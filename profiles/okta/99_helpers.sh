#!/usr/bin/env bash

for file in "${DOTFILES_BASEDIR}"/profiles/okta/helpers/*.sh; do
    # shellcheck disable=SC1090
    . "$file"
done
