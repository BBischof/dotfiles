#!/usr/bin/env bash

# load_secrets.sh - Load secrets from JSON file into environment variables
# Usage: source ./load_secrets.sh [secrets_file]

# Save original shell options
if [[ -o errexit ]]; then
    ORIGINAL_ERREXIT=true
else
    ORIGINAL_ERREXIT=false
fi

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

# Function to restore original shell settings
restore_shell_settings() {
    if [[ "$ORIGINAL_ERREXIT" == "true" ]]; then
        set -e
    else
        set +e
    fi
}

# Check if file exists
if [[ ! -f "$SECRETS_FILE" ]]; then
    [[ "$QUIET" != "true" ]] && echo "Warning: Secrets file '$SECRETS_FILE' not found" >&2
    [[ "$QUIET" != "true" ]] && echo "Usage: source ./load_secrets.sh [secrets_file]" >&2
    restore_shell_settings
    [[ "$SOURCED" == "true" ]] && return 1 || exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    [[ "$QUIET" != "true" ]] && echo "Warning: jq is required but not installed" >&2
    [[ "$QUIET" != "true" ]] && echo "Install with: brew install jq" >&2
    restore_shell_settings
    [[ "$SOURCED" == "true" ]] && return 1 || exit 1
fi

# Validate JSON format
if ! jq empty "$SECRETS_FILE" 2>/dev/null; then
    [[ "$QUIET" != "true" ]] && echo "Warning: Invalid JSON format in '$SECRETS_FILE'" >&2
    restore_shell_settings
    [[ "$SOURCED" == "true" ]] && return 1 || exit 1
fi

# Load secrets into environment variables
[[ "$QUIET" != "true" ]] && echo "Loading secrets from '$SECRETS_FILE'..."

# @sh shell-quotes values so objects, newlines, and special chars are handled correctly
while IFS= read -r assignment; do
    if [[ -n "$assignment" ]]; then
        key="${assignment%%=*}"
        if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
            [[ "$QUIET" != "true" ]] && echo "Warning: Skipping invalid key: $key" >&2
            continue
        fi
        eval "export $assignment"
        [[ "$QUIET" != "true" ]] && echo "Set: $key"
    fi
done < <(jq -r 'to_entries | .[] | "\(.key)=\(if (.value | type) == "string" then .value else (.value | tojson) end | @sh)"' "$SECRETS_FILE")

[[ "$QUIET" != "true" ]] && echo "Secrets loaded successfully!"
[[ "$QUIET" != "true" ]] && echo "Note: These variables are now available in your current shell session."

# Restore original shell settings
restore_shell_settings
