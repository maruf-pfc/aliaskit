#!/usr/bin/env bash

# core/add.sh - Interactive custom module creator

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

escape_single_quotes() {
    local s="$1"
    printf "%s" "$s" | sed "s/'/'\\''/g"
}

choose_action() {
    if command -v fzf >/dev/null 2>&1; then
        printf "Add another command\nSave module\nCancel\n" | fzf --height=12 --layout=reverse --border --prompt="Action > "
    else
        local choice
        echo "1) Add another command"
        echo "2) Save module"
        echo "3) Cancel"
        read -r -p "Choose [1-3]: " choice
        case "$choice" in
            2) echo "Save module" ;;
            3) echo "Cancel" ;;
            *) echo "Add another command" ;;
        esac
    fi
}

prompt_nonempty() {
    local label="$1"
    local value=""
    while true; do
        read -r -p "$label" value
        [[ -n "$value" ]] && { echo "$value"; return 0; }
        print_color red "Input cannot be empty."
    done
}

ak_registry_bootstrap

print_color cyan "✨ ak add - Custom Module Wizard"
echo ""

while true; do
    module_name_raw=$(prompt_nonempty "Module name (example: my_tools): ")
    module_name=$(ak_slugify "$module_name_raw")

    if ! ak_validate_module_name "$module_name"; then
        print_color red "Invalid module name. Use lowercase + numbers + underscore, and start with a letter."
        continue
    fi

    if ak_is_reserved_ak_command "$module_name"; then
        print_color red "This module name is reserved by ak."
        continue
    fi

    if ak_module_exists_any "$module_name"; then
        print_color red "This module name is already registered (official/custom)."
        continue
    fi

    break
done

category=$(prompt_nonempty "Module category/title (example: My Tools): ")

declare -a CMDS=()
declare -a GENUINES=()
declare -a DESCS=()
declare -a USAGES=()
declare -a EXAMPLES=()

while true; do
    echo ""
    print_color bold "[ left-box: custom command ] = [ right-box: genuine command ]"

    while true; do
        custom_cmd=$(prompt_nonempty "Left-box custom command: ")
        if ! ak_validate_command_name "$custom_cmd"; then
            print_color red "Invalid command format."
            continue
        fi
        if ak_is_reserved_ak_command "$custom_cmd"; then
            print_color red "This command is reserved by ak."
            continue
        fi
        if ak_command_exists_any "$custom_cmd"; then
            print_color red "This command is already registered (official/custom)."
            continue
        fi
        if printf "%s\n" "${CMDS[@]}" | grep -qx "$custom_cmd"; then
            print_color red "Duplicate command inside this module wizard."
            continue
        fi
        break
    done

    genuine_cmd=$(prompt_nonempty "Right-box genuine command: ")
    desc=$(prompt_nonempty "Description: ")
    usage=$(prompt_nonempty "Usage: ")
    example=$(prompt_nonempty "Example: ")

    CMDS+=("$custom_cmd")
    GENUINES+=("$genuine_cmd")
    DESCS+=("$desc")
    USAGES+=("$usage")
    EXAMPLES+=("$example")

    action=$(choose_action)
    case "$action" in
        "Save module")
            break
            ;;
        "Cancel")
            print_color yellow "Cancelled. Nothing was saved."
            exit 0
            ;;
        *)
            ;;
    esac
done

if [[ ${#CMDS[@]} -eq 0 ]]; then
    print_color red "At least one command is required."
    exit 1
fi

prefix=$(ak_get_next_custom_module_number)
printf -v prefix_padded "%02d" "$prefix"

module_file="${AK_CUSTOM_MODULE_DIR}/${prefix_padded}_${module_name}.sh"
doc_file="${AK_CUSTOM_DOC_MODULE_DIR}/${prefix_padded}_${module_name}.md"
doc_title=$(ak_humanize_module_name "$module_name")

{
    echo "#!/usr/bin/env bash"
    echo "# CATEGORY: ${category}"
    echo "# MODULE: ${module_name}"
    echo ""
    for i in "${!CMDS[@]}"; do
        cmd="${CMDS[$i]}"
        desc="${DESCS[$i]}"
        usage="${USAGES[$i]}"
        example="${EXAMPLES[$i]}"
        genuine="${GENUINES[$i]}"
        echo "## ${cmd}"
        echo "# @desc  ${desc}"
        echo "# @usage ${usage}"
        echo "# @example ${example}"
        echo "alias ${cmd}='$(escape_single_quotes "$genuine")'"
        echo ""
    done
} > "$module_file"

{
    echo "# ${doc_title}"
    echo ""
    echo "Custom module created with \`ak add\`."
    echo ""
    echo "---"
    echo ""
    echo "## Aliases"
    echo ""
    for i in "${!CMDS[@]}"; do
        cmd="${CMDS[$i]}"
        desc="${DESCS[$i]}"
        usage="${USAGES[$i]}"
        example="${EXAMPLES[$i]}"
        genuine="${GENUINES[$i]}"
        echo "### \`${cmd}\`"
        echo "- **Description:** ${desc}"
        echo "- **Usage:** \`${usage}\`"
        echo "- **Example:** \`${example}\`"
        echo ""
        echo "\`\`\`bash"
        echo "${cmd}"
        echo "# Runs: ${genuine}"
        echo "\`\`\`"
        echo ""
    done
    echo "---"
    echo ""
    echo "{{#template ../templates/footer.md module=${doc_title}}}"
} > "$doc_file"

chmod +x "$module_file"
ak_write_custom_index

print_color green "✔ Custom module created: ${module_name}"
echo "- Module file: ${module_file}"
echo "- Doc file:    ${doc_file}"
print_color yellow "Run 'ak reload' to activate this module in current shell."