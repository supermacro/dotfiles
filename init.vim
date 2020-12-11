let g:python3_host_prog = "/usr/local/bin/python3"


" Plugins

if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'airblade/vim-rooter'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-signify'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install' }
Plug 'tpope/vim-surround'
Plug 'preservim/nerdcommenter'


" Themes
Plug 'mhartington/oceanic-next'
Plug 'NieTiger/halcyon-neovim'
Plug 'morhetz/gruvbox'
Plug 'lifepillar/vim-solarized8'


" Syntax highlighting
Plug 'pantharshit00/vim-prisma'
Plug 'ekalinin/Dockerfile.vim'
Plug 'andys8/vim-elm-syntax'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'cespare/vim-toml'

call plug#end()

"""""""""""""""""""""""
" Plugin settings


" vim-arline settings
let g:airline#extensions#tabline#enabled = 1

" remove git info 
let g:airline_section_b = ''

" only show the number of lines, and nothing else
let g:airline_section_z = airline#section#create(['%L', ' ', 'ln'])

" remove separators for empty sections
let g:airline_skip_empty_sections = 1


" General Settings

if has('termguicolors')
  set termguicolors
endif


syntax enable

" colorscheme solarized8
" colorscheme gruvbox
colorscheme OceanicNext
" colorscheme halcyon


augroup WrapLineInMdFile
    autocmd!
    autocmd FileType markdown setlocal wrap
augroup END


set cursorline
set nowrap
set number

set cmdheight=2

" https://vim.fandom.com/wiki/Vim_buffer_FAQ#hidden
set hidden




" show space characters
" set list
" set listchars=trail:𐩑,space:𐩑

" Indentation-related stuff
" https://stackoverflow.com/questions/234564/tab-key-4-spaces-and-auto-indent-after-curly-braces-in-vim?rq=1
filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
autocmd FileType javascriptreact setlocal shiftwidth=2 tabstop=2
autocmd FileType typescript setlocal shiftwidth=2 tabstop=2
autocmd FileType typescriptreact setlocal shiftwidth=2 tabstop=2
autocmd FileType json setlocal shiftwidth=2 tabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2
autocmd FileType prisma setlocal shiftwidth=2 tabstop=2


" Highlight Current Line Number
" https://stackoverflow.com/a/9887272/4259341
hi CursorLineNr term=bold ctermfg=Yellow gui=bold guifg=Yellow


"""""""""""""""""""""""
" Key Mappings

" replace all occurrences of word on cursor with whatever you want
" https://vim.fandom.com/wiki/Search_and_replace_the_word_under_the_cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" copy just the file name to clipboard
nmap <Leader>cs :let @*=expand("%")<CR>
" copy the filename + path to clipboard
nmap <Leader>cf :let @*=expand("%:p")<CR>

" tab between buffers
nmap <Tab>[ :bp<Return>
nmap <Tab>] :bn<Return> 

" Move between windows
nmap <Tab>j <C-W><Down> 
nmap <Tab>k <C-W><Up>

" simple copy / paste onto system clipboard
vmap <leader>y "+y
nmap <leader>p "+p



" COC mappings
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gi <Plug>(coc-diagnostic-info)
nmap <silent> gf <Plug>(coc-diagnostic-info)
nmap <leader>rn <Plug>(coc-rename)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction


" Show dotfiles by default
let NERDTreeShowHidden=1
let g:NERDTreeWinSize=30
nmap <silent> <leader>nt :NERDTreeToggle<CR>
nmap <silent> <leader>nf :NERDTreeFind<CR>




"""""""""""""""""""""""""""""""""""""
" FZF Settings
" prevent opening buffers inside of NERD_tree window
" https://github.com/junegunn/fzf/issues/453
" https://github.com/junegunn/fzf/issues/453#issuecomment-354634207
function! FZFOpen(command_str)
  if (expand('%') =~# 'NERD_tree' && winnr('$') > 1)
    exe "normal! \<c-w>\<c-w>"
  endif
  exe 'normal! ' . a:command_str . "\<cr>"
endfunction


nnoremap <silent> <leader>f :call FZFOpen(':Files')<CR>

" More Vim-specific fzf config available at
" https://github.com/junegunn/fzf/blob/d4c9db0a273ccd17e7f43026c1297b434df6cbd7/README-VIM.md
"
let g:fzf_layout = { 'window': { 'width': 0.7, 'height': 0.5 } }
let g:fzf_preview_window = []

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



" Use <esc> during normal mode to clear search highlighting
nnoremap <esc> :noh<return><esc>

inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

