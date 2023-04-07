#!/usr/bin/env bash

# source this script to enable the run_xbar_plugin function
# function expects the xbar_env.py file to be in the same directory as the function script

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

    SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

    export_vars=$(python "$SCRIPT_DIR"/xbar_env.py "$PLUGIN")
    eval $export_vars

    PLUGIN_SCRIPT=$(ls "$DIR"/*"$PLUGIN"*.py)
    python "$PLUGIN_SCRIPT"
}

