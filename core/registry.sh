#!/usr/bin/env bash

# core/registry.sh - Shared helpers for official/custom module registry

AK_CUSTOM_ROOT="${AK_ROOT}/custom"
AK_CUSTOM_MODULE_DIR="${AK_CUSTOM_ROOT}/modules"
AK_CUSTOM_DOC_MODULE_DIR="${AK_CUSTOM_ROOT}/docs/modules"
AK_CUSTOM_INDEX_FILE="${AK_CUSTOM_ROOT}/index.tsv"

AK_RESERVED_AK_COMMANDS=(
    help search list modules config update reload stats version --version -v
    add edit custom
)

ak_registry_bootstrap() {
    mkdir -p "$AK_CUSTOM_MODULE_DIR" "$AK_CUSTOM_DOC_MODULE_DIR"
    touch "$AK_CUSTOM_INDEX_FILE"
}

ak_extract_module_name_from_file() {
    local module_file="$1"
    basename "$module_file" | sed -E 's/^[0-9]+_//' | sed 's/\.sh$//'
}

ak_humanize_module_name() {
    local module_name="$1"
    echo "$module_name" | tr '_' ' ' | awk '{
        for (i=1; i<=NF; i++) {
            $i=toupper(substr($i,1,1)) substr($i,2)
        }
        print
    }'
}

ak_collect_official_module_names() {
    local module_file
    for module_file in "${AK_ROOT}/modules/"*.sh; do
        [[ -f "$module_file" ]] || continue
        ak_extract_module_name_from_file "$module_file"
    done
}

ak_collect_custom_module_names() {
    local module_file
    for module_file in "${AK_CUSTOM_MODULE_DIR}/"*.sh; do
        [[ -f "$module_file" ]] || continue
        ak_extract_module_name_from_file "$module_file"
    done
}

ak_module_exists_official() {
    local target="$1"
    ak_collect_official_module_names | grep -qx "$target"
}

ak_module_exists_custom() {
    local target="$1"
    ak_collect_custom_module_names | grep -qx "$target"
}

ak_module_exists_any() {
    local target="$1"
    ak_module_exists_official "$target" || ak_module_exists_custom "$target"
}

ak_collect_commands_from_dir() {
    local target_dir="$1"
    local module_file
    for module_file in "${target_dir}/"*.sh; do
        [[ -f "$module_file" ]] || continue
        awk '/^## /{ print substr($0,4) }' "$module_file"
    done
}

ak_collect_official_commands() {
    ak_collect_commands_from_dir "${AK_ROOT}/modules"
}

ak_collect_custom_commands() {
    ak_collect_commands_from_dir "${AK_CUSTOM_MODULE_DIR}"
}

ak_command_exists_official() {
    local target="$1"
    ak_collect_official_commands | grep -qx "$target"
}

ak_command_exists_custom() {
    local target="$1"
    ak_collect_custom_commands | grep -qx "$target"
}

ak_command_exists_any() {
    local target="$1"
    ak_command_exists_official "$target" || ak_command_exists_custom "$target"
}

ak_slugify() {
    local input="$1"
    echo "$input" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_]+/_/g; s/^_+//; s/_+$//; s/_{2,}/_/g'
}

ak_validate_module_name() {
    local module_name="$1"
    [[ "$module_name" =~ ^[a-z][a-z0-9_]*$ ]]
}

ak_validate_command_name() {
    local command_name="$1"
    [[ "$command_name" =~ ^[a-zA-Z0-9._+-]+$ ]]
}

ak_is_reserved_ak_command() {
    local value="$1"
    local reserved
    for reserved in "${AK_RESERVED_AK_COMMANDS[@]}"; do
        [[ "$reserved" == "$value" ]] && return 0
    done
    return 1
}

ak_get_next_custom_module_number() {
    local max=89
    local module_file base prefix

    for module_file in "${AK_CUSTOM_MODULE_DIR}/"*.sh; do
        [[ -f "$module_file" ]] || continue
        base=$(basename "$module_file")
        prefix="${base%%_*}"
        if [[ "$prefix" =~ ^[0-9]+$ ]] && (( prefix > max )); then
            max="$prefix"
        fi
    done

    echo $((max + 1))
}

ak_extract_entries_from_module_file() {
    local module_file="$1"
    awk '
        function flush_entry() {
            if (cmd == "") return
            gsub(/\t/, " ", desc)
            gsub(/\t/, " ", usage)
            gsub(/\t/, " ", example)
            gsub(/\t/, " ", genuine)
            printf "%s\t%s\t%s\t%s\t%s\n", cmd, desc, usage, example, genuine
        }
        BEGIN {
            cmd = desc = usage = example = genuine = ""
        }
        /^## / {
            flush_entry()
            cmd = substr($0, 4)
            desc = usage = example = genuine = ""
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
        /^alias[[:space:]]+/ {
            line = $0
            sub(/^alias[[:space:]]+/, "", line)
            split(line, parts, "=")
            alias_name = parts[1]
            gsub(/[[:space:]]+/, "", alias_name)
            if (alias_name == cmd) {
                genuine = substr(line, index(line, "=") + 1)
                q = sprintf("%c", 39)
                if (substr(genuine,1,1) == "\"" || substr(genuine,1,1) == q) {
                    genuine = substr(genuine,2)
                }
                if (substr(genuine,length(genuine),1) == "\"" || substr(genuine,length(genuine),1) == q) {
                    genuine = substr(genuine,1,length(genuine)-1)
                }
            }
            next
        }
        END {
            flush_entry()
        }
    ' "$module_file"
}

ak_get_custom_module_file_by_name() {
    local target_module="$1"
    local module_file module_name
    for module_file in "${AK_CUSTOM_MODULE_DIR}/"*.sh; do
        [[ -f "$module_file" ]] || continue
        module_name=$(ak_extract_module_name_from_file "$module_file")
        if [[ "$module_name" == "$target_module" ]]; then
            echo "$module_file"
            return 0
        fi
    done
    return 1
}

ak_filter_custom_module_for_source() {
    local module_file="$1"
    local conflict_pipe="$2"

    awk -v conflicts="$conflict_pipe" '
        BEGIN {
            split(conflicts, arr, "|")
            for (i in arr) {
                if (arr[i] != "") skip[arr[i]] = 1
            }
            in_skip = 0
        }
        /^## / {
            cmd = substr($0, 4)
            in_skip = (cmd in skip)
            if (!in_skip) print
            next
        }
        {
            if (!in_skip) print
        }
    ' "$module_file"
}

ak_write_custom_index() {
    ak_registry_bootstrap

    {
        echo -e "type\tmodule\titem\tgenuine\tstatus\tdesc\tusage\texample\tpath"

        local module_file module_name category module_status
        for module_file in "${AK_CUSTOM_MODULE_DIR}/"*.sh; do
            [[ -f "$module_file" ]] || continue
            module_name=$(ak_extract_module_name_from_file "$module_file")
            category=$(grep -m 1 "# CATEGORY:" "$module_file" | sed 's/# CATEGORY:[[:space:]]*//')

            if ak_module_exists_official "$module_name"; then
                module_status="Already registered in official list"
            else
                module_status="active"
            fi

            echo -e "module\t${module_name}\t${category}\t-\t${module_status}\t-\t-\t-\t${module_file}"

            while IFS=$'\t' read -r cmd desc usage example genuine; do
                [[ -n "$cmd" ]] || continue
                local cmd_status
                if ak_command_exists_official "$cmd"; then
                    cmd_status="Already registered in official list"
                else
                    cmd_status="active"
                fi
                echo -e "command\t${module_name}\t${cmd}\t${genuine}\t${cmd_status}\t${desc}\t${usage}\t${example}\t${module_file}"
            done < <(ak_extract_entries_from_module_file "$module_file")
        done
    } > "$AK_CUSTOM_INDEX_FILE"
}

ak_source_custom_modules_with_conflict_guard() {
    ak_registry_bootstrap

    local module_file module_name conflict_commands conflict_pipe

    for module_file in "${AK_CUSTOM_MODULE_DIR}/"*.sh; do
        [[ -f "$module_file" ]] || continue
        module_name=$(ak_extract_module_name_from_file "$module_file")

        # If a module name became official later, do not source the custom one.
        if ak_module_exists_official "$module_name"; then
            continue
        fi

        conflict_commands=""
        while IFS= read -r cmd; do
            [[ -n "$cmd" ]] || continue
            if ak_command_exists_official "$cmd"; then
                conflict_commands+="${cmd}"$'\n'
            fi
        done < <(awk '/^## /{ print substr($0,4) }' "$module_file")

        if [[ -z "$conflict_commands" ]]; then
            # shellcheck source=/dev/null
            source "$module_file"
        else
            conflict_pipe=$(printf "%s" "$conflict_commands" | paste -sd'|' -)
            # shellcheck disable=SC1090
            source <(ak_filter_custom_module_for_source "$module_file" "$conflict_pipe")
        fi
    done

    ak_write_custom_index
}