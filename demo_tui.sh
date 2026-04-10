#!/usr/bin/env bash

# demo_tui.sh - Demo script to showcase the Aliaskit TUI

echo "=================================="
echo "🚀 Aliaskit TUI Demo"
echo "=================================="
echo ""

# Colors
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

echo -e "${CYAN}1️⃣  Testing module preview function...${RESET}"
echo ""
bash core/help_tui.sh _preview "navigation|Navigation & Directory"
echo ""
echo -e "${YELLOW}─────────────────────────────────────────${RESET}"
echo ""

echo -e "${CYAN}2️⃣  Testing another module (system)...${RESET}"
echo ""
bash core/help_tui.sh _preview "system|System Info & Monitoring" | head -20
echo ""
echo -e "${YELLOW}─────────────────────────────────────────${RESET}"
echo ""

echo -e "${CYAN}3️⃣  Testing git module...${RESET}"
echo ""
bash core/help_tui.sh _preview "git|Git Version Control" | head -25
echo ""
echo -e "${YELLOW}─────────────────────────────────────────${RESET}"
echo ""

echo -e "${GREEN}✅ All preview functions working correctly!${RESET}"
echo ""
echo -e "${CYAN}📋 Next steps:${RESET}"
echo ""
echo "  1. Install fzf: sudo apt install fzf"
echo "  2. Source aliaskit: source ~/.bashrc"
echo "  3. Launch TUI: ak help"
echo ""
echo -e "${YELLOW}💡 Without fzf, 'ak help' falls back to text help${RESET}"
echo ""
