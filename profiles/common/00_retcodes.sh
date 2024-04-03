#!/usr/bin/env bash

. "${DOTFILES_BASEDIR}/profiles/common/00_utils.sh"

get_retcode() {
    local status=$1

    if [[ -z $status ]]; then
        echo 0
        return
    fi

    local -A CODES
    local states=(
        GOOD
        FILE_NOT_FOUND
        PARAMETER_NOT_PROVIDED
    )

    i=0
    for state in "${states[@]}"; do
        CODES[${state}]=$i
        i=$((i+1))
    done

    if [[ ${CODES[${status}]+1} ]]; then
        echo "${CODES[${status}]}"
    else
        warn "Return code $status not defined!"
    fi
}
