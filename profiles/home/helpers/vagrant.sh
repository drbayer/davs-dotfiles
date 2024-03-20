#shellcheck disable=SC2112,SC2155,SC3043,SC1010
function vagrant() {
    local current_project_directory="$(pwd)"
    local rvm_silence_path_mismatch_check_flag=1
    pushd ~/.vagrant/hashicorp/vagrant >/dev/null
        VAGRANT_CWD="$current_project_directory" \
            VAGRANT_INSTALLER_ENV="silent" \
            rvm 3.1.4@vagrant do bundle exec vagrant $@
    popd
}
