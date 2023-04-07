#!/usr/bin/env bash

run_xbar_plugin() {
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

