#!/usr/bin/env bash

# core/help.sh - CLI interface for aliaskit

AK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMAND="${1:-}"
SUBCMD="${2:-}"

if [[ -f "${AK_ROOT}/core/registry.sh" ]]; then
    # shellcheck source=/dev/null
    source "${AK_ROOT}/core/registry.sh"
    ak_registry_bootstrap
fi

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
    echo "  ak help                - Open interactive help explorer (fzf)"
    echo "  ak help <module>       - Show aliases for a specific module"
    echo "  ak search <term>       - Search aliases for a keyword"
    echo "  ak list <module>       - List all aliases in a module"
    echo "  ak modules             - List all available modules"
    echo "  ak update              - Check and install updates"
    echo "  ak reload              - Reload aliaskit configuration"
    echo "  ak add                 - Create a custom module via wizard"
    echo "  ak edit                - Edit/delete custom modules"
    echo "  ak custom              - Show custom module status list"
    echo "  ak stats               - Show community stats"
    echo ""
    
    echo "Modules:"
    show_modules
    
    print_color "yellow" "💡 Tip: Type 'ak help <module>' to see specific commands."
}

function iter_all_module_files() {
    local module_file
    for module_file in "${AK_ROOT}/modules/"*.sh; do
        [[ -f "$module_file" ]] || continue
        echo "$module_file"
    done
    for module_file in "${AK_ROOT}/custom/modules/"*.sh; do
        [[ -f "$module_file" ]] || continue
        echo "$module_file"
    done
}

function show_modules() {
    local module_file category module_name
    for module_file in "${AK_ROOT}/modules/"*.sh; do
        [[ -f "$module_file" ]] || continue
        category=$(grep -m 1 "# CATEGORY:" "$module_file" | sed 's/# CATEGORY: //')
        module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
        printf "  %-15s - %s\n" "$module_name" "${category:-Uncategorized}"
    done
    for module_file in "${AK_ROOT}/custom/modules/"*.sh; do
        [[ -f "$module_file" ]] || continue
        category=$(grep -m 1 "# CATEGORY:" "$module_file" | sed 's/# CATEGORY: //')
        module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
        printf "  %-15s - %s [custom]\n" "$module_name" "${category:-Uncategorized}"
    done
}

function get_module_file_by_name() {
    local target_module="$1"
    target_module=$(printf "%s" "$target_module" | sed 's/[[:space:]]\+\[custom\]$//')
    for module_file in "${AK_ROOT}/modules/"*.sh; do
        [[ -f "$module_file" ]] || continue
        local module_name
        module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
        if [[ "$module_name" == "$target_module" ]]; then
            echo "$module_file"
            return 0
        fi
    done
    for module_file in "${AK_ROOT}/custom/modules/"*.sh; do
        [[ -f "$module_file" ]] || continue
        local module_name
        module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
        if [[ "$module_name" == "$target_module" ]]; then
            echo "$module_file"
            return 0
        fi
    done
    return 1
}

function render_module_preview_from_file() {
    local module_file="$1"

    if [[ ! -f "$module_file" ]]; then
        print_color "red" "Module file not found: $module_file"
        return
    fi

    local module_name category
    module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
    category=$(grep -m 1 "# CATEGORY:" "$module_file" | sed 's/# CATEGORY: //')

    print_color "cyan" "📦 Module: $module_name"
    echo "Category: ${category:-Uncategorized}"
    echo "---------------------------------------------------"

    awk '
        function flush_entry() {
            if (cmd == "") return
            found = 1
            printf "\033[32m%s\033[0m\n", cmd
            if (desc != "") printf "  desc: %s\n", desc
            if (usage != "") printf "  usage: %s\n", usage
            if (example != "") printf "  ex: %s\n", example
            printf "\n"
        }

        BEGIN {
            cmd = desc = usage = example = ""
            found = 0
        }

        /^## / {
            flush_entry()
            cmd = substr($0, 4)
            desc = usage = example = ""
            next
        }

        /^# @desc/ {
            line = $0
            sub(/^# @desc[[:space:]]*/, "", line)
            desc = line
            next
        }

        /^# @usage/ {
            line = $0
            sub(/^# @usage[[:space:]]*/, "", line)
            usage = line
            next
        }

        /^# @example/ {
            line = $0
            sub(/^# @example[[:space:]]*/, "", line)
            example = line
            next
        }

        END {
            flush_entry()
            if (!found) {
                print "No command metadata found in this module."
            }
        }
    ' "$module_file"
}

function show_help_tui() {
    if ! command -v fzf >/dev/null 2>&1; then
        print_color "yellow" "fzf is not installed. Falling back to classic help view."
        show_main_help
        return
    fi

    local module_rows
    module_rows=$(iter_all_module_files | while IFS= read -r module_file; do
        module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
        if [[ "$module_file" == "${AK_ROOT}/custom/modules/"* ]]; then
            printf "%s [custom]\n" "$module_name"
        else
            printf "%s\n" "$module_name"
        fi
    done | awk '!seen[$0]++')

    if [[ -z "$module_rows" ]]; then
        print_color "red" "No modules found in ${AK_ROOT}/modules"
        return
    fi

    local selection selected_module
    selection=$(printf "%s\n" "$module_rows" | \
        fzf --ansi \
            --height=90% \
            --layout=reverse \
            --border \
            --prompt='Module > ' \
            --preview-window='right:65%:wrap' \
            --preview "bash '${AK_ROOT}/core/help.sh' '__preview_module' {}") || return

    selected_module=$(printf "%s" "$selection" | sed 's/[[:space:]]\+\[custom\]$//')
    [[ -n "$selected_module" ]] && show_module_help "$selected_module"
}

function show_module_help() {
    local target_module="$1"
    local module_file

    if module_file=$(get_module_file_by_name "$target_module"); then
        render_module_preview_from_file "$module_file"
    else
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
    for module_file in "${AK_ROOT}/modules/"*.sh "${AK_ROOT}/custom/modules/"*.sh; do
        [[ -f "$module_file" ]] || continue
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
    __preview_module)
        if [[ -n "$SUBCMD" ]]; then
            preview_module_file=$(get_module_file_by_name "$SUBCMD")
            if [[ -n "$preview_module_file" ]]; then
                render_module_preview_from_file "$preview_module_file"
            else
                print_color "red" "Module not found: $SUBCMD"
            fi
        fi
        ;;
    help|list|"")
        if [[ -n "$SUBCMD" ]]; then
            show_module_help "$SUBCMD"
        elif [[ -t 0 && -t 1 ]]; then
            show_help_tui
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
    add)
        bash "${AK_ROOT}/core/add.sh" "$SUBCMD"
        ;;
    edit)
        bash "${AK_ROOT}/core/edit.sh" "$SUBCMD"
        ;;
    custom)
        bash "${AK_ROOT}/core/custom.sh"
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
