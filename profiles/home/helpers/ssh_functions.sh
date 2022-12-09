#!/bin/bash

function ssh_add_keys() {
    for key in $(grep 'BEGIN RSA PRIVATE KEY' ~/.ssh/* | awk -F':' '{print $1}'); do #ls ~/.ssh | egrep -v 'known_hosts|config|\..*'); do
        if [[ ! $(ssh-add -l | egrep "$key") ]]; then 
            ssh-add -K ${key}
        fi
    done
}

function ssh_remove_keys() {
    ssh-add -D
}

