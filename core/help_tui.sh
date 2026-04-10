#!/usr/bin/env bash

# core/help_tui.sh - Interactive TUI for aliaskit using fzf

AK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Color codes
readonly RESET='\033[0m'
readonly BOLD='\033[1m'
readonly CYAN='\033[36m'
readonly GREEN='\033[32m'
readonly YELLOW='\033[33m'
readonly BLUE='\033[34m'
readonly MAGENTA='\033[35m'
readonly RED='\033[31m'
readonly DIM='\033[2m'

# Check if fzf is installed
check_fzf() {
    if ! command -v fzf &>/dev/null; then
        echo -e "${RED}✖ Error: fzf is not installed.${RESET}"
        echo -e "${CYAN}Install fzf to use the TUI:${RESET}"
        echo ""
        echo -e "  ${GREEN}Ubuntu/Debian:${RESET}  sudo apt install fzf"
        echo -e "  ${GREEN}Fedora:${RESET}         sudo dnf install fzf"
        echo -e "  ${GREEN}Arch:${RESET}           sudo pacman -S fzf"
        echo -e "  ${GREEN}macOS:${RESET}          brew install fzf"
        echo ""
        echo -e "${YELLOW}Falling back to regular help...${RESET}"
        echo ""
        bash "${AK_ROOT}/core/help.sh"
        exit 0
    fi
}

# Get all modules as array
get_modules() {
    local modules=()
    for module_file in "${AK_ROOT}/modules/"*.sh; do
        if [[ -f "$module_file" ]]; then
            local module_name
            module_name=$(basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
            local category
            category=$(grep -m 1 "# CATEGORY:" "$module_file" | sed 's/# CATEGORY: //')
            modules+=("${module_name}|${category:-Uncategorized}")
        fi
    done
    printf '%s\n' "${modules[@]}"
}

# Parse module commands
get_module_commands() {
    local module_name="$1"
    local module_file=""
    
    # Find the module file by name
    for f in "${AK_ROOT}/modules/"*.sh; do
        local fname
        fname=$(basename "$f" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//')
        if [[ "$fname" == "$module_name" ]]; then
            module_file="$f"
            break
        fi
    done
    
    if [[ -z "$module_file" ]] || [[ ! -f "$module_file" ]]; then
        echo -e "${RED}Module not found: ${module_name}${RESET}"
        return 1
    fi

    local category
    category=$(grep -m 1 "# CATEGORY:" "$module_file" | sed 's/# CATEGORY: //')
    
    echo -e "${BOLD}${CYAN}📦 Module: ${module_name}${RESET} ${DIM}(${category})${RESET}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${RESET}"
    echo ""
    
    awk '
        /^## / {
            cmd = substr($0, 4)
            getline
            desc = ""
            usage = ""
            example = ""
            
            # Parse @desc
            if ($1 == "#" && $2 == "@desc") {
                line = $0
                sub(/^# @desc */, "", line)
                desc = line
            }
            
            # Parse @usage
            if ($1 == "#" && $2 == "@usage") {
                line = $0
                sub(/^# @usage */, "", line)
                usage = line
            }
            
            # Parse @example
            if ($1 == "#" && $2 == "@example") {
                line = $0
                sub(/^# @example */, "", line)
                example = line
            }
            
            printf "\033[32m  %-20s\033[0m %s\n", cmd, desc
            if (usage != "") {
                printf "\033[2m    Usage: %s\033[0m\n", usage
            }
            if (example != "") {
                printf "\033[2m    Example: %s\033[0m\n", example
            }
            printf "\n"
        }
    ' "$module_file"
}

# Main TUI function
show_tui() {
    check_fzf
    
    # Get all modules
    local modules
    modules=$(get_modules)
    
    if [[ -z "$modules" ]]; then
        echo -e "${YELLOW}⚠ No modules found.${RESET}"
        return 1
    fi
    
    # Create a temp file for preview
    local tmp_preview
    tmp_preview=$(mktemp)
    trap 'rm -f "$tmp_preview"' EXIT
    
    # Generate initial preview for first module
    local first_module
    first_module=$(echo "$modules" | head -n1 | cut -d'|' -f1)
    get_module_commands "$first_module" > "$tmp_preview" 2>/dev/null
    
    # Calculate window dimensions
    local height width
    height=$((${LINES:-$(tput lines 2>/dev/null || echo 24)} - 2))
    width=$((${COLUMNS:-$(tput cols 2>/dev/null || echo 80)} - 2))
    
    # Ensure minimum size
    [[ $height -lt 10 ]] && height=10
    [[ $width -lt 40 ]] && width=40
    
    # Left panel width (about 30% of screen)
    local left_width=$((width * 30 / 100))
    [[ $left_width -lt 25 ]] && left_width=25
    [[ $left_width -gt 40 ]] && left_width=40
    
    echo -e "${BOLD}${CYAN}🚀 Aliaskit v1.0.0 - Interactive Module Browser${RESET}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${RESET}"
    echo -e "${YELLOW}↑/↓${RESET} Navigate modules  |  ${YELLOW}Enter${RESET} Select  |  ${YELLOW}Esc/q${RESET} Quit  |  ${YELLOW}Tab${RESET} Copy command"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${RESET}"
    echo ""
    
    # Launch fzf with preview
    local selected
    selected=$(echo "$modules" | \
        fzf \
            --height "$height" \
            --width "$width" \
            --layout=reverse \
            --border=rounded \
            --preview="bash '${AK_ROOT}/core/help_tui.sh' _preview {}" \
            --preview-window=right:65% \
            --header=$'📦 Select a module to browse commands' \
            --header-first \
            --color="hl:36,hl+:37,header:33,info:35,pointer:36,border:36" \
            --prompt="🔍 Module> " \
            --marker="✓ " \
            --pointer="▸ " \
            --delimiter='|' \
            --with-nth=1 \
            --bind="enter:accept" \
            --bind="q:abort" \
            --bind="esc:abort" \
            --bind="ctrl-c:abort" \
            --ansi \
            2>/dev/null)
    
    if [[ -n "$selected" ]]; then
        local module_name
        module_name=$(echo "$selected" | cut -d'|' -f1)
        echo ""
        echo -e "${GREEN}✔ Selected module: ${BOLD}${CYAN}${module_name}${RESET}"
        echo ""
        
        # Show the full help for the selected module
        get_module_commands "$module_name"
    fi
}

# Preview function for fzf
preview_module() {
    local input="$1"
    local module_name
    module_name=$(echo "$input" | cut -d'|' -f1)
    
    if [[ -n "$module_name" ]]; then
        get_module_commands "$module_name"
    else
        echo -e "${YELLOW}No module selected${RESET}"
    fi
}

# Main entry point
case "${1:-}" in
    _preview)
        # This is called by fzf for preview
        shift
        preview_module "$@"
        ;;
    tui)
        show_tui
        ;;
    *)
        # Default: show TUI
        show_tui
        ;;
esac
