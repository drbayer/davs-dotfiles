#!/usr/bin/env bash

gconfig() {

    # Print the active gcloud configuration
    current() {
        if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
            echo "Usage: gconfig current"
            echo
            echo "Print the currently active gcloud configuration name"
            return
        fi
        gcloud config configurations list | awk '/True/ {print $1}'
    }

    # Change to a different gcloud configuration
    switch() {
        if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
            echo "Usage: gconfig switch [CONFIG]"
            echo
            echo "Switch to the specified config. If no config is specified,"
            echo "select from the list of available configurations."
            return
        fi
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
        if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
            echo "Usage: gconfig list"
            echo
            echo "List available gcloud configurations."
            return
        fi
        gcloud config configurations list --format json | jq -r '.[] | .name'
    }

    # Describe a gcloud configuration
    describe() {
        if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
            echo "Usage: gconfig describe [CONFIG]"
            echo
            echo "Describe the specified configuration. If no config is"
            echo "specified, describe the current config."
            return
        fi
        local this_env=$1
        if [[ -z this_env ]]; then
            this_env=$(current)
        fi
        gcloud config configurations describe $this_env
    }

    # Print this help message
    help() {
        local this_file=$(find "$HOME" -name gconfig.sh -type f -print -quit)
        local funcs=$(awk -F\( '/^[  ]+[a-z]+\(\)/ {gsub("[  ]+", ""); print $1}' "$this_file")
        if [[ "$funcs" =~ "$1" ]]; then
            $1 -h
            return
        fi
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
