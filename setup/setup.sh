#!/usr/bin/env bash

# This script is for initial clone of the dotfiles repo and setting up
# symlinks, etc.
#
# The script will create symlinks from links.csv found in the same dir
# as the script itself. Destination entries are relative to user's
# home directory.

# TODO install homebrew
# TODO install hombebrew packages

BACKUP_ALL=n
ACCEPT_ALL=n
DEST_DIR="${HOME}/.bash.d"
GIT_REPO=git@github.com:drbayer/davs-dotfiles.git
PROFILE=
SSH_KEY=

usage() {
    echo "Usage: ${0##*/} [-b] [-d DEST_DIR] [-y] [-h]"
    echo
    echo "    -b            Backup all items that would be overridden"
    echo "    -d DEST_DIR   Specify alternate directory for dotfiles"
    echo "    -g GIT_REPO   Specify Git repo URN"
    echo "    -p PROFILE    Specify bash profile for this computer"
    echo "    -y            Respond yes to all prompts"
    echo "    -h            Display this help message"
    echo
    echo "If not specified, DEST_DIR defaults to ~/.bash.d"
    echo
    echo "If PROFILE is not specified the user will be prompted to"
    echo "select from the profiles available or create a new one."
    echo
    echo "setup.sh is designed to be idempotent and only makes changes"
    echo "when desired state does not match existing state."
    exit 5
}

overwrite() {
    local OVERWRITE="$1"
    local item="$2"

    if [[ -e "$item" ]] && [[ "$OVERWRITE" != "y" ]]; then
        OVERWRITE='N'
        local prompt="$item already exists. Overwrite [y|N]? "
        read -rp "$prompt" OVERWRITE
        OVERWRITE=${OVERWRITE:0:1}
        OVERWRITE=$(echo "$OVERWRITE" | tr '[:upper:]' '[:lower:]')
    fi
    echo "$OVERWRITE"
}

backup() {
    local backup="$1"
    local item="$2"

    if [[ "$backup" != "y" ]]; then
        backup='Y'
        local prompt="Backup $item before proceeding [Y|n]? "
        read -rp "$prompt" backup
        backup=${backup:0:1}
        backup=$(echo "$backup" | tr '[:upper:]' '[:lower:]')

        if [[ "$backup" == "y" ]]; then
            mv "$item" "$item.bak"
        fi
    fi

}

link_item() {
    local src="$1"
    local dst="$2"
    
    if [[ -e "$dst"  ]]; then
        if [[ $(overwrite "$ACCEPT_ALL" "$dst") == "y" ]]; then
            backup "$BACKUP_ALL" "$dst"
            [[ -L "$dst" ]] && unlink "$dst"
            [[ -e "$dst" ]] && rm -rf "$dst"
        else
            return 1
        fi
    fi

    # shellcheck disable=SC2076
    if [[ ! "$dst" =~ "$HOME" ]]; then
        dst="${HOME}/${dst}"
    fi
    symlink_basedir=$(echo "$dst" | rev | cut -d / -f 2- | rev)
    if [[ ! -d "$symlink_basedir" ]]; then
        mkdir -p "$symlink_basedir"
    fi

    echo "Linking $dst to $src"
    ln -s "$src" "$dst"
}

install_git() {
    # Install git if not already there
    if [[ ! $(which git) ]]; then
        os=$(uname)
        if [[ "$os" == "Darwin" ]]; then
            # macOS will auto-install git when you run git commands
            git --version > /dev/null 2>&1
            until [[ $(which git) ]]; do
                sleep 10
            done
        elif [[ "$os" == "Linux" ]]; then
            for pm in yum apt dnf; do
                if [[ $(which "$pm") ]]; then
                    "$pm" install -y git
                    break
                fi
            done
        fi
    fi
}

clone_repo() {
    # Pull the dotfiles repo. Make sure all the necessary things are in place first.
    repo="$1"
    dest="$2"

    install_git
    load_ssh_key

    if [[ -e "$dest" ]]; then
        if [[ -f "$dest/.git/config" ]] && grep -q "$repo" "$dest/.git/config" > /dev/null 2>&1; then
            read -rp "Update existing dotfiles repo? " update
            update=${update:0:1}
            update=${update,,}
            if [[ "$update" == "y" ]]; then
                (
                # shellcheck disable=SC2164
                cd "$dest"
                git pull
                )
            fi
            return
        elif [[ $(overwrite "$ACCEPT_ALL" "$dest") == "y" ]]; then
            backup "$BACKUP_ALL" "$dest"
        else
            return 1
        fi
    fi
    echo "Cloning repo $repo into $dest"
    git clone "$repo" "$dest"
}

setup_safety_zone () {
    create_safe_values_file
}

setup_profile() {
    # Select the profile and set up git accordingly
    profile="$1"

    if [[ ! -z "$profile" ]] && [[ -d "${DEST_DIR}/profiles/${profile}" ]]; then
        PROFILE="$profile"
    else
        PROFILE=$(select_profile true)
    fi

    if [[ -d "${DEST_DIR}/profiles/${PROFILE}" ]]; then
        switch_profile "$PROFILE"
    else
        echo "Setup requires a valid profile to continue."
        usage
    fi

    setup_git
}

setup_git() {
    # Explicitly set which ssh key to use for dotfiles
    # If you have multiple github accounts (home & work), make sure to use the right key
    # Set as an ENV var to accommodate older versions of git
    # Also set up any git include files from your profile

    if [[ -d "${DEST_DIR}/profiles/${PROFILE}" ]]; then
        grep -q "export GITHUB_SSH_COMMAND.*${SSH_KEY}" "${DEST_DIR}/profiles/${PROFILE}/01_env.sh" ||
            echo "export GITHUB_SSH_COMMAND='ssh -i ${SSH_KEY}'" >> "${DEST_DIR}/profiles/${PROFILE}/01_env.sh"
    fi

    for profile in common active; do
        gitdir="${DEST_DIR}/profiles/${profile}/git"
        if [[ -d "${gitdir}" ]]; then
            for includefile in "${gitdir}"/gitconfig.*; do
                git config --global --get-all include.path | grep -q "path = $includefile" ||
                    git config --global --add include.path "$includefile"
            done
        fi
    done
}

setup_basedir() {
    # Dotfiles needs to know where to find all the things so add
    # DOTFILES_BASEDIR env var to .bashrc to get it early
    bashrc="${HOME}/.bashrc"

    if [[ -f "$bashrc" ]]; then
        if grep -q DOTFILES_BASEDIR "$bashrc" > /dev/null 2>&1 && ! grep -q "export DOTFILES_BASEDIR=${DEST_DIR}" "${bashrc}" > /dev/null 2>&1; then
            sed -i '' -e "s|\(export DOTFILES_BASEDIR=\).*|\1${DEST_DIR}|" "$bashrc"
        else
            echo "export DOTFILES_BASEDIR=${DEST_DIR}" >> "$bashrc"
        fi
    else
        touch "$bashrc"
        echo "export DOTFILES_BASEDIR=${DEST_DIR}" >> "$bashrc"
    fi
    export DOTFILES_BASEDIR="${DEST_DIR}"
}

load_ssh_key() {
    # Select the ssh key to use for the dotfiles repo
    if [[ -d "${HOME}/.ssh" ]]; then
        declare -a keys
        for public_key in "${HOME}"/.ssh/*.pub; do
            private_key=${public_key%.*}
            if [[ -f "${private_key}" ]]; then
                keys+=("${private_key}")
            fi
        done
        if [[ ${#keys[*]} -lt 1 ]]; then
            echo "Can't locate any SSH keys. Unable to clone git repo."
            exit 1
        else
            echo "Select ssh key to use to clone git repo: "
            for i in $(seq 0 $((${#keys[*]}-1)) ); do
                echo "$i) ${keys[i]}"
            done
            read -r ssh_key
            ssh-add "${keys[ssh_key]}"
            SSH_KEY="${keys[ssh_key]}"
        fi
    else
        echo "Can't locate any SSH keys. Unable to clone git repo."
        exit 1
    fi
}

install_brew_packages() {
    pkg_file="${DEST_DIR}/profiles/active/homebrew/installs.txt"
    if [[ ! -f "$pkg_file" ]]; then
        return 1
    fi
    pkg_list=$(cat "$pkg_file")
    cp "$pkg_list" "$pkg_list.bak"
    echo "Package list:"
    echo "$pkg_list"
    echo
    read -r -p "Install full list? [Y|n] " FULL_INSTALL
    if [[ "${FULL_INSTALL,,}" == "y" ]]; then
        install_list=$(echo "$pkg_list" | tr '\n' ' ')
    else
        for pkg in $pkg_list; do
            read -r -p "Install package $pkg? [Y|n]" INSTALL
            if [[ "${INSTALL,,}" == "y" ]]; then
                install_list="$install_list $pkg"
            else
                skip_list="$skip_list $pkg"
            fi
        done
    fi
    echo "Packages to install:"
    echo "$install_list" | tr ' ' '\n'
    read -r -p "Continue? [y|n] " CONTINUE
    if [[ "${CONTINUE,,}" = "y" ]]; then
        brew install "$install_list"
    else
        echo "Install cancelled by user"
        return 1
    fi
    echo "Packages installed: $install_list"
    echo "Packages skipped: $skip_list"
}

while getopts :ybd:g:p: FLAG; do
    case $FLAG in
        b)  BACKUP_ALL=y
            ;;
        d)  DEST_DIR=$OPTARG
            ;;
        g)  GIT_REPO=$OPTARG
            ;;
        p)  PROFILE=$OPTARG
            ;;
        y)  ACCEPT_ALL=y
            ;;
        *)  usage
            ;;
    esac
done

# Update path file here to prevent inadvertently using /bin/bash instead of /opt/homebrew/bin/bash
export PATH=/opt/homebrew/bin:$PATH
export DOTFILES_BASEDIR="$DEST_DIR"

clone_repo "$GIT_REPO" "$DEST_DIR"

# shellcheck disable=SC1091
source "${DEST_DIR}/profiles/common/helpers/profile_utils.sh"
# shellcheck disable=SC1091
source "${DEST_DIR}/profiles/common/00_safety-zone.sh"

setup_basedir
setup_profile "$PROFILE"
setup_safety_zone

declare -A links
while IFS=, read -r source destination; do
    if [[ "$source" == "source" ]]; then
        continue
    fi
    links["$source"]="$destination"
done < <(tail -n +2 "${DEST_DIR}/setup/links.csv")

for item in "${!links[@]}"; do
    link_item "${DEST_DIR}/${item}" "${HOME}/${links[$item]}"
done

install_brew_packages

exec -l ${SHELL}

