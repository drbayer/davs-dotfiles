#!/usr/bin/env bash
# shellcheck disable=SC1091

current_profile="${HOME}/.bash.d/profiles/active"

if [[ -d "$current_profile/helpers/install" ]]; then
    for req in "$current_profile"/helpers/install/*requirements.txt; do
        pip install -qq -U -r "$req"
    done
fi

if [[ -f "$current_profile/helpers/utils.sh" ]]; then
    source "$current_profile/helpers/utils.sh"
fi

if [[ -f "$current_profile/helpers/k8s_utils.sh" ]]; then
    source "$current_profile/helpers/k8s_utils.sh"
fi

if [[ -f "$current_profile/helpers/jira_todoist.py" ]]; then
    "$current_profile/helpers/jira_todoist.py"
fi

