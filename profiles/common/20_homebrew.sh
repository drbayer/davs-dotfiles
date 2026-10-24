# shellcheck disable=SC2086,SC3010

# Certain utility functions including get_retcode and warn
# found in 00_utils.sh

brew() {
    # Utility function to capture installed packages
    local cmd=$1 action arg
    local -a pkgs=()
    local homebrew=/opt/homebrew/bin/brew
    local installs_dir="$DOTFILES_BASEDIR/profiles/active/homebrew"
    local installs_file="$installs_dir/Brewfile"

    if [[ ! -x "$homebrew" ]]; then
        warn "brew command not found. Install at https://brew.sh"
        return "$(get_retcode FILE_NOT_FOUND)"
    fi

    if [[ ! -d "$installs_dir" ]]; then
        mkdir "$installs_dir"
    fi

    case "$cmd" in
        install)    action=add;;
        uninstall)  action=remove;;
    esac

    if [[ -n "$action" ]]; then
        for arg in "${@:2}"; do
            [[ "$arg" == -* ]] || pkgs+=("$arg")
        done
        (( ${#pkgs[@]} )) && "$homebrew" bundle "$action" --file "$installs_file" "${pkgs[@]}"
    fi

    "$homebrew" "$@"
 }
