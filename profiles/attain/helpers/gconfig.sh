#!/usr/bin/env bash

gconfig() {

    # Print the active gcloud configuration
    current() {
        echo "$1"
        if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
            echo "Print the currently active gcloud configuration name"
            exit
        fi
        gcloud config configurations list | awk '/True/ {print $1}'
    }

    # Change to a different gcloud configuration
    switch() {
        local new_env=$1
        if [[ -z $new_env ]]; then
            echo "Available configurations:"
            list
            read -p "Select configuration to switch to: " new_env
        fi
        gcloud config configurations activate $new_env
    }

    # List available gcloud configurations
    list() {
        gcloud config configurations list --format json | jq -r '.[] | .name'
    }

    # Describe a gcloud configuration
    describe() {
        local this_env=$1
        if [[ -z this_env ]]; then
            this_env=$(current)
        fi
        gcloud config configurations describe $this_env
    }

    # Print this help message
    help() {
        local this_file=$(find "$HOME" -name gconfig.sh -type f -print -quit)
        funcs=$(awk -F\( '/^[  ]+[a-z]+\(\)/ {gsub("[  ]+", ""); print $1}' "$this_file")
        echo "Usage: gconfig COMMAND [FLAGS]"
        echo
        echo "Manage gcloud configurations."
        echo "To get more help on a specific command use 'gconfig COMMAND -h'."
        echo
        echo "Available commands:"
        for func in $funcs; do
            egrep -B1 "^\s+${func}\(\)" "$this_file" | awk -v f=$func '/#/ {gsub("^[  ]+# ", ""); printf "    %-12s%s\n", f, $0}'
        done
    }


    case $1 in
        current)    current $2
                    ;;
        switch)     switch $2
                    ;;
        list)       list $2
                    ;;
        describe)   describe $2
                    ;;
        *)          help
                    ;;
    esac
}
