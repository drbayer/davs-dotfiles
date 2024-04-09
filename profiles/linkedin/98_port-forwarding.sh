# shellcheck disable=SC2148

oc4_proxy_list="tunnel-mysql tunnel-oc4"

start_proxy() {
    proxy="$1"
    ssh -fN "$proxy"
}

stop_proxy() {
    proxy="$1"
    ssh -O exit "$proxy" > /dev/null 2>&1
}

check_proxy() {
    proxy="$1"
    ssh -O check "$proxy" > /dev/null  2>&1
    return $?
}

oc4_proxy_on() {
    for proxy in $oc4_proxy_list; do
        echo "Starting port forwarding for $proxy"
        start_proxy "$proxy"
    done
}

oc4_proxy_check() {
    for proxy in $oc4_proxy_list; do
        if [[ $(check_proxy "$proxy") ]]; then
            echo "Port forwarding for $proxy is running"
        else
            echo "Port forwarding for $proxy is not running"
        fi
    done
}

oc4_proxy_off() {
    for proxy in $oc4_proxy_list; do
        if [[ $(check_proxy "$proxy") ]]; then
            echo "Stopping port forwarding for $proxy"
            stop_proxy "$proxy"
        fi
    done
}

