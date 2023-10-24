# shellcheck disable=SC2148,SC2157

get_safe_value() {
    key=$1

    values_file="${DOTFILES_BASEDIR}/safety-zone/safety-zone_values.ini"

    if [[ ! -f "$values_file" ]] || [[ -z key ]]; then
        source "${DOTFILES_BASEDIR}/profiles/common/00_utils.sh"
        warn "Unable to locate safety-zone values file: $values_file" 1>&2
        return
    else
        awk -F= -v key="$key" '{if ( $1 == key) { print $2; exit }}' "$values_file"
    fi
}

