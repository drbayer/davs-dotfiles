# shellcheck disable=SC2148

# git prompt & completion

os=$(get_os)

if [[ $(which git) ]]; then
    if [[ $os == "macos" ]]; then
    
        if [[ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]]; then
            source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
        fi
        
        if [[ -f "$(brew --prefix)/etc/bash_completion" ]]; then
          source "$(brew --prefix)/etc/bash_completion"
        fi

    else
        
        if [[ -f "${HOME}/.bash-git-prompt/gitprompt.sh" ]]; then
            source "$HOME/.bash-git-prompt/gitprompt.sh"
        else
            git clone https://github.com/magicmonty/bash-git-prompt.git "$HOME/.bash-git-prompt" --depth=1
            source "$HOME/.bash-git-prompt/gitprompt.sh"
        fi
    fi
    
    export GIT_PROMPT_ONLY_IN_REPO=1
    export GIT_PROMPT_THEME=Single_line
    export GIT_REPO_DIR="${HOME}"/repos

    for profile in active common; do
        gitdir="${DOTFILES_BASEDIR}/profiles/${profile}/git"
        if [[ -d "${gitdir}" ]]; then
            for includefile in "${gitdir}"/gitconfig.*; do
                grep -q "path = $includefile" ~/.gitconfig ||
                    git config --global --add include.path "$includefile"
            done
        fi
    done
fi
