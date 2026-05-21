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

TMP="$(mktemp -d "${TMPDIR:-/tmp}/load_secrets_test.XXXXXX")"
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

# 6. Unreadable file warns specifically (not "invalid JSON")
if [ "$(id -u)" -eq 0 ]; then
    pass "unreadable file warns correctly (skipped — running as root)"
else
    echo '{"KEY":"val"}' > "$TMP/unreadable.json"
    chmod 000 "$TMP/unreadable.json"
    stderr=$(zsh -c "QUIET=false source '$SCRIPT' '$TMP/unreadable.json'" 2>&1 >/dev/null)
    chmod 644 "$TMP/unreadable.json"
    [[ "$stderr" == *"not readable"* ]] && pass "unreadable file warns correctly" || fail "unreadable file warns correctly" "*not readable*" "$stderr"
fi

# 7. Invalid JSON fails gracefully
echo 'not json' > "$TMP/bad.json"
zsh -c "source '$SCRIPT' '$TMP/bad.json'" 2>/dev/null
check "invalid JSON exits non-zero" "1" "$?"

# 8. Non-object top-level type (array) fails with warning
echo '[{"key":"val"}]' > "$TMP/array.json"
stderr=$(zsh -c "QUIET=false source '$SCRIPT' '$TMP/array.json'" 2>&1 >/dev/null)
[[ "$stderr" == *"top-level JSON object"* ]] && pass "array type rejected with warning" || fail "array type rejected with warning" "*top-level JSON object*" "$stderr"

# 9. Invalid key names are skipped and warned about
echo '{"VALID_KEY":"ok","123invalid":"bad"}' > "$TMP/badkey.json"
result=$(zsh -c "source '$SCRIPT' '$TMP/badkey.json' 2>/dev/null && echo \"\$VALID_KEY\"")
check "valid key loaded alongside invalid" "ok" "$result"
stderr=$(zsh -c "QUIET=false source '$SCRIPT' '$TMP/badkey.json'" 2>&1 >/dev/null)
[[ "$stderr" == *"Skipping reserved/invalid key"* ]] && pass "invalid key warning emitted" || fail "invalid key warning emitted" "*Skipping reserved/invalid key*" "$stderr"

# 10. Invalid key with control characters is JSON-encoded in warning (no terminal injection)
printf '%s' '{"key\u001b[31mred\u001b[0m":"bad","SAFE":"ok"}' > "$TMP/ctrlkey.json"
stderr=$(zsh -c "QUIET=false source '$SCRIPT' '$TMP/ctrlkey.json'" 2>&1 >/dev/null)
[[ "$stderr" != *$'\x1b'* ]] && pass "control chars in key name are escaped in warning" || fail "control chars in key name are escaped in warning" "no raw ESC" "raw ESC present"

# 11. Filename starting with - is handled via jq's --
echo '{"FLAG_TEST":"works"}' > "$TMP/-secrets.json"
result=$(zsh -c "source '$SCRIPT' '$TMP/-secrets.json' 2>/dev/null && echo \"\$FLAG_TEST\"")
check "filename starting with - handled" "works" "$result"

# 12. Internal _ls_ variables do not leak (check both exported and unexported)
leftover=$(zsh -c "source '$SCRIPT' '$TMP/simple.json' 2>/dev/null && set | grep '^_ls_'")
check "no _ls_ variables leak" "" "$leftover"

# 13. _ls_cleanup function itself is removed after sourcing
func_leak=$(zsh -c "source '$SCRIPT' '$TMP/simple.json' 2>/dev/null && typeset -f _ls_cleanup")
check "_ls_cleanup function removed after sourcing" "" "$func_leak"

# 14. Direct execution warns about persistence
warning=$(bash "$SCRIPT" "$TMP/simple.json" 2>&1 | grep "will not persist")
[[ -n "$warning" ]] && pass "direct execution warns about persistence" || fail "direct execution warns about persistence" "warning present" "none"

# 15. Number value exported as string
echo '{"PORT":8080}' > "$TMP/number.json"
result=$(zsh -c "source '$SCRIPT' '$TMP/number.json' 2>/dev/null && echo \"\$PORT\"")
check "number value exported as string" "8080" "$result"

# 16. _ls_ prefixed keys are skipped (reserved namespace)
echo '{"_ls_failed":"injected","REAL_KEY":"ok"}' > "$TMP/lsprefix.json"
result=$(zsh -c "source '$SCRIPT' '$TMP/lsprefix.json' 2>/dev/null && echo \"\$REAL_KEY\"")
check "_ls_ prefixed key not exported" "ok" "$result"
result=$(zsh -c "source '$SCRIPT' '$TMP/lsprefix.json' 2>/dev/null && echo \"\${_ls_failed:-unset}\"")
check "_ls_ prefixed key value not set" "unset" "$result"
stderr=$(zsh -c "QUIET=false source '$SCRIPT' '$TMP/lsprefix.json'" 2>&1 >/dev/null)
[[ "$stderr" == *"Skipping reserved/invalid key"* ]] && pass "_ls_ key warning emitted" || fail "_ls_ key warning emitted" "*Skipping reserved/invalid key*" "$stderr"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" == "0" ]] && exit 0 || exit 1
