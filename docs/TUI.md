# 🎨 Aliaskit TUI - Interactive Terminal UI

## Overview

Aliaskit now features a beautiful **interactive TUI (Terminal User Interface)** powered by `fzf`. Browse all 17 modules and 174+ aliases with arrow key navigation and instant preview!

---

## 📦 Installation

### Install fzf

The TUI requires `fzf` (fuzzy finder). Install it for your system:

**Ubuntu/Debian:**
```bash
sudo apt install fzf
```

**Fedora:**
```bash
sudo dnf install fzf
```

**Arch Linux:**
```bash
sudo pacman -S fzf
```

**macOS:**
```bash
brew install fzf
```

---

## 🚀 Usage

### Launch the TUI

Simply run:
```bash
ak help
```

Or explicitly:
```bash
ak tui
```

### Navigation

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate through modules |
| `Enter` | Select module and view details |
| `Esc` / `q` | Quit TUI |
| `/` | Fuzzy search modules |
| `Tab` | Copy command (future feature) |

### Features

✨ **Left Panel**: Lists all 17 modules with categories
📋 **Right Panel**: Instant preview of commands in selected module
🔍 **Fuzzy Search**: Press `/` to search modules by name
🎨 **Color Coding**: Beautiful syntax highlighting for commands
📖 **Rich Info**: Shows command name, description, usage, and examples

---

## 🎯 Example Output

When you select the `git` module, you'll see:

```
📦 Module: git (Git Version Control)
────────────────────────────────────────────────────────────

  clone                Clone a remote repository

  ginit                Initialise a new Git repository in the current directory

  gst                  Show full git status

  gs                   Short git status with branch and tracking info

  gl                   Pretty one-line graph log for all branches

  gll                  Detailed log with date, author, and subject per commit

  gd                   Show unstaged diff (what has changed since last add)

  gds                  Show staged diff (what will be in the next commit)
```

---

## 🔄 Fallback Behavior

If `fzf` is **not installed**, the command automatically falls back to the traditional text-based help:

```bash
ak help
# Shows regular help if fzf is missing
```

---

## 🛠️ Technical Details

### Files Modified

- `core/help_tui.sh` - New TUI implementation
- `core/help.sh` - Updated to auto-launch TUI
- `core/init.sh` - Added `tui` command

### Architecture

```
ak help/tui
    ↓
core/help_tui.sh
    ↓
├── get_modules()      → Lists all 17 modules
├── get_module_cmds()  → Parses ## comments from module files
└── fzf preview        → Real-time preview on right panel
```

### How It Works

1. **Module Discovery**: Scans `modules/*.sh` files
2. **Comment Parsing**: Extracts `## command`, `@desc`, `@usage`, `@example`
3. **fzf Integration**: Uses `--preview` for instant right-panel display
4. **ANSI Colors**: Maintains color scheme throughout

---

## 🎨 Color Scheme

| Element | Color |
|---------|-------|
| Module names | 🟦 Cyan |
| Commands | 🟩 Green |
| Descriptions | ⬜ White |
| Usage/Examples | ⬛ Dim |
| Headers/Borders | 🟨 Yellow |

---

## 💡 Tips

1. **Quick Access**: Use `ak help git` to skip TUI and see git help directly
2. **Search**: Press `/` in fzf and type "docker" to filter modules
3. **Fallback**: No fzf? No problem! Traditional help still works
4. **Copy Feature**: Coming soon - copy commands to clipboard with `Tab`

---

## 🐛 Troubleshooting

**TUI not launching?**
```bash
# Check if fzf is installed
which fzf

# Install fzf
sudo apt install fzf  # Ubuntu/Debian
```

**Preview not working?**
```bash
# Test preview manually
bash ~/.aliaskit/core/help_tui.sh _preview "git|Git Version Control"
```

**Colors looking weird?**
```bash
# Ensure your terminal supports ANSI colors
echo -e "\033[32mTest\033[0m"
```

---

## 📚 Available Modules

| Module | Category | Commands |
|--------|----------|----------|
| `navigation` | Navigation & Directory | 11 |
| `files` | Files & Searching | 12 |
| `system` | System Info & Monitoring | 10 |
| `process` | Process Management | 9 |
| `packages` | Package Management (APT) | 8 |
| `network` | Networking | 10 |
| `git` | Git Version Control | 20+ |
| `docker` | Docker & Compose | 12 |
| `python` | Python | 8 |
| `node` | Node/JS | 6 |
| `dotnet` | .NET | 5 |
| `cpp_java` | C++/Java | 4 |
| `archives` | Archives | 6 |
| `editors` | Editors | 6 |
| `servers` | Servers | 6 |
| `ssh` | SSH | 7 |
| `productivity` | Productivity | 8 |

---

## 🤝 Contributing

Want to improve the TUI? Check out:
- `core/help_tui.sh` - Main TUI logic
- `core/help.sh` - Help system
- See `CONTRIBUTING.md` for module creation guidelines

---

**Enjoy your supercharged terminal experience! 🚀**
