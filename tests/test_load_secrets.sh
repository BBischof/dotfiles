#!/usr/bin/env bash
# Tests for load_secrets.sh
# Run directly: bash tests/test_load_secrets.sh

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/load_secrets.sh"
PASS=0; FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1 — expected '$2', got '$3'"; FAIL=$((FAIL + 1)); }

check() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$actual" == "$expected" ]]; then
        pass "$desc"
    else
        fail "$desc" "$expected" "$actual"
    fi
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo ""
echo "load_secrets.sh tests"
echo "─────────────────────"

# 1. Simple string values load correctly
echo '{"API_KEY":"abc123","OTHER":"xyz"}' > "$TMP/simple.json"
result=$(zsh -c "source '$SCRIPT' '$TMP/simple.json' 2>/dev/null && echo \"\$API_KEY \$OTHER\"")
check "simple string values" "abc123 xyz" "$result"

# 2. JSON object value serialized to string (compare parsed to avoid key-order brittleness)
echo '{"CREDS":{"type":"service_account","project":"test"}}' > "$TMP/object.json"
result=$(zsh -c "source '$SCRIPT' '$TMP/object.json' 2>/dev/null && echo \"\$CREDS\"")
type_val=$(echo "$result" | jq -r '.type' 2>/dev/null)
project_val=$(echo "$result" | jq -r '.project' 2>/dev/null)
if [[ "$type_val" == "service_account" && "$project_val" == "test" ]]; then
    pass "JSON object value serialized"
else
    fail "JSON object value serialized" "type=service_account,project=test" "type=$type_val,project=$project_val"
fi

# 3. Multi-line string value (embedded newline)
printf '{"PEM_KEY":"line1\\nline2"}' > "$TMP/multiline.json"
result=$(zsh -c "source '$SCRIPT' '$TMP/multiline.json' 2>/dev/null && printf '%s' \"\$PEM_KEY\"")
check "multiline string value" "$(printf 'line1\nline2')" "$result"

# 4. Missing file exits non-zero
zsh -c "source '$SCRIPT' '$TMP/nonexistent.json'" 2>/dev/null
check "missing file exits non-zero" "1" "$?"

# 5. Missing file warns on stderr
stderr=$(zsh -c "QUIET=false source '$SCRIPT' '$TMP/nonexistent.json'" 2>&1 >/dev/null)
[[ "$stderr" == *"not found"* ]] && pass "missing file warns on stderr" || fail "missing file warns on stderr" "*not found*" "$stderr"

# 6. Invalid JSON fails gracefully
echo 'not json' > "$TMP/bad.json"
zsh -c "source '$SCRIPT' '$TMP/bad.json'" 2>/dev/null
check "invalid JSON exits non-zero" "1" "$?"

# 7. Non-object top-level type (array) fails with warning
echo '[{"key":"val"}]' > "$TMP/array.json"
stderr=$(zsh -c "QUIET=false source '$SCRIPT' '$TMP/array.json'" 2>&1 >/dev/null)
[[ "$stderr" == *"top-level JSON object"* ]] && pass "array type rejected with warning" || fail "array type rejected with warning" "*top-level JSON object*" "$stderr"

# 8. Invalid key names are skipped and warned about
echo '{"VALID_KEY":"ok","123invalid":"bad"}' > "$TMP/badkey.json"
result=$(zsh -c "source '$SCRIPT' '$TMP/badkey.json' 2>/dev/null && echo \"\$VALID_KEY\"")
check "valid key loaded alongside invalid" "ok" "$result"
stderr=$(zsh -c "QUIET=false source '$SCRIPT' '$TMP/badkey.json'" 2>&1 >/dev/null)
[[ "$stderr" == *"Skipping invalid key"* ]] && pass "invalid key warning emitted" || fail "invalid key warning emitted" "*Skipping invalid key*" "$stderr"

# 9. Filename starting with - is handled via jq's --
echo '{"FLAG_TEST":"works"}' > "$TMP/-secrets.json"
result=$(zsh -c "source '$SCRIPT' '$TMP/-secrets.json' 2>/dev/null && echo \"\$FLAG_TEST\"")
check "filename starting with - handled" "works" "$result"

# 10. Internal _ls_ variables do not leak into environment
leftover=$(zsh -c "source '$SCRIPT' '$TMP/simple.json' 2>/dev/null && env | grep '^_ls_'")
check "no _ls_ variables leak" "" "$leftover"

# 11. Direct execution warns about persistence
warning=$(bash "$SCRIPT" "$TMP/simple.json" 2>&1 | grep "will not persist")
[[ -n "$warning" ]] && pass "direct execution warns about persistence" || fail "direct execution warns about persistence" "warning present" "none"

# 12. Number value exported as string
echo '{"PORT":8080}' > "$TMP/number.json"
result=$(zsh -c "source '$SCRIPT' '$TMP/number.json' 2>/dev/null && echo \"\$PORT\"")
check "number value exported as string" "8080" "$result"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" == "0" ]] && exit 0 || exit 1
