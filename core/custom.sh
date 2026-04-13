#!/usr/bin/env bash

# core/custom.sh - Show custom module/command registry and statuses

AK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "${AK_ROOT}/core/registry.sh"

print_color() {
    local color="$1"
    local text="$2"
    case "$color" in
        green) echo -e "\033[32m${text}\033[0m" ;;
        yellow) echo -e "\033[33m${text}\033[0m" ;;
        red) echo -e "\033[31m${text}\033[0m" ;;
        cyan) echo -e "\033[36m${text}\033[0m" ;;
        bold) echo -e "\033[1m${text}\033[0m" ;;
        *) echo "$text" ;;
    esac
}

ak_registry_bootstrap
ak_write_custom_index

if [[ ! -s "$AK_CUSTOM_INDEX_FILE" ]]; then
    print_color yellow "No custom entries found. Use 'ak add' first."
    exit 0
fi

print_color cyan "🧩 Custom Modules & Commands"
echo "---------------------------------------------------"

awk -F'\t' '
    NR == 1 { next }
    $1 == "module" {
        printf "\n[%s]  status: %s\n", $2, $5
        next
    }
    $1 == "command" {
        printf "  - %-18s => %-30s [%s]\n", $3, $4, $5
    }
' "$AK_CUSTOM_INDEX_FILE"
