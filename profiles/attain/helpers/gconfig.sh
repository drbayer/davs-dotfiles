#!/usr/bin/env bash

gconfig() {

    current() {
        gcloud config configurations list | awk '/True/ {print $1}'
    }

    switch() {
        local new_env=$1
        if [[ -z $new_env ]]; then
            echo "Available configurations:"
            list
            read -p "Select configuration to switch to: " new_env
        fi
        gcloud config configurations activate $new_env
    }

    list() {
        gcloud config configurations list --format json | jq -r '.[] | .name'
    }


    case $1 in
        current)    current
                    ;;
        switch)     switch $2
                    ;;
        list)       list
                    ;;
        *)          echo "Nothing to see here."
                    ;;
    esac
}
