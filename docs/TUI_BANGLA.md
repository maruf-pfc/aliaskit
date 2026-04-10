# 🎨 Aliaskit TUI - Bangla Guide

## ✅ Ki Banano Holo

Tomar **"ak help"** command er jonno ekta **sundor interactive TUI (Terminal User Interface)** banano hoyeche jo **fzf** use kore!

---

## 🎯 Main Features

### ✨ Ja Ja Feature Ache:

1. **Left Side**: 17 ta module er list dekhabo (arrow key diye navigate kora jabe)
2. **Right Side**: Selected module er sob commands instantly show korbe
3. **Arrow Keys**: ↑ ↓ diye modules er moddhe switch kora jabe
4. **Fuzzy Search**: `/` chepe module search kora jabe
5. **Sundor Colors**: Command, description, usage - sob color coding kora
6. **Auto Fallback**: fzf na thakle normal text help dekhabe

---

## 📁 Files - Ki Ki Change Holo

### New Files (3 ta):
```
core/help_tui.sh      → Main TUI code (227 lines)
docs/TUI.md           → English documentation
docs/TUI_IMPLEMENTATION.md → Technical details
demo_tui.sh           → Demo/test script
```

### Modified Files (2 ta):
```
core/help.sh          → TUI auto-launch korbe
core/init.sh          → "ak tui" command add kora
```

---

## 🚀 Ki Vabe Use Korbe

### Step 1: fzf Install (First Time)
```bash
# Ubuntu/Debian
sudo apt install fzf

# Arch
sudo pacman -S fzf

# Fedora
sudo dnf install fzf
```

### Step 2: TUI Launch
```bash
ak help        # TUI ashbe (jodi fzf installed thake)
ak tui         # Direct TUI launch
ak help git    # TUI skip kore direct git help
```

### Step 3: Navigate
```
↑ / ↓       → Module select koro
Enter       → Module select koro
Esc / q     → TUI theke ber hoo
/           → Module search koro
```

---

## 🎨 Dekhte Kemon Lagbe

```
┌─────────────────────────────────────────────────────┐
│ 🚀 Aliaskit v1.0.0 - Interactive Module Browser     │
│ ─────────────────────────────────────────────────── │
│ ↑/↓ Navigate | Enter Select | Esc Quit              │
│                                                     │
│ ┌──────────────┬────────────────────────────────────┐
│ │ 📦 Modules   │ 📦 Module: git (Git Version)      │
│ │              │ ────────────────────────────────── │
│ │ ▸ navigation │                                     │
│ │   files      │   clone         Clone a repo       │
│ │   system     │   ginit         Init repo          │
│ │ ▸ process    │   gst           Git status         │
│ │   packages   │   gs            Short status       │
│ │ ▸ network    │   gl            Log graph          │
│ │   git        │   gd            Git diff           │
│ │ ▸ docker     │   gds           Staged diff        │
│ │   python     │   add           Stage changes      │
│ │   node       │   ...           ...                │
│ │   ...        │                                     │
│ └──────────────┴────────────────────────────────────┘
│                                                     │
│ 🔍 Module>                                          │
└─────────────────────────────────────────────────────┘
```

**Left side**: Module list (arrow key diye navigate)  
**Right side**: Selected module er sob command + description

---

## 💡 Example Usage

### Navigation Module:
```
..        → Go up one directory
...       → Go up two directories
~         → Go to home
-         → Previous directory
mkcd foo  → Create folder + cd into it
```

### Git Module:
```
gst       → git status
gl        → git log (beautiful graph)
gd        → git diff
gs        → git status (short)
clone     → git clone
```

### Docker Module:
```
dk        → docker shorthand
dkp       → docker ps (running containers)
dkimg     → docker images
dklogs    → docker logs
dkexec    → docker exec (shell inside container)
```

---

## 🔧 Ki Vabe Kaaj Kore

### Flow:
```
User: "ak help"
    ↓
Check: fzf installed?
    ↓
    ├─ YES → TUI launch
    │   ├─ Left: 17 modules list
    │   └─ Right: Instant preview
    │
    └─ NO → Normal text help
```

### Comment Parsing:
Module file theke ei format parse kora hoy:
```bash
## clone                    ← Command name
# @desc Clone a repo        ← Description  
# @usage clone <url>        ← Usage
# @example clone https://   ← Example
alias clone='git clone'     ← Actual alias
```

---

## 📊 17 Ta Module List

| # | Module | Category | Commands |
|---|--------|----------|----------|
| 1 | navigation | Navigation | 11 |
| 2 | files | Files & Search | 12 |
| 3 | system | System Info | 10 |
| 4 | process | Process Mgmt | 9 |
| 5 | packages | Package Mgmt | 8 |
| 6 | network | Networking | 10 |
| 7 | git | Git Version | 20+ |
| 8 | docker | Docker | 12 |
| 9 | python | Python | 8 |
| 10 | node | Node/JS | 6 |
| 11 | dotnet | .NET | 5 |
| 12 | cpp_java | C++/Java | 4 |
| 13 | archives | Archives | 6 |
| 14 | editors | Editors | 6 |
| 15 | servers | Servers | 6 |
| 16 | ssh | SSH | 7 |
| 17 | productivity | Productivity | 8 |

**Total: 174+ aliases!**

---

## 🧪 Testing/Verify

### Preview Test:
```bash
bash core/help_tui.sh _preview "git|Git Version Control"
bash core/help_tui.sh _preview "docker|Docker & Compose"
```

### Demo Run:
```bash
bash demo_tui.sh
```

### Full Integration:
```bash
source ~/.bashrc
ak help        # TUI ashbe
```

---

## 🎨 Color Scheme

| Element | Color |
|---------|-------|
| Module names | 🟦 Cyan |
| Commands | 🟩 Green |
| Descriptions | ⬜ White |
| Usage/Examples | ⬛ Dim (gray) |
| Headers | 🟨 Yellow |
| Errors | 🟥 Red |

---

## ⚠️ Important Notes

1. **fzf lagbe**: TUI use korte fzf install korte hobe
2. **Auto Fallback**: fzf na thakle normal help dekhabe
3. **Minimum Size**: Terminal 40x10 er boro hote hobe
4. **Keyboard Only**: Mouse support nei (future feature)

---

## 🚀 Quick Start

```bash
# 1. Install fzf
sudo apt install fzf

# 2. Reload terminal
source ~/.bashrc

# 3. Use TUI
ak help

# Enjoy! 🎉
```

---

## 📚 Extra Commands

```bash
ak help         # TUI (interactive)
ak tui          # Same as above
ak help git     # Direct git help (no TUI)
ak help docker  # Direct docker help
ak search logs  # Search all aliases
ak modules      # List all modules
ak update       # Update aliaskit
ak stats        # GitHub stats
```

---

## 🎯 Summary

**Ki banano holo**: Interactive TUI jo fzf use kore  
**Files changed**: 2 ta modified, 3 ta new  
**Total code**: ~230 lines clean Bash  
**Features**: Arrow navigation, instant preview, fuzzy search, colors  
**Use**: `ak help` (jodi fzf installed thake)

**Shundor, fast, and intuitive terminal help system!** 🚀
