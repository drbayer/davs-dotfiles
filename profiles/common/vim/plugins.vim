
call plug#begin('~/.vim/plugins')

Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'scrooloose/syntastic'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf' | Plug 'junegunn/fzf.vim'
Plug 'preservim/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'frazrepo/vim-rainbow'
Plug 'tpope/vim-fugitive'
Plug 'cohama/lexima.vim'

call plug#end()

nnoremap <C-t> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeRespectWildIgnore=1
set wildignore+=*.DS_Store
if getcwd() !~ 'ingraphs-dashboards' && getcwd() !~ 'range'
    autocmd VimEnter * NERDTree
    autocmd VimEnter * wincmd p
    cnoremap Q qa
endif
autocmd BufWinEnter * silent NERDTreeMirror
nmap <F8> :TagbarToggle<CR>

if !empty(glob("$DOTFILES_BASEDIR/profiles/common/flake8"))
    let g:syntastic_python_flake8_args = "--append-config $DOTFILES_BASEDIR/profiles/common/flake8"
endif
