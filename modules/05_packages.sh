#!/usr/bin/env bash
# CATEGORY: Package Management (APT)
# MODULE: packages

## update
# @desc  Refresh package lists from all repositories (and check aliaskit updates)
# @usage update
# @example update
alias update='sudo apt update'

## upgrade
# @desc  Update package lists and upgrade all installed packages
# @usage upgrade
# @example upgrade
alias upgrade='sudo apt update && sudo apt upgrade -y'

## full-upgrade
# @desc  Full system upgrade including dependency resolution, then clean up
# @usage full-upgrade
# @example full-upgrade
alias full-upgrade='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean'

## install
# @desc  Install a package (apt, non-interactive)
# @usage install <package>
# @example install curl
alias install='sudo apt install -y'

## remove
# @desc  Remove a package (keep config files)
# @usage remove <package>
# @example remove vim
alias remove='sudo apt remove -y'

## purge
# @desc  Completely remove a package including its config files
# @usage purge <package>
# @example purge nginx
alias purge='sudo apt purge -y'

## autoremove
# @desc  Remove unused dependency packages
# @usage autoremove
# @example autoremove
alias autoremove='sudo apt autoremove -y'

## search
# @desc  Search for a package by name or keyword
# @usage search <term>
# @example search python3
alias search='apt search'

## show
# @desc  Show details about a package
# @usage show <package>
# @example show nginx
alias show='apt show'

## pkglist
# @desc  List all installed packages
# @usage pkglist
# @example pkglist
alias pkglist='apt list --installed 2>/dev/null'