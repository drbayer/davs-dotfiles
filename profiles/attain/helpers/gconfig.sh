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

    describe() {
        local this_env=$1
        if [[ -z this_env ]]; then
            this_env=$(current)
        fi
        gcloud config configurations describe $this_env
    }

    help() {
        local f=$(basename "$0")
        echo $f
    }


    case $1 in
        current)    current
                    ;;
        switch)     switch $2
                    ;;
        list)       list
                    ;;
        describe)   describe $2
                    ;;
        *)          help
                    ;;
    esac
}
