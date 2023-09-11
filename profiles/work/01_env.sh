#!/usr/bin/env bash
# env vars

export DOTFILES_PROFILE=work

export LI_FABRICS='prod-lor1 prod-ltx1 prod-lva1'
export VOYAGER_SRE=$(get_safe_value TEAM_MEMBERS)
export JAVA_VERSION='11.0'
export GIT_REPO_DIR=${HOME}/repos

setJava $JAVA_VERSION
export GITHUB_SSH_COMMAND='ssh -i ~/.ssh/github-drbayer'
