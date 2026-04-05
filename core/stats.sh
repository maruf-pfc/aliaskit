#!/usr/bin/env bash

# core/stats.sh - Fetch and display GitHub marketing stats

function print_color() {
    local color="$1"
    local text="$2"
    case "$color" in
        "blue") echo -e "\033[34m${text}\033[0m" ;;
        "green") echo -e "\033[32m${text}\033[0m" ;;
        "yellow") echo -e "\033[33m${text}\033[0m" ;;
        "cyan") echo -e "\033[36m${text}\033[0m" ;;
        "bold") echo -e "\033[1m${text}\033[0m" ;;
        *) echo "$text" ;;
    esac
}

REPO="blackstart-labs/aliaskit" # the user's Github repo

print_color "cyan" "📊 Aliaskit Community Stats"
echo "Fetching live data from GitHub ($REPO)..."
echo "---------------------------------------------------"

# We use curl and standard tools to parse JSON lightly
RESPONSE=$(curl -s "https://api.github.com/repos/$REPO")

if [[ "$RESPONSE" == *"Not Found"* ]] || [[ -z "$RESPONSE" ]]; then
    echo "Could not fetch stats. Maybe the repository $REPO is not public yet."
    exit 0
fi

# Extract stats using grep and sed to avoid needing jq
STARS=$(echo "$RESPONSE" | grep -m 1 '"stargazers_count":' | sed -E 's/.*"stargazers_count": ([0-9]+).*/\1/')
FORKS=$(echo "$RESPONSE" | grep -m 1 '"forks_count":' | sed -E 's/.*"forks_count": ([0-9]+).*/\1/')
WATCHERS=$(echo "$RESPONSE" | grep -m 1 '"subscribers_count":' | sed -E 's/.*"subscribers_count": ([0-9]+).*/\1/')

print_color "yellow" "⭐ GitHub Stars : $STARS"
print_color "blue"   "🚀 Forks        : $FORKS"
print_color "green"  "👀 Watchers     : $WATCHERS"
echo ""
print_color "bold" "Join the users supercharging their terminal!"
print_color "cyan" "URL: https://github.com/$REPO"
