#!/usr/bin/env bash
# shellcheck disable=SC2148,SC1090

# set java version

os=$(get_os)
java_funcs="$HOME/.bash.d/profiles/common/helpers/java_functions.sh"
#java_default_version="9.0"

if [[ "$os" == "macos" ]] && [[ -f "$java_funcs" ]]; then
    source "$java_funcs"
    if [[ ${#DOTFILES_JAVA_VERSION} -gt 0 ]]; then
        setJava "$DOTFILES_JAVA_VERSION"
    fi
fi

