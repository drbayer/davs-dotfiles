#!/usr/bin/env bash
# shellcheck disable=SC3010

new_profile() {
  local new_profile="$1"

  if [[ -z "$new_profile" ]]; then
    echo "Missing new profile name" 1>&2
  else
    if [[ -d "${DOTFILES_BASEDIR}/profiles/${new_profile}" ]]; then
      echo "Profile ${new_profile} already exists" 1>&2
    else
      echo "Creating new profile directory"
      mkdir "${DOTFILES_BASEDIR}/profiles/${new_profile}"
    fi
  fi
}

select_profile() {
    local output_profile="$1"

    declare -a profiles
    for p in $(ls "${DOTFILES_BASEDIR}/profiles" | egrep -v 'common|active'); do
        if [[ -d "${DOTFILES_BASEDIR}/profiles/${p}" ]]; then
            profiles+=("$p")
        fi
    done

    echo "Select new profile from the following:" >&2
    for i in $(seq 0 $((${#profiles[*]}-1))); do
      echo "$i) ${profiles[i]}" >&2
    done
    echo "n) Create new profile" >&2
    echo "x) Exit without changing profile" >&2
    read -r profile_num
    if [[ "$profile_num" == "x" ]]; then
      selected_profile=abort
    elif [[ "$profile_num" == "n" ]]; then
      read -rp "Enter new profile name: " selected_profile >&2
      new_profile $selected_profile
    else
      selected_profile="${profiles[$profile_num]}"
    fi
    if [[ "$output_profile" == "true" ]]; then
        echo "$selected_profile"
    fi
}

switch_profile() {
  local selected_profile="$1"

  if [[ -z "$selected_profile" ]]; then
      selected_profile=$(select_profile true)
  fi

  if [[ ! -z "$selected_profile" ]] && [[ -d "${DOTFILES_BASEDIR}/profiles/${selected_profile}" ]]; then
    echo "Switching to profile ${selected_profile}"
    if [[ -e "${DOTFILES_BASEDIR}/profiles/active" ]]; then
      unlink "${DOTFILES_BASEDIR}/profiles/active"
    fi
    ln -s "${DOTFILES_BASEDIR}/profiles/${selected_profile}" "${DOTFILES_BASEDIR}/profiles/active"
  else
    echo "Exiting without changing profile"
  fi
}
