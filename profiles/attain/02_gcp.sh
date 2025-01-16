#!/usr/bin/env bash

source "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"
source "$(brew --prefix)/etc/bash_completion.d/google-cloud-sdk"

source "$DOTFILES_BASEDIR/profiles/active/helpers/gconfig.sh"

alias gcurl='curl -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json"'
