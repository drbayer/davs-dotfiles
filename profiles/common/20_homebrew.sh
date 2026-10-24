# shellcheck disable=SC2086,SC3010

# Certain utility functions including get_retcode and warn
# found in 00_utils.sh

brew() {
    # Utility function to capture installed packages
    cmd=$1
    shift
    # shellcheck disable=SC2124
    pkgs="$@" 
    homebrew=/opt/homebrew/bin/brew
    installs_dir="$DOTFILES_BASEDIR/profiles/active/homebrew"
    installs_file="$installs_dir/Brewfile"

    if [[ ! -x "$homebrew" ]]; then
        warn "brew command not found. Install at https://brew.sh"
        return "$(get_retcode FILE_NOT_FOUND)"
    fi

    if [[ ! -d "$installs_dir" ]]; then
        mkdir "$installs_dir"
    fi

    case "$cmd" in
        install)    echo "$pkgs" | xargs -I {} "$homebrew" bundle add --file "$installs_file" {};;
        uninstall)  echo "$pkgs" | xargs -I {} "$homebrew" bundle remove --file "$installs_file" {};;
    esac

    "$homebrew" "$cmd" "$pkgs"
 }
