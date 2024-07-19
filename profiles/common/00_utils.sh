# shellcheck disable=SC2148,SC3010,SC3037

# utility functions

install() {
    package_list=${*}

    pkg_mgr=$(get_package_manager)

    case $pkg_mgr in
        yum)    sudo yum install -y "$package_list"
                ;;
        apt)    sudo apt install -y "$package_list"
                ;;
        dnf)    sudo dnf install -y "$package_list"
                ;;
        brew)   brew install "$package_list"
                ;;
        *)      echo "Unable to determine package manager. $package_list not installed."
                return 2
                ;;
    esac
}

warn() {
    message=${*}

    RED='\033[1;91m'
    NC='\033[0m'

    echo -e "${RED}Warning${NC}: ${message}" 1>&2
}

get_os() {
    base_os=$(uname)
    case $base_os in
        Darwin) os=macos
                ;;
        Linux)  os=linux
                ;;
        *)      os=unknown
                ;;
    esac
    echo $os
}

get_package_manager() {
    os=$(get_os)

    pkg_mgr=unknown
    package_managers_macos="brew"
    package_managers_linux="yum apt dnf"

    if [[ "$os" == "macos" ]]; then
        package_managers=$package_managers_macos
    elif [[ "$os" == "linux" ]]; then
        package_managers=$package_managers_linux
    fi

    for pm in $package_managers; do
        if [[ $(command -v "$pm") ]]; then
            pkg_mgr=$pm
            break
        fi
    done

    echo "$pkg_mgr"
}

# iTerm2 helper functions
function tabname() {
    echo -ne "\033]0;"$*"\007"
}

function tabcolor() {
    local red=0
    local green=0
    local blue=0
    case $1 in
        green)
            red=57
            green=197
            blue=77
            ;;
        red)
            red=270
            green=60
            blue=83
            ;;
        orange)
            red=227
            green=143
            blue=10
            ;;
        purple)
            red=255
            green=0
            blue=255
            ;;
        *)
            if [[ "$1" =~ ^[0-9]+,[0-9]+,[0-9]$ ]]; then
                red=$(echo "$1" | cut -f1 -d,)
                green=$(echo "$1" | cut -f2 -d,)
                blue=$(echo "$1" | cut -f3 -d,)
            fi
            ;;
    esac
    echo -ne "\033]6;1;bg;red;brightness;${red}\a"
    echo -ne "\033]6;1;bg;green;brightness;${green}\a"
    echo -ne "\033]6;1;bg;blue;brightness;${blue}\a"
}
