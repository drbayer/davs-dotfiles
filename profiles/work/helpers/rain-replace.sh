#!/usr/bin/env bash

usage() {
    echo "Usage: ${0##*/} -f FABRIC -s SLICE -H HOSTS"
    echo
    echo "This will replace all specified instances of an application slice. All instances"
    echo "will be deleted at the same time, so be sure that your service can handle a temporary"
    echo "reduction in capacity while the new instances are created."
    echo
    echo "    -f FABRIC   The fabric where the instance needs to be replaced"
    echo "    -H HOSTS    Comma separated list of hosts to be replaced"
    echo "    -s SLICE    The slice ID of the slice being replaced"
    echo
    exit 5
}

confirm() {
    message="$1"
    local answer=n

    read -r -p "$message [y|n] " answer
    answer=$(echo "${answer:0:1}" | tr '[:upper:]' '[:lower:]')
    echo "$answer"
}

validate_fabric() {
    local fabrics="prod-lor1 prod-ltx1 prod-lva1"
    # shellcheck disable=SC2076
    if [[ "$fabrics" =~ "$FABRIC" ]]; then
        echo > /dev/null
    else
        echo "Missing or invalid fabric"
        echo
        usage
    fi
}

validate_hosts() {
    HOSTCOUNT=$(echo "$HOSTS" | tr ',' ' ' | wc -w | tr -d '[:space:]')
    if [[ $HOSTCOUNT -eq 0 ]]; then
        echo "Missing host list to be replaced"
        echo
        usage
    fi
    local host
    local host_list
    host_list=$(go-status -f "$FABRIC" --slice "$SLICE" --show-host-list)
    for host in $(echo "$HOSTS" | tr ',' ' '); do
        # shellcheck disable=SC2076
        if [[ "$host_list" =~ "$host" ]]; then
            echo > /dev/null
        else
            echo "Host $host is not running slice $SLICE in fabric $FABRIC"
            echo
            usage
        fi
    done
}

validate_slice() {
    if (rain slice show "$SLICE" &> /dev/null); then
        echo > /dev/null
    else
        echo "Missing or invalid slice ID"
        echo
        usage
    fi
}


FABRIC=
HOSTS=
SLICE=
HOSTCOUNT=0

while getopts :f:H:s:h FLAG; do
    case $FLAG in
        f)  FABRIC=$OPTARG
            ;;
        H)  HOSTS=$OPTARG
            ;;
        s)  SLICE=$OPTARG
            ;;
        *)  usage
            ;;
    esac
done

validate_fabric
validate_slice
validate_hosts

echo "WARNING: All $HOSTCOUNT hosts will be removed at the same time. Be sure this will not cause capacity issues for your service!"
do_it=$(confirm "Are you sure you want to replace $HOSTCOUNT instances of slice $SLICE in $FABRIC?")
echo
if [[ "$do_it" == "y" ]]; then
    echo "Creating $HOSTCOUNT new instancees of slice $SLICE in $FABRIC"
    rain instance create -f "$FABRIC" --count "$HOSTCOUNT" "$SLICE"
    echo "Deleting $HOSTCOUNT instances of slice $SLICE in $FABRIC"
    rain instance delete -f "$FABRIC" --hosts "$HOSTS" "$SLICE"
else
    echo "Action aborted by user"
fi
