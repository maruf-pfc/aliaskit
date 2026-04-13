#!/usr/bin/env bash

# core/add.sh - Single-screen form style custom module wizard

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
        *) echo "$text" ;;
    esac
}

escape_single_quotes() {
    local s="$1"
    printf "%s" "$s" | sed "s/'/'\\''/g"
}

input_box() {
    local label="$1"
    local header="$2"
    local initial="${3:-}"
    local out value

    if ! command -v fzf >/dev/null 2>&1; then
        read -r -p "$label: " value
        printf "%s" "$value"
        return 0
    fi

    out=$(printf '\n' | fzf \
        --height=95% \
        --layout=reverse \
        --border \
        --phony \
        --prompt="${label} > " \
        --header="$header" \
        --bind='enter:accept' \
        --print-query \
        --query="$initial") || return 1

    value=$(printf "%s\n" "$out" | awk 'NF{print; exit}')
    printf "%s" "$value"
}

form_menu() {
    local header="$1"

    local lines=()
    lines+=("Module Name      : ${module_name}")
    lines+=("Category         : ${category}")
    lines+=("Custom Command   : ${custom_cmd}")
    lines+=("Genuine Command  : ${genuine_cmd}")
    lines+=("Description      : ${desc}")
    lines+=("Usage            : ${usage}")
    lines+=("Example          : ${example}")
    lines+=("")
    lines+=("[Save]")
    lines+=("[Save & Add Another]")
    lines+=("[Cancel]")

    if command -v fzf >/dev/null 2>&1; then
        printf "%s\n" "${lines[@]}" | fzf \
            --height=95% \
            --layout=reverse \
            --border \
            --prompt='Form > ' \
            --header="$header"
    else
        printf "%s\n" "[Cancel]"
    fi
}

clear_command_fields() {
    custom_cmd=""
    genuine_cmd=""
    desc=""
    usage=""
    example=""
}

append_current_command_or_fail() {
    [[ -n "$custom_cmd" && -n "$genuine_cmd" && -n "$desc" && -n "$usage" && -n "$example" ]] || {
        form_error="All fields are required."
        return 1
    }

    if ! ak_validate_command_name "$custom_cmd"; then
        form_error="Invalid command format."
        return 1
    fi
    if ak_is_reserved_ak_command "$custom_cmd"; then
        form_error="This command is reserved by ak."
        return 1
    fi
    if ak_command_exists_any "$custom_cmd"; then
        form_error="This command is already registered (official/custom)."
        return 1
    fi
    if printf "%s\n" "${CMDS[@]}" | grep -qx "$custom_cmd"; then
        form_error="Duplicate command in this module."
        return 1
    fi

    CMDS+=("$custom_cmd")
    GENUINES+=("$genuine_cmd")
    DESCS+=("$desc")
    USAGES+=("$usage")
    EXAMPLES+=("$example")
    return 0
}

write_module_and_docs() {
    local prefix prefix_padded module_file doc_file doc_title
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
            echo "## ${CMDS[$i]}"
            echo "# @desc  ${DESCS[$i]}"
            echo "# @usage ${USAGES[$i]}"
            echo "# @example ${EXAMPLES[$i]}"
            echo "alias ${CMDS[$i]}='$(escape_single_quotes "${GENUINES[$i]}")'"
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
            echo "### \`${CMDS[$i]}\`"
            echo "- **Description:** ${DESCS[$i]}"
            echo "- **Usage:** \`${USAGES[$i]}\`"
            echo "- **Example:** \`${EXAMPLES[$i]}\`"
            echo ""
            echo "\`\`\`bash"
            echo "${CMDS[$i]}"
            echo "# Runs: ${GENUINES[$i]}"
            echo "\`\`\`"
            echo ""
        done
        echo "---"
        echo ""
        echo "{{#template ../templates/footer.md module=${doc_title}}}"
    } > "$doc_file"

    chmod +x "$module_file"
    ak_write_custom_index

    # shellcheck source=/dev/null
    source ~/.aliaskit/core/init.sh >/dev/null 2>&1 || true

    print_color green "✔ Custom module created: ${module_name}"
    echo "- Module file: ${module_file}"
    echo "- Doc file:    ${doc_file}"
    print_color green "✔ Auto executed: source ~/.aliaskit/core/init.sh"
}

ak_registry_bootstrap

declare -a CMDS=()
declare -a GENUINES=()
declare -a DESCS=()
declare -a USAGES=()
declare -a EXAMPLES=()

module_name=""
category=""
clear_command_fields
form_error=""

while true; do
    form_header="ak add — Single Form Wizard\n\nUse ↑↓ to navigate, Enter to edit/select."
    form_header+="\nCommands queued: ${#CMDS[@]}"
    [[ -n "$form_error" ]] && form_header+="\n\n⚠ ${form_error}"

    selected=$(form_menu "$form_header") || exit 0
    case "$selected" in
        "Module Name"* )
            value=$(input_box "Module Name" "Enter module name" "$module_name") || continue
            [[ -n "$value" ]] && module_name=$(ak_slugify "$value")
            form_error=""
            ;;
        "Category"* )
            value=$(input_box "Category" "Enter category/title" "$category") || continue
            [[ -n "$value" ]] && category="$value"
            form_error=""
            ;;
        "Custom Command"* )
            value=$(input_box "Custom Command" "Enter custom command" "$custom_cmd") || continue
            [[ -n "$value" ]] && custom_cmd="$value"
            form_error=""
            ;;
        "Genuine Command"* )
            value=$(input_box "Genuine Command" "Enter genuine command" "$genuine_cmd") || continue
            [[ -n "$value" ]] && genuine_cmd="$value"
            form_error=""
            ;;
        "Description"* )
            value=$(input_box "Description" "Enter description" "$desc") || continue
            [[ -n "$value" ]] && desc="$value"
            form_error=""
            ;;
        "Usage"* )
            value=$(input_box "Usage" "Enter usage" "$usage") || continue
            [[ -n "$value" ]] && usage="$value"
            form_error=""
            ;;
        "Example"* )
            value=$(input_box "Example" "Enter example" "$example") || continue
            [[ -n "$value" ]] && example="$value"
            form_error=""
            ;;
        "[Save & Add Another]")
            [[ -n "$module_name" && -n "$category" ]] || { form_error="All fields are required."; continue; }
            if ! ak_validate_module_name "$module_name"; then
                form_error="Invalid module name."
                continue
            fi
            if ak_is_reserved_ak_command "$module_name"; then
                form_error="This module name is reserved by ak."
                continue
            fi
            if ak_module_exists_any "$module_name"; then
                form_error="This module name is already registered (official/custom)."
                continue
            fi

            if append_current_command_or_fail; then
                clear_command_fields
                form_error=""
            fi
            ;;
        "[Save]")
            [[ -n "$module_name" && -n "$category" ]] || { form_error="All fields are required."; continue; }
            if ! ak_validate_module_name "$module_name"; then
                form_error="Invalid module name."
                continue
            fi
            if ak_is_reserved_ak_command "$module_name"; then
                form_error="This module name is reserved by ak."
                continue
            fi
            if ak_module_exists_any "$module_name"; then
                form_error="This module name is already registered (official/custom)."
                continue
            fi

            if append_current_command_or_fail; then
                write_module_and_docs
                exit 0
            fi
            ;;
        "[Cancel]"|"")
            exit 0
            ;;
    esac
done
