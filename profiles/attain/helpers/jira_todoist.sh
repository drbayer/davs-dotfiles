#!/usr/bin/env bash

. "$DOTFILES_BASEDIR/profiles/active/helpers/python_venv.sh"
activate_venv jira_todoist
python3 "$DOTFILES_BASEDIR/profiles/active/helpers/jira_todoist.py"
deactivate
