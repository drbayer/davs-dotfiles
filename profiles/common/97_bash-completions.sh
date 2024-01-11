#!/usr/bin/env bash
#shellcheck disable=SC1091,SC2128,SC1090

if [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]; then
    . "/usr/local/etc/profile.d/bash_completion.sh"
fi

if [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]]; then
    . "/opt/homebrew/etc/profile.d/bash_completion.sh"
fi

kube_ctl="$(dirname "${BASH_SOURCE}")/helpers/kubectl.sh"
if [ -f  "$kube_ctl" ]; then
    echo "Sourcing $kube_ctl"
    source "$kube_ctl"
fi

if [[ -d /opt/homebrew/etc/bash_completion.d ]]; then
    for completion in /opt/homebrew/etc/bash_completion.d/*; do
        source "$completion"
    done
fi
