#!/usr/bin/env bash

# core/help.sh - CLI interface for aliaskit

AK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMAND="${1:-}"
SUBCMD="${2:-}"

# Usage:
# ak help -> list categories
# ak help module_name -> list commands in category
# ak search term -> search commands
# ak list module_name -> same as ak help module_name

function print_color() {
    local color="$1"
    local text="$2"
    case "$color" in
        "blue") echo -e "\033[34m${text}\033[0m" ;;
        "green") echo -e "\033[32m${text}\033[0m" ;;
        "yellow") echo -e "\033[33m${text}\033[0m" ;;
        "cyan") echo -e "\033[36m${text}\033[0m" ;;
        "red") echo -e "\033[31m${text}\033[0m" ;;
        "bold") echo -e "\033[1m${text}\033[0m" ;;
        *) echo "$text" ;;
    esac
}

function show_main_help() {
    print_color "cyan" "🚀 Aliaskit v1.0.0 - Command Line Superpowers"
    echo ""
    print_color "bold" "Usage:"
    echo "  ak <command> [args]"
    echo ""
    print_color "bold" "Commands:"
    echo "  ak help                - Show this help message"
    echo "  ak help <module>       - Show aliases for a specific module"
    echo "  ak search <term>       - Search aliases for a keyword"
    echo "  ak list <module>       - List all aliases in a module"
    echo "  ak modules             - List all available modules"
    echo "  ak update              - Check and install updates"
    echo "  ak reload              - Reload aliaskit configuration"
    echo "  ak stats               - Show community stats"
    echo ""
    
    echo "Modules:"
    show_modules
    
    print_color "yellow" "💡 Tip: Type 'ak help <module>' to see specific commands."
}

function show_modules() {
    for module_file in "${AK_ROOT}/modules/"*.sh; do
        if [[ -f "$module_file" ]]; then
            local category
            category=$(grep -m 1 "# CATEGORY:" "$module_file" | sed 's/# CATEGORY: //')
            local module_name
            module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
            printf "  %-15s - %s\n" "$module_name" "${category:-Uncategorized}"
        fi
    done
}

function show_module_help() {
    local target_module="$1"
    local found=0
    
    for module_file in "${AK_ROOT}/modules/"*.sh; do
        local module_name
        module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
        if [[ "$module_name" == "$target_module" ]]; then
            found=1
            local category
            category=$(grep -m 1 "# CATEGORY:" "$module_file" | sed 's/# CATEGORY: //')
            print_color "cyan" "📦 Module: $module_name ($category)"
            echo "---------------------------------------------------"
            
            # Parse comments
            # Format: 
            # ## alias_name
            # # @desc Description
            # # @usage Usage
            # alias...
            
            awk '
                /^## / { 
                    cmd = substr($0, 4)
                    getline
                    desc = ""
                    if ($1 == "#" && $2 == "@desc") {
                        sub(/^# @desc */, "", $0)
                        desc = $0
                    }
                    printf "\033[32m  %-18s\033[0m %s\n", cmd, desc
                }
            ' "$module_file"
            break
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        print_color "red" "Module not found: $target_module"
        echo "Use 'ak modules' to see available modules."
    fi
}

function search_aliases() {
    local term="$1"
    if [[ -z "$term" ]]; then
        print_color "red" "Error: Search term missing."
        echo "Usage: ak search <keyword>"
        return
    fi
    
    print_color "cyan" "🔍 Search results for: '$term'"
    echo "---------------------------------------------------"
    
    local found=0
    for module_file in "${AK_ROOT}/modules/"*.sh; do
        local module_name
        module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
        
        # We need to extract blocks of alias info.
        local results
        results=$(awk -v term="$term" '
            /^## / { 
                cmd = substr($0, 4)
                getline
                desc = ""
                if ($1 == "#" && $2 == "@desc") {
                    sub(/^# @desc */, "", $0)
                    desc = $0
                }
                
                # Check if term is in command or description (case insensitive)
                cmd_lower=tolower(cmd)
                desc_lower=tolower(desc)
                term_lower=tolower(term)
                
                if (index(cmd_lower, term_lower) || index(desc_lower, term_lower)) {
                    printf "\033[32m  %-18s\033[0m %s\n", cmd, desc
                }
            }
        ' "$module_file")
        
        if [[ -n "$results" ]]; then
            found=1
            print_color "yellow" "[$module_name]:"
            echo "$results"
            echo ""
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        echo "No aliases found matching '$term'."
    fi
}

case "$COMMAND" in
    help|list|"")
        if [[ -n "$SUBCMD" ]]; then
            show_module_help "$SUBCMD"
        else
            show_main_help
        fi
        ;;
    search)
        search_aliases "$SUBCMD"
        ;;
    modules)
        print_color "cyan" "📦 Available Modules"
        echo "---------------------------------------------------"
        show_modules
        ;;
    reload)
        # shellcheck source=/dev/null
        source ~/.bashrc
        print_color "green" "✔ Aliaskit reloaded directly."
        ;;
    update)
        bash "${AK_ROOT}/update.sh" "$SUBCMD"
        ;;
    stats)
        bash "${AK_ROOT}/core/stats.sh"
        ;;
    version)
        print_color "cyan" "Aliaskit v1.0.0"
        ;;
    *)
        if [[ "$COMMAND" == "help.sh" ]]; then
            if [[ -n "${1:-}" ]]; then
                show_main_help
            fi
        else
            # Try to match a module directly
            show_module_help "$COMMAND"
        fi
        ;;
esac
