#!/usr/bin/env bash
# shellcheck disable=SC2148
# Set up ssh-agent and ssh keys. If more than 5 keys found
# you will see a warning and be asked which keys to load.

# Set the following variable to the keys you want to load
# in order to avoid warnings or manual acceptance.
SSH_KEYS_TO_LOAD="$(get_safe_value SSH_KEYS_TO_LOAD)"
SSH_KEYS_TO_LOAD="$SSH_KEYS_TO_LOAD dbayer-github davids-desktop"

find_keys() {
    local keys=
    local all_keys=

    all_keys=$(find ~/.ssh -maxdepth 1 -name "*.pub" | sed -e 's/.pub//')

    if [[ -z ${SSH_KEYS_TO_LOAD+x} ]]; then
        keys="$all_keys"
    else
        for key in $all_keys; do
            for listed_key in $SSH_KEYS_TO_LOAD; do
                if [[ $key =~ $listed_key ]]; then
                    keys="$keys $key"
                fi
            done
        done
    fi
    echo "$keys"
}

select_keys() {
    local key_list="$1"
    local keys=
    for key in $key_list; do
        read -rp "Add to keychain? [yN]  $key " add_key
        if [[ ${add_key:0:1} =~ [Yy] ]]; then
            keys="$keys $key"
        fi
    done
    echo "$keys"
}

if [[ -z "$(which keychain)" ]]; then
    install keychain
fi

if [[ -x "$(which keychain)" ]]; then
    unset ssh_keys
    ssh_keys="$(find_keys)"
    ssh_key_count=$(echo "$ssh_keys" | wc -l)
    if [[ $ssh_key_count -gt 5 ]]; then
        warn "Loading more than 5 SSH keys. This may lead to unexpected behavior during SSH authentication."
        warn "Add all of the following keys? [yN]\n$ssh_keys"
        read -r answer
        if [[ ! ${answer:0:1} =~ [Yy] ]]; then
            ssh_keys="$(select_keys \""$ssh_keys"\")"
        fi
    fi

    # shellcheck disable=SC2086
    keychain $ssh_keys
    # shellcheck disable=SC2046
    . ~/.keychain/$(hostname)-sh

fi
