" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif


call plug#begin('~/.vim/plugins')

Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'dense-analysis/ale'
" Plug 'scrooloose/syntastic'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'frazrepo/vim-rainbow'
Plug 'tpope/vim-fugitive'
Plug 'cohama/lexima.vim'
Plug 'Exafunction/windsurf.vim', { 'branch': 'main' }

call plug#end()

" NERDTree config
nnoremap <C-t> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeRespectWildIgnore=1
set wildignore+=*.DS_Store
if getcwd() =~ 'range-acl' || getcwd() !~ 'ingraphs-dashboards' && getcwd() !~ 'range'
    autocmd VimEnter * NERDTree
    autocmd VimEnter * wincmd p
endif
cnoremap Q qa
autocmd BufWinEnter * silent NERDTreeMirror
nmap <F8> :TagbarToggle<CR>

" ALE config
let g:ale_fixers = {
\    '*': ['prettier', 'remove_trailing_lines', 'trim_whitespace'],
\   'yaml': ['yamlfix', 'yamlfmt', 'remove_trailing_lines', 'trim_whitespace']
\}

if !empty(glob("$DOTFILES_BASEDIR/profiles/common/flake8"))
    let g:syntastic_python_flake8_args = "--append-config $DOTFILES_BASEDIR/profiles/common/flake8"
endif

" Tagbar config
nnoremap <C-o> :TagbarToggle<CR>
let g:tagbar_type_tf = {
  \ 'ctagstype': 'tf',
  \ 'kinds': [
    \ 'r:Resource',
    \ 'R:Resource',
    \ 'd:Data',
    \ 'D:Data',
    \ 'v:Variable',
    \ 'V:Variable',
    \ 'p:Provider',
    \ 'P:Provider',
    \ 'm:Module',
    \ 'M:Module',
    \ 'o:Output',
    \ 'O:Output',
    \ 'f:TFVar',
    \ 'F:TFVar'
  \ ]
\ }

" CSV don't obfuscate field delimiters
let g:csv_no_conceal = 1
