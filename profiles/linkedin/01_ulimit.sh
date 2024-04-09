#!/usr/bin/env bash
# shellcheck disable=SC2148

# update macOS open file limit
# sadly, this will require user input of sudo pw if plist does not already exist

os=$(get_os)

plist="limit.maxfiles.plist"
if ! [[ -f "/Library/LaunchDaemons/$plist" ]] && [[ "$os" == 'macos' ]]; then
    echo "Setting up limit.maxfiles.plist. This may require you to enter your admin password."
    sudo cp "${DOTFILES_DIR}/profiles/active/helpers/$plist" /Library/LaunchDaemons/
    sudo chown root:wheel "/Library/LaunchDaemons/$plist"
    sudo launchctl load -w "/Library/LaunchDaemons/$plist"
fi

openfiles=16384

if [[ $(ulimit -n) -lt $openfiles ]]; then
    ulimit -S -n $openfiles
fi
