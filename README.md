# Aliaskit 🚀

[![CI/CD Pipeline](https://github.com/blackstart-labs/aliaskit/actions/workflows/lint.yml/badge.svg)](https://github.com/blackstart-labs/aliaskit/actions/workflows/lint.yml)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/blackstart-labs/aliaskit/wiki)

A comprehensive, modular open-source Bash alias toolkit designed for all Linux environments. Whether you are a developer, operations engineer, or casual Linux user, Aliaskit supercharges your terminal with a beautiful UI.

## Features
- **Modules**: Break down aliases into logical domains (Git, Docker, Network, System, etc.)
- **Built-in Docs**: Auto-generate beautiful `--help` formatting directly from snippet comments.
- **Auto Updater**: Hooks into `sudo apt update` to suggest Aliaskit tool upgrades smoothly!
- **Stats**: Real-time GitHub community integration.

## Installation

Run this one-liner to install:
```bash
curl -sL https://raw.githubusercontent.com/blackstart-labs/aliaskit/main/install.sh | bash
```
Once installed, reload your terminal or run `source ~/.bashrc`.

## Usage
The central command is `ak`.
- `ak help` -> Show all modules and general commands.
- `ak help git` -> Show all commands available in the Git module.
- `ak search logs` -> Search for the word 'logs' across all descriptions and commands.
- `ak stats` -> Check out how many stars and forks the project has!
- `ak update` -> Update Aliaskit manually.

## Configuration
Aliaskit generates a `.aliaskit.conf` file in your home directory. Open it to toggle individual modules on or off:
```bash
AK_ENABLE_DOCKER=true
AK_ENABLE_GIT=false # disable git aliases
```

## Community
Star us on GitHub and use `ak stats` to see where we're at!
