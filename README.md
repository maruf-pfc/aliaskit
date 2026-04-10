# Aliaskit 🚀

[![CI/CD Pipeline](https://github.com/blackstart-labs/aliaskit/actions/workflows/lint.yml/badge.svg)](https://github.com/blackstart-labs/aliaskit/actions/workflows/lint.yml)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/blackstart-labs/aliaskit/wiki)

> **📚 Read the Full Documentation Website: [blackstart-labs.github.io/aliaskit/docs/MANUAL](https://blackstart-labs.github.io/aliaskit/docs/MANUAL)**

A comprehensive, modular open-source Bash alias toolkit designed for all Linux environments. Whether you are a developer, operations engineer, or casual Linux user, Aliaskit supercharges your terminal with a beautiful UI.

## Features
- **Modules**: Break down aliases into logical domains (Git, Docker, Network, System, etc.)
- **Built-in Docs**: Auto-generate beautiful `--help` formatting directly from snippet comments.
- **Auto Updater**: Hooks into `sudo apt update` to suggest Aliaskit tool upgrades smoothly!
- **Stats**: Real-time GitHub community integration.

## Installation

## Install

**Linux / macOS / WSL (Windows):**
```bash
curl -sL https://raw.githubusercontent.com/blackstart-labs/aliaskit/main/install.sh | bash
```

The installer auto-detects your OS and injects into the correct shell profile:

| Platform | Shell Profile | APT Hook |
| :--- | :--- | :--- |
| Ubuntu / Debian | `~/.bashrc` | ✅ Optional |
| Arch / Fedora / Other Linux | `~/.bashrc` | ❌ Skipped |
| macOS (Zsh) | `~/.zprofile` | ❌ N/A |
| WSL / Git Bash | `~/.bashrc` | ✅ Optional |
To remove all scripts, configs, and APT background hooks:
```bash
bash ~/.aliaskit/uninstall.sh
```

## Contributing
Please see the [Comprehensive Manual](https://blackstart-labs.github.io/aliaskit/docs/MANUAL) for detailed instructions on adding new `# @desc` modules and utilizing the `shellcheck` CI pipeline!

Once installed, reload your terminal or run `source ~/.bashrc`.

## Usage
The central command is `ak`.
- `ak help` -> Open interactive module explorer (fzf) with live preview.
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
