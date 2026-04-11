---
layout: default
title: Aliaskit Documentation
---

# 🚀 Aliaskit — Command Line Superpowers

**Aliaskit** is a comprehensive, modular open-source Bash alias toolkit with 17 built-in domains covering everything from system monitoring to cloud infrastructure.

## Quick Install

**Linux / macOS / WSL (Windows):**
```bash
curl -sL https://raw.githubusercontent.com/blackstart-labs/aliaskit/main/install.sh | bash
```

The installer auto-detects your OS and shell profile automatically:

| Platform | Shell Profile Injected | APT Auto-Hook |
| :--- | :--- | :--- |
| Ubuntu / Debian | `~/.bashrc` | ✅ Optional |
| Arch / Fedora / Other Linux | `~/.bashrc` | ❌ Skipped |
| macOS (Zsh, default since Catalina) | `~/.zprofile` | ❌ N/A |
| WSL / Git Bash (Windows) | `~/.bashrc` | ✅ Optional |

> **💡 Tip:** On macOS, aliaskit uses `pbcopy` for clipboard commands. On WSL it uses `clip.exe`. On Linux it uses `xclip` or `xsel`.

Then reload your terminal:
```bash
source ~/.bashrc   # Linux / WSL
source ~/.zprofile # macOS
```

## Core Commands

| Command | Description |
| :--- | :--- |
| `ak help` | Show the main help menu |
| `ak help <module>` | Show all aliases in a module |
| `ak search <term>` | Search all aliases by keyword |
| `ak modules` | List all available modules |
| `ak update` | Pull the latest version |
| `ak add` | Create a custom module (wizard mode) |
| `ak edit` | Edit or delete custom modules |
| `ak custom` | View custom module/command status |
| `ak stats` | Show GitHub community statistics |
| `ak version` | Show current version |

## Module Overview

Aliaskit ships with **17 modules** and **100+ aliases** out of the box. Select a chapter in the sidebar to browse any module in detail.

| # | Module | Focus |
| :--- | :--- | :--- |
| 01 | [Navigation](./modules/01_navigation.md) | Fast directory jumping |
| 02 | [Files](./modules/02_files.md) | File operations & clipboard |
| 03 | [System](./modules/03_system.md) | CPU, RAM, disk monitoring |
| 04 | [Process](./modules/04_process.md) | Kill processes & ports |
| 05 | [Packages](./modules/05_packages.md) | APT shortcuts |
| 06 | [Network](./modules/06_network.md) | IPs, ports, sockets |
| 07 | [Git](./modules/07_git.md) | VCS aliases |
| 08 | [Docker](./modules/08_docker.md) | Container management |
| 09 | [Python](./modules/09_python.md) | Venvs, pip, ruff |
| 10 | [Node / JS](./modules/10_node.md) | npm, yarn, pnpm |
| 11 | [.NET](./modules/11_dotnet.md) | Build, run, test |
| 12 | [C++ & Java](./modules/12_cpp_java.md) | Compile & execute |
| 13 | [Archives](./modules/13_archives.md) | Universal extractor |
| 14 | [Editors](./modules/14_editors.md) | vim, nano, VS Code |
| 15 | [Servers](./modules/15_servers.md) | systemctl, logs |
| 16 | [SSH](./modules/16_ssh.md) | Keys, configs |
| 17 | [Productivity](./modules/17_productivity.md) | Weather, timers, fun |
