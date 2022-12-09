#!/bin/bash

lastpass_login() {
    lpass status -q
    if [[ $? -eq 1 ]]; then
        lpass login drbayer@eternalstench.com
    fi
}

lastpass_ldap_pw() {
    lastpass_login

    lpass show --sync=auto 'Linux LDAP Account' --password --format="%ap"
}

# Copy the desired password to the clipboard
lastpass_get_pw() {
    lastpass_login

    filter=$1
    fail=0

    i=0
    while read line; do
        i=$((i + 1))
        if [[ $i -gt 1 ]]; then
            echo "Lastpass returned more than 1 site. Refine your search criteria."
            fail=1
        else
            pw=$(echo "$line" | awk '{gsub("]",""); print $NF}' | xargs lpass show --password)
        fi
    done <<< "$(lpass ls | grep "$filter")"

    if [[ "$fail" -ne "0" ]]; then
        return $fail
    else
        echo $pw
    fi
}
