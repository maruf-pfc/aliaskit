#!/usr/bin/env bash

# uninstall.sh - Removes Aliaskit from the system

set -e

INSTALL_DIR="${HOME}/.aliaskit"
BASHRC="${HOME}/.bashrc"

echo "Uninstalling Aliaskit..."

# 1. Remove from .bashrc
if grep -q "Aliaskit Initialization" "$BASHRC"; then
    # We use sed to remove the block
    # Removing the lines
    sed -i '/# Aliaskit Initialization/d' "$BASHRC"
    sed -i "\\|source ${INSTALL_DIR}/core/init.sh|d" "$BASHRC"
    echo "Removed aliaskit from $BASHRC"
fi

# 2. Remove configuration
if [[ -f "${HOME}/.aliaskit.conf" ]]; then
    read -p "Do you want to delete your configuration file (~/.aliaskit.conf)? (y/N): " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        rm -f "${HOME}/.aliaskit.conf"
        echo "Configuration removed."
    fi
fi

# 3. Remove APT Hook
if [[ -f "/etc/apt/apt.conf.d/99aliaskit" ]]; then
    read -p "Do you want to remove the APT auto-update hook? (Requires sudo) [y/N]: " rm_apt
    if [[ "$rm_apt" =~ ^[yY] ]]; then
        sudo rm -f "/etc/apt/apt.conf.d/99aliaskit"
        echo "APT hook removed."
    fi
fi

# 4. Remove directory structure
if [[ -d "$INSTALL_DIR" ]]; then
    read -p "Do you want to delete the installation directory ($INSTALL_DIR)? (y/N): " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        rm -rf "$INSTALL_DIR"
        echo "Installation directory removed."
    fi
fi

echo -e "\033[32m✔ Uninstallation complete.\033[0m"
