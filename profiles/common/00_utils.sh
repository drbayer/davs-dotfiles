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

    echo -e "${RED}Warning${NC}: ${message}"
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
        if [[ $(which "$pm") ]]; then
            pkg_mgr=$pm
            break
        fi
    done

    echo "$pkg_mgr"
}

