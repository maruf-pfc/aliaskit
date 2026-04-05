#!/usr/bin/env bash

# install.sh - Installer for Aliaskit

set -e

REPO_URL="https://github.com/blackstart-labs/aliaskit.git"
INSTALL_DIR="${HOME}/.aliaskit"
BASHRC="${HOME}/.bashrc"
SOURCE_LINE="source ${INSTALL_DIR}/core/init.sh"

echo "🚀 Installing Aliaskit..."

# 1. Clone or update repository
if [[ -d "$INSTALL_DIR" ]]; then
    echo "Aliaskit is already installed. Updating..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# 2. Add to .bashrc
if grep -qF "$SOURCE_LINE" "$BASHRC"; then
    echo "Aliaskit is already in your .bashrc."
else
    echo -e "\n# Aliaskit Initialization" >> "$BASHRC"
    echo "$SOURCE_LINE" >> "$BASHRC"
    echo "Added initialization code to $BASHRC."
fi

# 3. Setup default config if none exists
if [[ ! -f "${HOME}/.aliaskit.conf" ]]; then
    cp "${INSTALL_DIR}/config/aliaskit.conf.default" "${HOME}/.aliaskit.conf"
    echo "Created default configuration."
fi

# 4. Setup APT Auto-Update hook
if [[ -d "/etc/apt/apt.conf.d" ]]; then
    echo -e "\nWould you like to enable the APT auto-update hook?"
    echo "This checks for Aliaskit updates whenever you manually run 'sudo apt update'."
    read -p "Enable APT hook? (Requires sudo pass) [y/N]: " enable_apt
    if [[ "$enable_apt" =~ ^[yY] ]]; then
        cat <<EOF | sudo bash -c "cat > /etc/apt/apt.conf.d/99aliaskit"
APT::Update::Post-Invoke { "su -c 'bash ${INSTALL_DIR}/update.sh --auto' - $USER || true"; };
EOF
        echo "APT hook installed successfully!"
    fi
fi

echo -e "\n\033[32m✔ Installation complete!\033[0m"
echo -e "Please run \033[36msource ~/.bashrc\033[0m to start using aliaskit."
echo -e "Type \033[33mak help\033[0m to see available commands."
