#!/usr/bin/env bash

# load_secrets.sh - Load secrets from JSON file into environment variables
# Usage: source ./load_secrets.sh [secrets_file]

# Determine if being sourced
(return 0 2>/dev/null) && SOURCED=true || SOURCED=false

# Set quiet mode based on how we're being run
if [[ "$SOURCED" == "true" ]]; then
    QUIET=${QUIET:-true}
else
    QUIET=${QUIET:-false}
fi

# Default secrets file
DEFAULT_SECRETS_FILE="$HOME/.api_keys"

# Use provided file or default
SECRETS_FILE="${1:-$DEFAULT_SECRETS_FILE}"

# Check if file exists
if [[ ! -f "$SECRETS_FILE" ]]; then
    [[ "$QUIET" != "true" ]] && echo "Warning: Secrets file '$SECRETS_FILE' not found" >&2
    [[ "$QUIET" != "true" ]] && echo "Usage: source ./load_secrets.sh [secrets_file]" >&2
    [[ "$SOURCED" == "true" ]] && return 1 || exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    [[ "$QUIET" != "true" ]] && echo "Warning: jq is required but not installed" >&2
    [[ "$QUIET" != "true" ]] && echo "Install with: brew install jq" >&2
    [[ "$SOURCED" == "true" ]] && return 1 || exit 1
fi

# Validate JSON format
if ! jq empty "$SECRETS_FILE" 2>/dev/null; then
    [[ "$QUIET" != "true" ]] && echo "Warning: Invalid JSON format in '$SECRETS_FILE'" >&2
    [[ "$SOURCED" == "true" ]] && return 1 || exit 1
fi

# Validate top-level type is an object
if [[ "$(jq -r 'type' "$SECRETS_FILE")" != "object" ]]; then
    [[ "$QUIET" != "true" ]] && echo "Warning: Secrets file must contain a top-level JSON object" >&2
    [[ "$SOURCED" == "true" ]] && return 1 || exit 1
fi

[[ "$QUIET" != "true" ]] && echo "Loading secrets from '$SECRETS_FILE'..."

# Emit export statements for valid keys; warn on invalid ones.
# eval processes the full output as a shell script, so @sh-quoted values
# containing embedded newlines are handled correctly as a unit.
_load_secrets_script="$(jq -r '
  to_entries | .[] |
  if (.key | test("^[A-Za-z_][A-Za-z0-9_]*$")) then
    "export \(.key)=\(if (.value | type) == "string" then .value else (.value | tojson) end | @sh)"
  else
    "echo \"Warning: Skipping invalid key: \(.key)\" >&2"
  end
' "$SECRETS_FILE")"

if ! eval "$_load_secrets_script"; then
    [[ "$QUIET" != "true" ]] && echo "Warning: One or more exports failed" >&2
fi
unset _load_secrets_script

if [[ "$QUIET" != "true" ]]; then
    jq -r 'to_entries | .[] | select(.key | test("^[A-Za-z_][A-Za-z0-9_]*$")) | "Set: \(.key)"' "$SECRETS_FILE"
    echo "Secrets loaded successfully!"
fi

if [[ "$SOURCED" != "true" ]]; then
    echo "Warning: Script was executed directly; exports will not persist in the calling shell. Use: source $0" >&2
fi
