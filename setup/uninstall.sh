#!/usr/bin/env bash

# Script to undo most of the changes made during setup:
#
# order of operations:
# * collect list of items that would be removed DONE
# * check for items to restore and mark for restore if user wants to DONE
# * remove git includes coming from dotfiles DONE
# * remove DOTFILES_BASEDIR export from .bashrc DONE
# * remove symlinks DONE
# * remove git repo dir DONE
# * restore backups

# possible backed up items: links, repo

RESTORE_ALL=undef

declare -A ITEM_LIST

usage() {
    echo "Usage: ${0##*/} [-d] [-r]"
    echo
    echo "  -d          Do not restore anything"
    echo "  -r          Restore all backup items found"
    echo "  -h          Display this help message"
    echo
    echo "Uninstall all items added by dotfiles setup. This includes:"
    echo "  * Remove symlinks defined in links.csv"
    echo "  * Remove ${DOTFILES_BASEDIR}"
    echo "  * Remove 'export DOTFILES_BASEDIR' from .bashrc"
    echo "  * Restore any backups found according to user response"
    exit 5
}

get_items_to_remove() {
    # iterate over items that should have been set by setup.sh
    # to see which exist and if they should be removed
    ITEM_LIST["$DOTFILES_BASEDIR"]="n"

    while IFS=, read -r source destination; do
        if [[ "$source" == "source" ]]; then
            continue
        fi
        # shellcheck disable=SC2076
        if [[ ! "$destination" =~ "${HOME}" ]]; then
            destination="${HOME}/${destination}"
        fi
        ITEM_LIST["$destination"]="$RESTORE_ALL"
    done < <(tail -n +2 "${DOTFILES_BASEDIR}/setup/links.csv")
    if [[ "$RESTORE_ALL" == "undef" ]]; then
        for key in "${!ITEM_LIST[@]}"; do
            ITEM_LIST[$key]=$(verify_restore "$key")
        done
    fi
}

check_for_backup() {
    # see if a backup exists for the item
    local item="$1"

    backup_item="${item}.bak"
    if [[ -e "$backup_item" ]]; then
        echo "y"
    else
        echo "n"
    fi
}

verify_restore() {
    # check with user to see if we should restore from backup
    local item="$1"
    local restore

    restore=$(check_for_backup "$item")
    if [[ "$restore" == "y" ]]; then
        local prompt="Restore backup of $item? [y|N] "
        read -rp "$prompt" restore
        if [[ "$restore" == "" ]]; then
            restore="n"
        fi
        restore=${restore:0:1}
        restore=$(echo "$restore" | tr '[:upper:]' '[:lower:]')
    fi
    echo "$restore"
}

remove_git_includes() {
    # remove any git includes from dotfiles, since dotfiles won't
    # be there any more to include
    for profile in active common; do
        gitdir="${DOTFILES_BASEDIR}/profiles/${profile}/git"
        if [[ -d "${gitdir}" ]]; then
            for includefile in "${gitdir}"/gitconfig.*; do
                grep -q "path = $includefile" ~/.gitconfig &&
                    git config --global --fixed-value --unset include.path "$includefile"
                done
        fi
    done
}

remove_dotfiles_export()  {
    # remove 'export DOTFILES_BASEDIR=' lines from .bashrc
    bashrc="${HOME}/.bashrc"

    if [[ -f "$bashrc" ]]; then
        sed -i '' -e 's|^.*export DOTFILES_BASEDIR=.*$||' "$bashrc"
    fi
}

remove_link() {
    local item="$1"
    if [[ -L "$item" ]]; then
        unlink "$item"
    fi
}

remove_basedir() {
    if [[ -d "${DOTFILES_BASEDIR}" ]]; then
        rm -rf "${DOTFILES_BASEDIR}"
    fi
}

restore_item() {
    local item="$1"

    mv "${item}.bak" "$item"
}


while getopts :dr FLAG; do
    case $FLAG in
        d)  if [[ "$RESTORE_ALL" == "undef" ]]; then
                RESTORE_ALL=n
            else
                echo "You cannot specify both flags '-d' and '-r'"
                usage
            fi
            ;;
        r)  if [[ "$RESTORE_ALL" == "undef" ]]; then
                RESTORE_ALL=y
            else
                echo "You cannot specify both flags '-d' and '-r'"
                usage
            fi
            ;;
        *)  usage
            ;;
    esac
done

get_items_to_remove
remove_git_includes
remove_dotfiles_export

for key in "${!ITEM_LIST[@]}"; do
    if [[ -L "$key" ]]; then
        remove_link "${key}"
    fi
done

remove_basedir

for key in "${!ITEM_LIST[@]}"; do
    if [[ "${ITEM_LIST[$key]}" == "y" ]]; then
        restore_item "$key"
    fi
done
