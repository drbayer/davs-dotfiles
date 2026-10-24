#! /usr/bin/env bash
# shellcheck disable=SC1091

# git prompt & completion

os=$(get_os)

if [[ $(which git) ]]; then
    if [[ $os == "macos" ]]; then
    
        if [[ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]]; then
            . "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
        fi
        
        if [[ -f "$(brew --prefix)/etc/bash_completion" ]]; then
          . "$(brew --prefix)/etc/bash_completion"
        fi

    else
        
        if [[ -f "${HOME}/.bash-git-prompt/gitprompt.sh" ]]; then
            . "$HOME/.bash-git-prompt/gitprompt.sh"
        else
            git clone https://github.com/magicmonty/bash-git-prompt.git "$HOME/.bash-git-prompt" --depth=1
            . "$HOME/.bash-git-prompt/gitprompt.sh"
        fi
    fi
    
    export GIT_PROMPT_ONLY_IN_REPO=1
    export GIT_PROMPT_THEME=Single_line
    export GIT_REPO_DIR="${HOME}"/repos

    while IFS= read -r includefile; do
        if [[ "$includefile" == "$DOTFILES_BASEDIR"/* ]] && [[ ! -e "$includefile" ]]; then
            git config --global --unset-all --fixed-value include.path "$includefile"
        fi
    done < <(git config --global --get-all include.path)

    for profile in active common; do
        gitdir="${DOTFILES_BASEDIR}/profiles/${profile}/git"
        if [[ -d "${gitdir}" ]]; then
            for includefile in "${gitdir}"/gitconfig.*; do
                [[ -f "$includefile" ]] || continue
                git config --global --replace-all --fixed-value include.path "$includefile" "$includefile" 2>/dev/null
            done
        fi
    done
fi
