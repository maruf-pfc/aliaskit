#!/usr/bin/env bash

# update.sh - Check and pull the latest changes for aliaskit

AK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTO_MODE=0

if [[ "${1:-}" == "--auto" ]]; then
    AUTO_MODE=1
fi

check_and_update() {
    cd "$AK_ROOT" || return
    
    # We will do a quick check against remote
    git fetch origin main &>/dev/null || git fetch origin master &>/dev/null
    
    local LOCAL=$(git rev-parse HEAD 2>/dev/null)
    local REMOTE=$(git rev-parse @{u} 2>/dev/null)
    
    if [[ -z "$LOCAL" || -z "$REMOTE" ]]; then
        [[ $AUTO_MODE -eq 0 ]] && echo "Cannot check for updates. Are you in a git repository with an upstream set?"
        return
    fi
    
    if [[ "$LOCAL" != "$REMOTE" ]]; then
        if [[ $AUTO_MODE -eq 1 ]]; then
            echo -e "\n\033[33m🚀 A new version of Aliaskit is available!\033[0m"
            read -p "Do you want to update now? (y/N): " response < /dev/tty || response="N"
            if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                git pull
                echo -e "\033[32m✔ Aliaskit updated successfully.\033[0m"
                echo "Run 'ak reload' to apply changes."
            else
                echo "Update skipped. Run 'ak update' anytime to update."
            fi
        else
            echo "Updating Aliaskit..."
            git pull
            echo -e "\033[32m✔ Aliaskit updated successfully.\033[0m"
            echo "Run 'ak reload' to apply changes."
        fi
    else
        [[ $AUTO_MODE -eq 0 ]] && echo -e "\033[32m✔ Aliaskit is already up to date.\033[0m"
    fi
}

check_and_update
