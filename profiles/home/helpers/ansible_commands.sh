#!/bin/bash

# disable this for now - a bug in ansible 2.5 causes all things
# to fail when callbacks are specified ¯\_(ツ)_/¯
# export ANSIBLE_CALLBACK_WHITELIST=timer,mail,profile_tasks
alias ap='time ansible-playbook'

function apl() {
    arglist=""
    whitespace="[[:space:]]"
    for i in "$@"; do
        if [[ $i =~ $whitespace ]]; then
            i=\'$i\'
        fi
        arglist="$arglist $i"
    done
    cmd="time ansible-playbook $arglist"
    eval "$cmd" 2>&1 | tee ansible-$(date "+%Y%m%d-%H%M%S").log
}
