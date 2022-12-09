#!/usr/bin/env bash
# shellcheck disable=SC2148,SC1091

# Google Cloud
alias gca='gcloud config configurations activate'

# Ansible
alias ap='time ansible-playbook'

# Java
alias java6='export JAVA_HOME=`/usr/libexec/java_home -v1.6` && java -version'
alias java7='export JAVA_HOME=`/usr/libexec/java_home -v1.7` && java -version'
alias java8='export JAVA_HOME=`/usr/libexec/java_home -v1.8` && java -version'

# Hashicorp
alias tf='terraform'
alias vdu='vagrant destroy -f && vagrant up'
alias pb='time packer_build'

# Chef
alias kl='kitchen list'
alias kli='kitchen login'
alias kd='kitchen destroy'
alias kv='kitchen verify'
alias kcu='knife cookbook upload'
alias kns='knife node show'
alias ksn='knife search node'
alias kssh='knife ssh'

