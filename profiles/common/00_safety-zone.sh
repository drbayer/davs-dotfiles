#!/usr/bin/env bash
# shellcheck disable=SC2046,SC1091
echo "TESTING: $(whoami)"
. "${DOTFILES_BASEDIR}/profiles/common/00_utils.sh"
. "${DOTFILES_BASEDIR}/profiles/common/00_retcodes.sh"

values_file="${DOTFILES_BASEDIR}/safety-zone/safety-zone_values.ini"

get_safe_value() {
    local key="$1"

    if ! values_file_exists; then
        warn "Unable to locate safety-zone values file: $values_file"
        return $(get_retcode FILE_NOT_FOUND)
    elif [[ -z $key ]]; then
        warn "Key to search for not provided"
        return $(get_retcode PARAMETER_NOT_PROVIDED)
    else
        echo $(eval $(awk -F= -v key="$key" '{if ( $1 == key) { print $2; exit }}' "$values_file"))
    fi
}

set_safe_value() {
    local key="$1"
    local value="$2"

    create_safe_values_file
    existing_value="$(get_safe_value "$key")"
    if [[ -z "$existing_value" ]]; then
        echo "$key=$value" >> "$values_file"
    else
        read -rp "Existing value '$existing_value' present for $key. Replace it? [yN] " REPLACE
        if [[ ${REPLACE:0:1} =~ [Yy] ]]; then
            sed -i '' -e "s/^\($key=\).*/\1$value/g" "$values_file"
        else
            warn "Not changing safety-zone value at user request."
        fi
    fi
}

create_safe_values_file() {
    if ! values_file_exists; then
        touch "$values_file"
        echo "[general]" >> "$values_file"
    fi
}

values_file_exists() {
    if [[ -f "$values_file" ]]; then
        return 0
    else
        return $(get_retcode FILE_NOT_FOUND)
    fi
}
