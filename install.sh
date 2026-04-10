#!/usr/bin/env bash

# install.sh - Cross-platform installer for Aliaskit
# Supports: Linux (Debian/Arch/Fedora), macOS, WSL, Git Bash (Windows)

set -e

REPO_URL="https://github.com/arifinsiddiqzisan/aliaskit-tui.git"
INSTALL_DIR="${HOME}/.aliaskit"
SOURCE_LINE="source ${INSTALL_DIR}/core/init.sh"

echo "🚀 Installing Aliaskit..."

# 1. Detect shell profile file
detect_shell_profile() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: prefer zsh (default since Catalina)
        if [[ -f "${HOME}/.zprofile" ]]; then echo "${HOME}/.zprofile"
        elif [[ -f "${HOME}/.zshrc" ]]; then echo "${HOME}/.zshrc"
        else echo "${HOME}/.bash_profile"; fi
    else
        # Linux / WSL / Git Bash
        echo "${HOME}/.bashrc"
    fi
}
SHELL_PROFILE="$(detect_shell_profile)"

# 2. Clone or update repository
if [[ -d "$INSTALL_DIR" ]]; then
    echo "Aliaskit is already installed. Updating..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "Cloning repository..."
    GIT_TERMINAL_PROMPT=0 git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
fi

# 3. Add to shell profile
if grep -qF "$SOURCE_LINE" "$SHELL_PROFILE"; then
    echo "Aliaskit is already in ${SHELL_PROFILE}."
else
    echo -e "\n# Aliaskit Initialization" >> "$SHELL_PROFILE"
    echo "$SOURCE_LINE" >> "$SHELL_PROFILE"
    echo "Added initialization code to ${SHELL_PROFILE}."
fi

# 4. Setup default config if none exists
if [[ ! -f "${HOME}/.aliaskit.conf" ]]; then
    cp "${INSTALL_DIR}/config/aliaskit.conf.default" "${HOME}/.aliaskit.conf"
    echo "Created default configuration."
fi

# 5. Setup APT Auto-Update hook (Debian/Ubuntu Linux only)
if [[ -d "/etc/apt/apt.conf.d" ]] && [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "\nWould you like to enable the APT auto-update hook?"
    echo "This checks for Aliaskit updates whenever you run 'sudo apt update'."
    read -rp "Enable APT hook? (Requires sudo) [y/N]: " enable_apt
    if [[ "$enable_apt" =~ ^[yY] ]]; then
        cat <<EOF | sudo bash -c "cat > /etc/apt/apt.conf.d/99aliaskit"
APT::Update::Post-Invoke { "su -c 'bash ${INSTALL_DIR}/update.sh --auto' - $USER || true"; };
EOF
        echo "APT hook installed successfully!"
    fi
fi

echo -e "\n\033[32m✔ Installation complete!\033[0m"
echo -e "Please run \033[36msource ${SHELL_PROFILE}\033[0m to start using aliaskit."
echo -e "Type \033[33mak help\033[0m to see available commands."
