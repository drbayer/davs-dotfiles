#!/bin/bash

#################################################
## Function List
## add-function-list()
#################################################

add-function-list() {
    usage() {
        echo "get-function-list -s SCRIPT [-h]"
        echo "    -s    Path to script to add info to"
        echo "    -h    Show this help message"
        echo
        echo "Searches SCRIPT for functions and updates the following function list block"
        echo "with the list: "
        echo "#################################################"
        echo "## Function List"
        echo "#################################################"
        echo
        return 1
    }

    local myscript=
    local retval=0
    local OPTIND FLAG s
    while getopts :hs: FLAG; do
        case $FLAG in
            s)  myscript=$OPTARG
                ;;
            h)  usage
                retval=$?
                ;;
            \?) echo "Unknown parameter: -$OPTARG"
                retval=1
                return 1
                ;;
        esac
    done
    if [[ $retval -eq 0 ]]; then
        if [[ -z $myscript ]]; then
            echo "Missing -s script parameter."
            usage
            retval=$?
        elif [[ ! -f $myscript ]]; then
            echo "File not found: $myscript"
            retval=2
        elif [[ $(grep '^## Function List' $myscript | wc -l) -eq 0 ]]; then
            echo "Function List not found. Not updating list."
            retval=3
        fi
    fi
    
    if [[ $retval -eq 0 ]]; then
        local continue
        func_list=$(awk '/^[A-Za-z0-9\-_]+\(\)/ {print $1}' $myscript | sort)
        last_func="## Function List"
        echo "The following functions found in $myscript:"
        echo "$func_list"
        read -p "Continue? [yn]" continue
        if [[ $(echo "$continue" | tr '[:upper:]' '[:lower:]') == "y" ]]; then
            for func in $func_list; do
                func="## $func"
                sed -i '' -e "s/^$last_func/$last_func"'\
'"$func/" $myscript
                last_func=$func
            done
        else
            echo "Aborted on user command.  No changes made to $myscript."
        fi
    fi
    
    return $retval
}
