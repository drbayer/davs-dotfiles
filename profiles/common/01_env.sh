#!/usr/bin/env bash
# env vars

export DOTFILES_COMMIT='true'       # default to commit dotfiles changes on exiting bash
export EDITOR='/usr/bin/vim'
export PS1='[\u@\h: \w]\$ '
export HISTSIZE=500000
export HISTFILESIZE=500000
export HISTTIMEFORMAT="%m/%d/%y %T "
export HISTCONTROL=ignorespace
export BASH_SILENCE_DEPRECATION_WARNING=1

# shellcheck disable=SC2155
export HOMEBREW_GITHUB_API_TOKEN="$(get_safe_value HOMEBREW_GITHUB_API_TOKEN)" 
export PATH=/opt/homebrew/bin:/usr/local/opt/gnu-sed/libexec/gnubin:$PATH:$HOME/.bash.d/profiles/common/helpers:$HOME/.bash.d/profiles/active/helpers:/usr/local/opt/python/libexec/bin:$HOME/Library/Python/3.8/bin
export PROMPT_COMMAND='history -a; history -n'  # add '; history -n' if you want to reread history file on each prompt

if [[ -e /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

