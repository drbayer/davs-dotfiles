# shellcheck disable=SC2148

# set java version

os=$(get_os)
java_funcs="$HOME/.bash.d/profiles/common/helpers/java_functions.sh"
#java_default_version="9.0"

if [[ "$os" == "macos" ]] && [[ -f "$java_funcs" ]]; then
    source "$java_funcs"
#    if [[ -z "$JAVA_VERSION" ]]; then
#        setJava "$java_default_version"
#    else
#        setJava "$JAVA_VERSION"
#    fi
fi

