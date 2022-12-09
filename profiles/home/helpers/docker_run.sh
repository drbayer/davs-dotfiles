#!/usr/bin/env bash

cmd=$1
shift

command="docker run --rm -v ${HOME}/.aws:/root/.aws -v ${HOME}/.ssh:/root/.ssh"
case $cmd in 
    k8s) 
        env | grep AWS > env_vars.txt
        command="$command --env-file env_vars.txt -w /app -v $(pwd):/app -it kops-deploy:alpine"
        ;;
    nginx)
        command="$command -v $(pwd):/usr/share/nginx/html:ro -d -p 8080:80 nginx:alpine"
        ;;
    *)
        echo "Missing command parameter"
        return 1
esac

$command $@

