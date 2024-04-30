#!/usr/bin/env bash

VENV_DIR="${HOME}/.python/virtualenvs"

list_venvs() {
    find "$VENV_DIR" -type d -depth 1 | xargs -I {} basename {}
}

activate_venv() {
    local venv=$1
    local all_venvs=$(list_venvs)
    if [[ -z $venv ]]; then
        echo "Select from the following python virtualenvs: "
        $all_venvs
        read venv
    fi
    for v in $all_venvs; do
        if [[ $v == $venv ]]; then
            . "$VENV_DIR/$venv/bin/activate"
            break
        fi
    done
}

new_venv() {
    local venv=$1
    if [[ -z $venv ]]; then
        echo "Missing virtual env name."
        return 1
    fi
    for v in $(list_venvs); do
        if [[ $v == $venv ]]; then
            echo "Virtual env $venv already exists."
            return 1
        fi
    done
    python3 -m venv "$VENV_DIR/$venv"
}

run_in_venv() {
    local script=$1
    if [[ -z $script ]]; then
        echo "Missing script name."
        return 1
    fi
}
