#!/usr/bin/env bash

# core/init.sh - Initializes aliaskit, loads configs, and sources enabled modules

AK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export AK_ROOT
export AK_CONFIG="${HOME}/.aliaskit.conf"

# Detect OS and export for conditional use in modules
_os_type="$(uname -s)"
case "$_os_type" in
    Linux*)
        if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
            export AK_OS="wsl"
        else
            export AK_OS="linux"
        fi
        ;;
    Darwin*)              export AK_OS="macos" ;;
    MINGW*|CYGWIN*|MSYS*) export AK_OS="windows" ;;
    *)                    export AK_OS="unknown" ;;
esac
unset _os_type

# Copy default config if it doesn't exist
if [[ ! -f "$AK_CONFIG" ]]; then
    # In case installation hasn't fully copied it yet, try local layout
    if [[ -f "${AK_ROOT}/config/aliaskit.conf.default" ]]; then
        cp "${AK_ROOT}/config/aliaskit.conf.default" "$AK_CONFIG"
    fi
fi

# Load configs
if [[ -f "$AK_CONFIG" ]]; then
    # shellcheck source=/dev/null
    source "$AK_CONFIG"
fi

# Registry / custom module helpers
if [[ -f "${AK_ROOT}/core/registry.sh" ]]; then
    # shellcheck source=/dev/null
    source "${AK_ROOT}/core/registry.sh"
    ak_registry_bootstrap
fi

# Source enabled modules
for module_file in "${AK_ROOT}/modules/"*.sh; do
    if [[ -f "$module_file" ]]; then
        module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
        var_name="AK_ENABLE_$(echo "$module_name" | tr '[:lower:]' '[:upper:]')"
        
        # Check if module is enabled (defaults to true if not explicitly set to false)
        if [[ "${!var_name}" != "false" ]]; then
            # shellcheck source=/dev/null
            source "$module_file"
        fi
    fi
done

# Source custom modules (keeps official priority on conflicts)
if declare -f ak_source_custom_modules_with_conflict_guard >/dev/null 2>&1; then
    ak_source_custom_modules_with_conflict_guard
fi

# The root `ak` command router
ak() {
    local cmd="${1:-help}"
    shift

    case "$cmd" in
        help|search|list|modules|config|update|reload|stats|version|--version|-v|add|edit|custom)
            if [[ "$cmd" == "version" || "$cmd" == "--version" || "$cmd" == "-v" ]]; then
                bash "${AK_ROOT}/core/help.sh" "version"
            elif [[ -f "${AK_ROOT}/core/${cmd}.sh" ]]; then
                bash "${AK_ROOT}/core/${cmd}.sh" "$@"
            elif [[ -f "${AK_ROOT}/core/help.sh" ]]; then
                bash "${AK_ROOT}/core/help.sh" "$cmd" "$@"
            fi
            ;;
        *)
            echo "Unknown command: $cmd"
            bash "${AK_ROOT}/core/help.sh"
            ;;
    esac
}
