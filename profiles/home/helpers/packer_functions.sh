

# packer + ansible + aws = no bueno if too many ssh keys in agent
function packer_build() {
    #ssh_remove_keys

    packer build $1 $2 | tee packer-$(date "+%Y%m%d-%H%M%S").log

    #ssh_add_keys
}

