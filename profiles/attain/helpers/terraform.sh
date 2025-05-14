#!/usr/bin/env bash

set_tf_version() {
    tf_version="1.7.3"
    git_root=$(git rev-parse --show-toplevel 2> /dev/null)
    if [[ -n $git_root ]]; then
        repo=$(awk '/url/ {print $NF}' "$git_root/.git/config")
        if [[ "$repo" ==  "git@gitlab.com:kloverhq/terraform/sre-infrastructure.git" ]]; then
            current_path=$(pwd)
            tf_version=$(awk -v path="${current_path#$git_root/}$" '$0 ~ path {print_next_line = 1; next} print_next_line == 1 {print_next_line=0; gsub("v", ""); print $2}' "$git_root/atlantis.yaml")
        fi
    fi
    tfenv use $tf_version
}
