#!/usr/bin/env bash

scriptfile="${DOTFILES_BASEDIR}/profiles/active/helpers/jira_todoist.sh"

if [[ -f "$scriptfile" ]]; then
    "$scriptfile"
fi
