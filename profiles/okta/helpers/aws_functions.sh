#!/usr/bin/env bash
aws_set_profile() {
    local profile=$1
    local profile_list

    profile_list=$(aws_get_profiles)
    if [[ -z "$profile" ]]; then
        echo "Missing AWS profile. Select from the following:"
        echo "$profile_list"
        echo
        read -r -p "Enter profile: " profile
        echo
    fi
    if ! echo "$profile_list" | grep -q "^$profile$"; then
        echo "Invalid AWS profile \"$profile\" selected. Available profiles:"
        echo "$profile_list"
        echo
        echo "AWS profile not set."
        return 1
    fi
    echo "Setting AWS_PROFILE to $profile"
    export AWS_PROFILE="$profile"
}

aws_get_profiles() {
    # shellcheck disable=SC2016
    awk '/profile/ {gsub("]",""); print $NF}' ~/.aws/config |
        sort
}
