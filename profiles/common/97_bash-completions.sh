#!/usr/bin/env bash

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

kubectl="$(dirname ${BASH_SOURCE})/helpers/kubectl.sh"
if [ -f  "$kubectl" ]; then
    echo "Sourcing $kubectl"
    source "$kubectl"
fi

if [[ -d /opt/homebrew/etc/bash_completion.d ]]; then
    for completion in /opt/homebrew/etc/bash_completion.d/*; do
        source $completion
    done
fi
