#!/usr/bin/env bash

# source this script to enable the xbar functions

list_xbar_plugins() {
    # Find all installed xbar plugins

    if [[ -z $2 ]]; then
        DIR="${HOME}/Library/Application Support/xbar/plugins"
    else
        DIR="$2"
    fi

    for f in "${DIR}"/*.py; do
        # remove extension and timing from filename
        f="${f%%.*}"
        # remove leading digits for community plugins
        f="${f##[0-9]*-}"
        basename "$f"
    done
}


# this function expects the xbar_env.py file to be in the same directory as the function script
run_xbar_plugin() {
    # Run xbar plugins from the command line more easily. Loads config values into ENV vars
    # for xbar plugin configs
    #
    # Usage: run_xbar_plugin PLUGIN_NAME
    # example: run_xbar_plugin gcn3
    
    if [[ -z $1 ]]; then
        echo "Missing plugin name"
        return
    else
        PLUGIN="$1"
    fi

    if [[ -z $2 ]]; then
        DIR="${HOME}/Library/Application Support/xbar/plugins"
    else
        DIR="$2"
    fi

    if ! command -v jq &> /dev/null; then
        echo "Unable to locate 'jq' command. Install before continuing."
        return 1
    fi

    export_vars=$(jq -r 'to_entries | map("export \(.key)=\(.value|tostring)") | .[]' "$DIR"/*"$PLUGIN"*.py.vars.json)
    #shellcheck disable=SC2086
    eval $export_vars 

    PLUGIN_SCRIPT=$(ls "$DIR"/*"$PLUGIN"*.py)
    python "$PLUGIN_SCRIPT"
}

