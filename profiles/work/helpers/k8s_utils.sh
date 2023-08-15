#!/usr/bin/env bash


# source this file to more easily work with k8s resources

PIDFILE=/tmp/prodpid

k8s_login() {
    fabric=${1:-prod-lor1}
    cluster=${2:-k8s-0}

    echo $cluster && exit

    kubectl login -f $fabric -t $cluster
    sshuttle --daemon --pidfile $PIDFILE -r ltx1-shell07.prod.linkedin.com:22 \
        k8s-{0,1,hub}.apiserver.prod-lor1.atd.prod.linkedin.com \
        k8s-{0,1,hub}.apiserver.prod-ltx1.atd.prod.linkedin.com \
        k8s-{0,1,hub}.apiserver.prod-lva1.atd.prod.linkedin.com
}

k8s_logout() {
    if [[ -f $PIDFILE ]]; then
        PID=$(<$PIDFILE)
        kill $PID
    fi
}
