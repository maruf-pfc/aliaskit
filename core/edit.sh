#!/usr/bin/env bash

# core/edit.sh - Edit/delete custom modules and commands

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

prompt_with_default() {
    local label="$1"
    local def="$2"
    local value out

    if command -v fzf >/dev/null 2>&1; then
        out=$(printf '\n' | fzf \
            --height=95% \
            --layout=reverse \
            --border \
            --phony \
            --prompt="${label} > " \
            --header="ak edit • Enter value (ESC to cancel)" \
            --bind='enter:accept' \
            --print-query \
            --query="$def") || return 1
        value=$(printf "%s\n" "$out" | head -n1)
        if [[ -z "$value" ]]; then
            echo "$def"
        else
            echo "$value"
        fi
        return 0
    fi

    read -r -p "$label [$def]: " value
    if [[ -z "$value" ]]; then
        echo "$def"
    else
        echo "$value"
    fi
}

pick_one() {
    local prompt="$1"
    shift
    local items=("$@")

    if [[ ${#items[@]} -eq 0 ]]; then
        return 1
    fi

    if command -v fzf >/dev/null 2>&1; then
        printf "%s\n" "${items[@]}" | fzf --height=18 --layout=reverse --border --prompt="$prompt"
    else
        local i
        for i in "${!items[@]}"; do
            printf "%d) %s\n" "$((i+1))" "${items[$i]}"
        done
        local idx
        read -r -p "Choose [1-${#items[@]}]: " idx
        if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx >=1 && idx <= ${#items[@]} )); then
            echo "${items[$((idx-1))]}"
        fi
    fi
}

write_module_file() {
    local module_file="$1"
    local module_name="$2"
    local category="$3"

    {
        echo "#!/usr/bin/env bash"
        echo "# CATEGORY: ${category}"
        echo "# MODULE: ${module_name}"
        echo ""
        local i
        for i in "${!CMDS[@]}"; do
            echo "## ${CMDS[$i]}"
            echo "# @desc  ${DESCS[$i]}"
            echo "# @usage ${USAGES[$i]}"
            echo "# @example ${EXAMPLES[$i]}"
            echo "alias ${CMDS[$i]}='$(escape_single_quotes "${GENUINES[$i]}")'"
            echo ""
        done
    } > "$module_file"

    chmod +x "$module_file"
}

write_doc_file() {
    local doc_file="$1"
    local module_name="$2"
    local title
    title=$(ak_humanize_module_name "$module_name")

    {
        echo "# ${title}"
        echo ""
        echo "Custom module managed by \`ak add\` / \`ak edit\`."
        echo ""
        echo "---"
        echo ""
        echo "## Aliases"
        echo ""
        local i
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
        echo "{{#template ../templates/footer.md module=${title}}}"
    } > "$doc_file"
}

find_cmd_index() {
    local target="$1"
    local i
    for i in "${!CMDS[@]}"; do
        [[ "${CMDS[$i]}" == "$target" ]] && { echo "$i"; return 0; }
    done
    return 1
}

ak_registry_bootstrap

mapfile -t custom_modules < <(ak_collect_custom_module_names)
if [[ ${#custom_modules[@]} -eq 0 ]]; then
    print_color yellow "No custom modules found. Use 'ak add' first."
    exit 0
fi

selected_module=$(pick_one "Custom Module > " "${custom_modules[@]}")
[[ -n "$selected_module" ]] || exit 0

module_file=$(ak_get_custom_module_file_by_name "$selected_module")
[[ -n "$module_file" ]] || { print_color red "Unable to locate module file."; exit 1; }

base_name=$(basename "$module_file")
prefix="${base_name%%_*}"

module_name="$selected_module"
category=$(grep -m 1 "# CATEGORY:" "$module_file" | sed 's/# CATEGORY:[[:space:]]*//')

declare -a CMDS=()
declare -a GENUINES=()
declare -a DESCS=()
declare -a USAGES=()
declare -a EXAMPLES=()

while IFS=$'\t' read -r c d u e g; do
    [[ -n "$c" ]] || continue
    CMDS+=("$c")
    DESCS+=("$d")
    USAGES+=("$u")
    EXAMPLES+=("$e")
    GENUINES+=("$g")
done < <(ak_extract_entries_from_module_file "$module_file")

while true; do
    echo ""
    print_color cyan "Editing module: ${module_name}"
    action=$(pick_one "Edit Action > " \
        "Edit module name" \
        "Edit category" \
        "Add command" \
        "Edit command" \
        "Delete command" \
        "Save and exit" \
        "Delete module" \
        "Cancel")

    case "$action" in
        "Edit module name")
            new_name_raw=$(prompt_with_default "New module name" "$module_name") || continue
            new_name=$(ak_slugify "$new_name_raw")
            if ! ak_validate_module_name "$new_name"; then
                print_color red "Invalid module name format."
                continue
            fi
            if ak_is_reserved_ak_command "$new_name"; then
                print_color red "Reserved name."
                continue
            fi
            if [[ "$new_name" != "$module_name" ]] && ak_module_exists_any "$new_name"; then
                print_color red "Module name already registered (official/custom)."
                continue
            fi
            module_name="$new_name"
            ;;
        "Edit category")
            category=$(prompt_with_default "Category" "$category") || continue
            ;;
        "Add command")
            while true; do
                cmd=$(prompt_with_default "Custom command" "") || { print_color yellow "Cancelled adding command."; break; }
                [[ -n "$cmd" ]] || { print_color red "Command cannot be empty."; continue; }
                if ! ak_validate_command_name "$cmd"; then
                    print_color red "Invalid command format."
                    continue
                fi
                if ak_is_reserved_ak_command "$cmd"; then
                    print_color red "Reserved command."
                    continue
                fi
                if ak_command_exists_any "$cmd" || printf "%s\n" "${CMDS[@]}" | grep -qx "$cmd"; then
                    print_color red "Command already registered (official/custom)."
                    continue
                fi
                break
            done
            [[ -n "$cmd" ]] || continue
            genuine=$(prompt_with_default "Genuine command" "") || continue
            desc=$(prompt_with_default "Description" "") || continue
            usage=$(prompt_with_default "Usage" "$cmd") || continue
            example=$(prompt_with_default "Example" "$cmd") || continue
            CMDS+=("$cmd")
            GENUINES+=("$genuine")
            DESCS+=("$desc")
            USAGES+=("$usage")
            EXAMPLES+=("$example")
            ;;
        "Edit command")
            if [[ ${#CMDS[@]} -eq 0 ]]; then
                print_color yellow "No command to edit."
                continue
            fi
            selected_cmd=$(pick_one "Command > " "${CMDS[@]}")
            [[ -n "$selected_cmd" ]] || continue
            idx=$(find_cmd_index "$selected_cmd") || continue

            new_cmd=$(prompt_with_default "Custom command" "${CMDS[$idx]}") || continue
            if [[ "$new_cmd" != "${CMDS[$idx]}" ]]; then
                if ! ak_validate_command_name "$new_cmd"; then
                    print_color red "Invalid command format."
                    continue
                fi
                if ak_is_reserved_ak_command "$new_cmd"; then
                    print_color red "Reserved command."
                    continue
                fi
                if ak_command_exists_any "$new_cmd" || printf "%s\n" "${CMDS[@]}" | grep -qx "$new_cmd"; then
                    print_color red "Command already registered (official/custom)."
                    continue
                fi
                CMDS[$idx]="$new_cmd"
            fi

            GENUINES[$idx]=$(prompt_with_default "Genuine command" "${GENUINES[$idx]}") || continue
            DESCS[$idx]=$(prompt_with_default "Description" "${DESCS[$idx]}") || continue
            USAGES[$idx]=$(prompt_with_default "Usage" "${USAGES[$idx]}") || continue
            EXAMPLES[$idx]=$(prompt_with_default "Example" "${EXAMPLES[$idx]}") || continue
            ;;
        "Delete command")
            if [[ ${#CMDS[@]} -eq 0 ]]; then
                print_color yellow "No command to delete."
                continue
            fi
            selected_cmd=$(pick_one "Delete Command > " "${CMDS[@]}")
            [[ -n "$selected_cmd" ]] || continue
            idx=$(find_cmd_index "$selected_cmd") || continue

            unset 'CMDS[idx]' 'GENUINES[idx]' 'DESCS[idx]' 'USAGES[idx]' 'EXAMPLES[idx]'
            CMDS=("${CMDS[@]}")
            GENUINES=("${GENUINES[@]}")
            DESCS=("${DESCS[@]}")
            USAGES=("${USAGES[@]}")
            EXAMPLES=("${EXAMPLES[@]}")
            ;;
        "Save and exit")
            if [[ ${#CMDS[@]} -eq 0 ]]; then
                print_color red "Module must contain at least one command."
                continue
            fi

            conflict_found=0
            for cmd in "${CMDS[@]}"; do
                if ak_command_exists_official "$cmd"; then
                    print_color red "'${cmd}' is already registered in official list. Change it before saving."
                    conflict_found=1
                fi
            done
            (( conflict_found == 1 )) && continue

            new_module_file="${AK_CUSTOM_MODULE_DIR}/${prefix}_${module_name}.sh"
            new_doc_file="${AK_CUSTOM_DOC_MODULE_DIR}/${prefix}_${module_name}.md"

            write_module_file "$new_module_file" "$module_name" "$category"
            write_doc_file "$new_doc_file" "$module_name"

            if [[ "$new_module_file" != "$module_file" && -f "$module_file" ]]; then
                rm -f "$module_file"
            fi
            old_doc_file="${AK_CUSTOM_DOC_MODULE_DIR}/${prefix}_${selected_module}.md"
            if [[ "$new_doc_file" != "$old_doc_file" && -f "$old_doc_file" ]]; then
                rm -f "$old_doc_file"
            fi

            ak_write_custom_index
            # shellcheck source=/dev/null
            source /home/zisan/Downloads/aliaskit-tui/core/init.sh >/dev/null 2>&1 || true
            print_color green "✔ Saved module: ${module_name}"
            print_color green "✔ Auto executed: source /home/zisan/Downloads/aliaskit-tui/core/init.sh"
            exit 0
            ;;
        "Delete module")
            read -r -p "Type YES to delete module '${module_name}': " confirm
            if [[ "$confirm" =~ ^([Yy][Ee][Ss]|[Yy])$ ]]; then
                rm -f "$module_file" "${AK_CUSTOM_DOC_MODULE_DIR}/${prefix}_${selected_module}.md" "${AK_CUSTOM_DOC_MODULE_DIR}/${prefix}_${module_name}.md"
                ak_write_custom_index
                # shellcheck source=/dev/null
                source ~/.aliaskit/core/init.sh >/dev/null 2>&1 || true
                print_color green "✔ Module deleted: ${module_name}"
                print_color green "✔ Auto executed: source ~/.aliaskit/core/init.sh"
                exit 0
            else
                print_color yellow "Delete cancelled."
            fi
            ;;
        "Cancel"|"")
            print_color yellow "Cancelled. No changes saved."
            exit 0
            ;;
    esac
done
