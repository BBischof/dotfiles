#!/usr/bin/env bash

# load_secrets.sh - Load secrets from JSON file into environment variables
# Usage: source ./load_secrets.sh [secrets_file]

# Determine if being sourced
(return 0 2>/dev/null) && _ls_sourced=true || _ls_sourced=false

# Set quiet mode; respect caller-provided QUIET if set
if [[ "$_ls_sourced" == "true" ]]; then
    _ls_quiet=${QUIET:-true}
else
    _ls_quiet=${QUIET:-false}
fi

_ls_file="${1:-$HOME/.api_keys}"

# Clean up all internal variables except _ls_sourced (needed for return/exit decision)
_ls_cleanup() { unset _ls_quiet _ls_file _ls_script _ls_failed; unset -f _ls_cleanup; }

# Check if file exists
if [[ ! -f "$_ls_file" ]]; then
    [[ "$_ls_quiet" != "true" ]] && echo "Warning: Secrets file '$_ls_file' not found" >&2
    [[ "$_ls_quiet" != "true" ]] && echo "Usage: source ./load_secrets.sh [secrets_file]" >&2
    _ls_cleanup
    [[ "$_ls_sourced" == "true" ]] && { unset _ls_sourced; return 1; } || exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    [[ "$_ls_quiet" != "true" ]] && echo "Warning: jq is required but not installed. Install with: brew install jq" >&2
    _ls_cleanup
    [[ "$_ls_sourced" == "true" ]] && { unset _ls_sourced; return 1; } || exit 1
fi

# Validate JSON format and top-level type
if ! jq empty -- "$_ls_file" 2>/dev/null; then
    [[ "$_ls_quiet" != "true" ]] && echo "Warning: Invalid JSON format in '$_ls_file'" >&2
    _ls_cleanup
    [[ "$_ls_sourced" == "true" ]] && { unset _ls_sourced; return 1; } || exit 1
fi
if [[ "$(jq -r 'type' -- "$_ls_file")" != "object" ]]; then
    [[ "$_ls_quiet" != "true" ]] && echo "Warning: Secrets file must contain a top-level JSON object" >&2
    _ls_cleanup
    [[ "$_ls_sourced" == "true" ]] && { unset _ls_sourced; return 1; } || exit 1
fi

[[ "$_ls_quiet" != "true" ]] && echo "Loading secrets from '$_ls_file'..."

# Warn about invalid keys via a separate jq pass — never pass untrusted key
# names through eval, even inside an echo statement
if [[ "$_ls_quiet" != "true" ]]; then
    jq -r 'to_entries | .[] | select(.key | test("^[A-Za-z_][A-Za-z0-9_]*$") | not) | "Warning: Skipping invalid key: \(.key)"' -- "$_ls_file" >&2
fi

# Build export statements for valid keys only. Each line appends a failure
# flag so partial failures aren't masked by a later successful export.
# eval handles @sh-quoted multi-line values correctly as a unit.
if ! _ls_script="$(jq -r '
  to_entries | .[] |
  select(.key | test("^[A-Za-z_][A-Za-z0-9_]*$")) |
  "export \(.key)=\(if (.value | type) == "string" then .value else (.value | tojson) end | @sh) || _ls_failed=1"
' -- "$_ls_file")"; then
    [[ "$_ls_quiet" != "true" ]] && echo "Warning: Failed to process secrets file" >&2
    _ls_cleanup
    [[ "$_ls_sourced" == "true" ]] && { unset _ls_sourced; return 1; } || exit 1
fi

_ls_failed=0
eval "$_ls_script"
if [[ "$_ls_failed" == "1" ]]; then
    [[ "$_ls_quiet" != "true" ]] && echo "Warning: One or more exports failed" >&2
fi

if [[ "$_ls_quiet" != "true" ]]; then
    jq -r 'to_entries | .[] | select(.key | test("^[A-Za-z_][A-Za-z0-9_]*$")) | "Set: \(.key)"' -- "$_ls_file"
    echo "Secrets loaded successfully!"
fi

if [[ "$_ls_sourced" != "true" ]]; then
    echo "Warning: Script was executed directly; exports will not persist in the calling shell. Use: source $0" >&2
fi

_ls_cleanup
unset _ls_sourced
