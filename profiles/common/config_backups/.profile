
EDITOR='/usr/bin/vim'
PS1='\u@\h: \w \$ '
HISTFILESIZE=5000
HISTTIMEFORMAT="%m/%d/%y %T "

export EDITOR
export HISTTIMEFORMAT
export PROMPT_COMMAND='history -a'

# Show current git branch at bash prompt
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

GIT_PROMPT_ONLY_IN_REPO=1
GIT_PROMPT_THEME=Single_line

