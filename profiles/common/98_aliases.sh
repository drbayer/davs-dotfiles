#!/usr/bin/env bash
# shellcheck disable=SC2148,SC1091

os=$(get_os)

if [[ "$os" == "macos" ]]; then
    alias en='Cg=='
    alias flushdns='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
    alias grepv='grep -v '\''^$'\'' | grep -v '\''^#'\'''
    alias ls='ls -G'
    alias powershell='pwsh'
fi

if [[ "$os" == "linux" ]]; then
    alias ls='ls --color'
fi

# Java
alias java6='export JAVA_HOME=`/usr/libexec/java_home -v1.6` && java -version'
alias java7='export JAVA_HOME=`/usr/libexec/java_home -v1.7` && java -version'
alias java8='export JAVA_HOME=`/usr/libexec/java_home -v1.8` && java -version'

# Git
alias repo='cd ${GIT_REPO_DIR}'
alias gcommit='gitCommit'
alias gmerge='gitMerge'

# Python
alias python='python3'
alias pip='pip3'

# Kubernetes
alias kubens='kubectl config set-context --current --namespace '    # set current namespace
