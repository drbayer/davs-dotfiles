set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

if !empty(glob("~/.bash.d/profiles/active/nvim"))
    let include_list = globpath("~/.bash.d/profiles/active/nvim", "*.vim", 0, 1)
    for include_file in include_list
        exe 'so' include_file
    endfor
endif
