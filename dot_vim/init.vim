" Vundle {{{
" no VI compatibility
set nocompatible
" set filetype off (for Vundle)
filetype off
" normal colors
set notermguicolors

if has("unix")
	set rtp+=~/.vim/bundle/Vundle.vim
	call vundle#begin()
else
	set rtp+=d:/tools/vim/vimfiles/bundle/Vundle.vim/
	call vundle#begin('d:/tools/vim/vimfiles/bundle')
endif

" Plugins
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
"Plugin 'tpope/vim-rails'
Plugin 'vim-ruby/vim-ruby'
"Plugin 'Valloric/YouCompleteMe'
Plugin 'SirVer/ultisnips'
Plugin 'bling/vim-airline'
Plugin 'kien/ctrlp.vim'
Plugin 'mattn/emmet-vim'
"Plugin 'dense-analysis/ale'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'majutsushi/tagbar'
Plugin 'derekwyatt/vim-fswitch'
Plugin 'joe-skb7/cscope-maps'
Plugin 'fs111/pydoc.vim'
Plugin 'matze/vim-tex-fold'
Plugin 'tmhedberg/SimpylFold'
Plugin 'pangloss/vim-javascript'
Plugin 'suy/vim-qmake'
Plugin 'cespare/vim-toml'
Plugin 'dag/vim-fish'

Plugin 'TeX-9'
"Plugin 'Smart-Tabs'
Plugin 'AutoFenc'
Plugin 'sql_iabbr.vim'
Plugin 'bufkill.vim'
Plugin 'DoxygenToolkit.vim'
Plugin 'jremmen/vim-ripgrep'

call vundle#end()
" }}}

" OS specific {{{
" Backup
set backup

if has("unix")
	if ($USER != "root")
		set backupdir=~/.vim/tmp
		set directory=~/.vim/tmp//
	else
		"set backupdir=~/tmp
		"set directory=~/tmp//
		set nobackup
	endif
	" Use + register (X Window clipboard) as unnamed register
	set clipboard+=unnamedplus
	let g:autofenc_ext_prog_args = "-i -L polish"
	let $VIMHOME = $HOME.'/.vim'
	let ctrlp_latex = '--options=/home/kuba/.vim/ctags/latex.cnf --language-force=latex --latex-types=lstu'
	let tagbar_latex = expand('<sfile>:p:h') . '/.vim/ctags/tagbar_latex.cnf'
else
	set shellslash
	set clipboard+=unnamed " share windows clipboard
	let g:autofenc_ext_prog_args = "-m -L polish"
	let g:tagbar_ctags_bin = 'C:\Program Files\Ctags\ctags.exe'
	set encoding=utf-8
	let $VIMHOME = $VIM.'/vimfiles'
	set backupdir=$VIMHOME/tmp
	set directory=$VIMHOME/tmp//
	let ctrlp_latex = '--options='.$VIMHOME.'ctags/latex.cnf --language-force=latex --latex-types=lstu'
	let tagbar_latex = $VIMHOME.'ctags/tagbar_latex.cnf'
endif
" }}}

" Settings {{{
" normal backspace
set backspace=indent,eol,start

" Comma is a new leader
let mapleader = ","
let maplocalleader = ","

" Enable filetype plugin
filetype plugin indent on
" Syntax highlighting, essential
syntax on

" Intenting
set autoindent
set smartindent
set cindent
set cinoptions=(0,u0,:0,g0,t0,N-s

" Textwidth
set textwidth=0

" Autoread when a file is changed outside
set autoread

set hidden

" Line nubering
set number

" Line highlighting
set cursorline "(makes vim slow so disabled)

" Minimal number of screen lines to keep above and below the cursor
set scrolloff=0

" Splitting
set splitbelow
set splitright

" Always display the status line
set laststatus=2

" Tabs
set softtabstop=0
set shiftwidth=4
set tabstop=4
set noexpandtab
"set smarttab

" Auto-formatting
"set formatoptions=c,q,r,t

" History of remembered lines
set history=1000

" Save changes to undo file (persistent undo)
"set undofile
set undolevels=1000

set showcmd

set showmode

" Redraw only when we need to
set lazyredraw

" Always show current position
set ruler
" Wrap lines
set nowrap
set linebreak

" No sound on errors
set noerrorbells
set novisualbell

" Mouse
set mouse=a "use mouse in all modes

" tty
set ttyfast

" Search
set incsearch "Go to searched word
set ignorecase "Ignore case when searching
set smartcase
set hlsearch "Highlight searched stuff
set showmatch "Show matching brackets
"set gdefault "Global substitution default

set nopaste "Default disabled, problems with fuzzyfind
set wildmenu
"set wildmode=longest:full
set wildmode=list:longest
set wildignore=*.swp,*.bak,*.tmp

" Whitespace handling
set listchars=tab:>\ ,trail:.,extends:#,nbsp:_,eol:↲

" Dark background
set background=dark
"let g:hybrid_use_Xresources = 1
" }}}

" Airline {{{
set ttimeoutlen=50
let g:airline_powerline_fonts = 1
let g:airline_mode_map = {
    \ '__' : ' - ',
    \ 'n'  : ' N ',
    \ 'i'  : ' I ',
    \ 'R'  : ' R ',
    \ 'c'  : ' C ',
    \ 'v'  : ' V ',
    \ 'V'  : 'V-L',
    \ '' : 'V-B',
    \ 's'  : ' S ',
    \ 'S'  : 'S-L',
    \ '' : 'S-B',
    \ }
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.whitespace = 'Ξ' " Envy Code R fix
" }}}

" NeoSolarized {{{ 
let g:neosolarized_diffmode = "high"
" }}}

" Gvim {{{
if has("gui_running")
	colorscheme NeoSolarized
	set guiheadroom=0
	" Maximalize screen space, looks stupid but works
	set guioptions+=LlRrbTm
	set guioptions-=LlRrbTm
	" Disable annoying cursor blinking
	set guicursor+=a:blinkon0
	" Special OS settings
	if has("gui_gtk2")
		set guifont=DejaVu\ Sans\ Mono\ 9
		map <S-Insert> "*p
		map! <S-Insert> <C-R>*
	elseif has("gui_gtk3")
		set guifont=DejaVu\ Sans\ Mono\ 9
		map <S-Insert> "*p
		map! <S-Insert> <C-R>*
	elseif has("gui_win32")
		set guifont=DejaVu_Sans_Mono_for_Powerline:h10:cDEFAULT " Compatibile font for powerline fancy symbols
	endif
else
	" Tmux override magic (for Meta-arrows)
	if &term =~ '^screen'
		execute "set <xUp>=\e[1;*A"
		execute "set <xDown>=\e[1;*B"
		execute "set <xRight>=\e[1;*C"
		execute "set <xLeft>=\e[1;*D"
		execute "set <kPlus>=Ok"
		execute "set <kMinus>=Om"
		execute "set <kDivide>=Oo"
		execute "set <kMultiply>=Oj"
		execute "set <kEnter>=OM"
	endif
	" TTY hoodoo
	if (&term == "linux" || &term == "screen" || &term == "xterm")
		" Trick vim I have loaded airline
		let g:loaded_airline = 1
		" Default statusline
		set statusline=\ [%n]\ %f\ %m\ %r\ %h%=[%{strlen(&fenc)?&fenc:'none'}][%{&ff}]%y%5v,%l/%L\ %P
		" Status for special filetypes without Powerline
		"autocmd FileType qf setlocal statusline=\ %n\ \ %f%=%l\ of\ %L\
		"autocmd FileType help setlocal statusline=Help:\ %f%=%c,%l/%L\ %P
		"autocmd FileType fuf setlocal statusline=%=Fuzzyfinder
		colorscheme NeoSolarized
	else
		set t_Co=256
		colorscheme NeoSolarized
	endif
endif
" }}}

" Php {{{
let php_sql_query = 1 " Highlight SQL Queries
let php_htmlInStrings = 1 " Highlight HTML in Strings
let use_xhtml = 1
" }}}

" HTML/JS {{{
let g:html_indent_inctags = "html,body,head,p,tbody,li,header,footer,section,article,figure,aside,video"
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"
" }}}

" Spellcheck {{{
set spelllang=pl "for both: set spelllang=pl,en
" }}}

" Autofenc {{{
let g:autofenc_enc_blacklist = '\(us-ascii\|utf-7\)'
let g:autofenc_max_file_size = 20971520
let g:autofenc_autodetect_bom = 1
" }}}

" Omni Complete {{{
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

 " Closes the preview window after completion
"autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
"autocmd InsertLeave * if pumvisible() == 0|pclose|endif
" Do not show preview window at all
set completeopt=longest,menu,menuone
" }}}

" Supertab {{{
"let g:SuperTabDefaultCompletionType = "context"
"let g:SuperTabContextDefaultCompletionType = "<C-n>"
"let g:SuperTabMappingForward = '<C-space>'
"let g:SuperTabMappingBackward = '<S-C-space>'
" }}}

" UltiSnips {{{
"let g:UltiSnipsExpandTrigger = '<C-\>'
let g:python3_host_prog = '/usr/bin/python'
" }}}

" Fuzzyfinder {{{
"let g:fuf_file_exclude = '\v\~$|\.(o|exe|dll|bak|swp|pyc|pyo|pyd)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])'
" }}}

" NERDCommenter {{{
let g:NERDCustomDelimiters = {
    \ 'dosini': { 'left': '#' }
\ }
" }}}

" CtrlP {{{
let ctrlp_cmd = 'CtrlPTag'
let ctrlp_python = '--language-force=python --python-kinds=-vi --exclude=build --exclude=dist'
let g:ctrlp_clear_cache_on_exit = 1 " cross-session cache
let g:ctrlp_user_command = 'rg -g "" --color=never --ignore-vcs --hidden --files %s'
let g:ctrlp_root_markers = ['Gemfile'] " stop searching upwards for Rails
let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_switch_buffer = 0
let g:ctrlp_working_path_mode = 0

"let g:ctrlp_prompt_mappings = {
	"\ 'AcceptSelection("e")': ['<c-t>', '<MiddleMouse>'],
	"\ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
	"\ }

let g:ctrlp_buftag_types = {
	\ 'tex': ctrlp_latex,
	\ 'python': ctrlp_python,
	\ }
" }}}

" Zencoding {{{
let g:user_zen_expandabbr_key = '<C-e>'
" }}}

" YouCompleteMe {{{
let g:jedi#auto_initialization = 0
let g:jedi#popup_on_dot = 0
let g:ycm_key_list_select_completion = ['<Down>']
let g:ycm_key_list_previous_completion = ['<Up>']
let g:ycm_confirm_extra_conf = 0
" }}}

" Folding {{{
set foldmethod=syntax " folding uses syntax for folding [indent]
set nofoldenable " don't start with folded lines
set foldlevelstart=10 " open most folds by default
set foldnestmax=10 " 10 nested fold max
" }}}

" LaTeX {{{
" LaTeX-Box
"let g:LatexBox_output_type = 'pdf'
"let g:LatexBox_latexmk_options = '-pvc'
"let g:vim_program = v:progname

if has("unix")
	let g:LatexBox_viewer = 'xpdf'
else
	let g:LatexBox_viewer = 'C:\Program Files\Foxit Reader\Foxit Reader.exe'
endif

let g:tex_flavor = 'latex'
let g:tex_conceal= 'admgs'
let g:tex_viewer = {'app': 'xpdf', 'target': 'pdf'}
let g:tex_fold_sec_char = '→'
let g:tex_fold_env_char = '»'
" }}}

" Tagbar {{{
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1

" LaTeX in tagbar
let g:tagbar_type_tex = {
	\ 'ctagstype' : 'latex',
	\ 'kinds'	 : [
		\ 's:sections',
		\ 'g:graphics',
		\ 'l:labels',
		\ 'r:refs:1',
		\ 'p:pagerefs:1'
	\ ],
	\ 'sort'	: 0,
	\ 'deffile' : tagbar_latex
\ }
" }}}

" Rope AutoComplete {{{
let ropevim_vim_completion = 1
let ropevim_extended_complete = 1
let ropevim_guess_project = 1
let ropevim_autoimport_modules = ["os", "shutil", "datetime"]
" }}}

" Syntastic {{{
let g:syntastic_enable_signs = 0
let g:syntastic_enable_balloons = 0
let g:syntastic_mode_map = { 'mode': 'passive',
			\ 'active_filetypes': [],
			\ 'passive_filetypes': ['tex', 'plaintex'] }
" }}}

" Autocmd {{{
" Vala
au BufRead *.vala set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
au BufRead *.vapi set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
au BufRead,BufNewFile *.vala setfiletype vala
au BufRead,BufNewFile *.vapi setfiletype vala

" Python
" Repair some syntax highlighting
au FileType python syn keyword Structure self __debug__ __doc__ __file__ __name__ __package__
au FileType python syn keyword Number True False None NotImplemented Ellipsis

" C/C++
"au Filetype c,cpp set cscopetag

" Conf files
au Filetype conf set tabstop=8

" Asciidoc
au BufNewFile,BufRead *.adoc setf asciidoc

" Diff
au VimEnter * if &diff | execute 'windo set wrap' | endif
if &diff | syntax off | endif
"}}}

" Templates {{{
autocmd BufNewFile * silent! 0r $VIMHOME/templates/%:e.tpl
" }}}

" Functions {{{
" Toggle relative or absoulte numbers
function! NumberToggle()
	if(&relativenumber == 1)
		set number
	else
		set relativenumber
	endif
endfunc

function! CycleBuffers(forward)
	" Change buffer (keeping track of before and after buffers)
	let l:origBuf = bufnr('%')
	if (a:forward == 1)
		bn!
	else
		bp!
	endif
	let l:curBuf = bufnr('%')

	" Ignore non modifiable buffers
	while getbufvar(l:curBuf, '&modifiable') == 0 && l:origBuf != l:curBuf
		if (a:forward == 1)
			bn!
		else
			bp!
		endif
		let l:curBuf = bufnr('%')
	endwhile
endfunction
" }}}

" Bindings {{{
noremap ; :
noremap <silent> <Up> gk
noremap <silent> <Down> gj
noremap <silent> k gk
noremap <silent> j gj

" Easier window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" Config file shortcut
nmap <leader>ev :tabedit $MYVIMRC<CR>

" Remove trailingtspaces
nmap <leader>rt :%s/\s\+$//e<CR>

" Repair Home and End keys to work like ^ and g_
noremap <Home> ^
noremap <End> g_

" Repair broken C-b and Pgup
noremap <silent> <PageUp> 1000<C-u>
noremap <silent> <C-b> 1000<C-u>
noremap <silent> <PageDown> 1000<C-d>
noremap <silent> <C-f> 1000<C-d>
inoremap <silent> <PageUp> <C-o>1000<C-u>
inoremap <silent> <PageDown> <C-o>1000<C-d>

" Pull word under cursor into lhs of a substitute
nmap gS :%s/<C-r>=expand("<cword>")<CR>/
" A very useful map
map gs :%s/

set relativenumber
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber

nnoremap <Leader>n :call NumberToggle()<CR>

" Toggle list whitespaces
nmap <leader>l :set list!<CR>

" highlight last inserted text
nnoremap gV `[v`]

" Quickfix next/prev error
nnoremap ]q :cnext<cr>
nnoremap [q :cprevious<cr>

" Cancel search highlight
nnoremap <silent> <Leader>/ :noh<CR>
noremap <silent> <F12> :noh<CR>
noremap <F11> :set paste!<Bar>set paste?<CR>
noremap <F10>  :set wrap!<Bar>set wrap?<CR>
nnoremap <silent> <F9> :TagbarToggle<CR>
noremap <silent> <F8>  :NERDTreeToggle<CR>
noremap <silent><F7>   :setlocal spell!<CR>
inoremap <silent><F7>  <ESC>:setlocal spell!<CR>i<right>

" Comment/Uncomment
map <F5> <leader>c<space><CR>
imap <F5> <C-o><leader>c<space><C-o><CR>
map <C-_> <leader>c<space><CR>
imap <C-_> <C-o><leader>c<space><C-o><CR>

" Free
"map <F6>
"imap <F6>

" Switch source/header
autocmd FileType c,cpp nnoremap <F4> :FSHere<CR>
autocmd FileType ruby,eruby nnoremap <F4> :R<CR>

" Syntastic checking
noremap <buffer> <F3> :SyntasticCheck<CR>

" Save current buffer
nnoremap <F2> :w!<CR>
vnoremap <F2> <Esc>:w!<CR>gv
inoremap <F2> <C-o>:w!<CR>

" Disable F1 Help
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Buffers & Tabs
nmap <C-k> :CtrlP<CR>
nmap <C-o> :CtrlPBuffer<CR>
nmap <C-g> :CtrlPBufTag<CR>

nmap <silent><M-Up> :call CycleBuffers("1")<CR>
nmap <silent><M-Down> :call CycleBuffers("0")<CR>
nmap <silent><M-Right> gt
nmap <silent><M-Left> gT

"nmap <silent><M-l> :call CycleBuffers("1")<CR>
"nmap <silent><M-h> :call CycleBuffers("0")<CR>

" Gvim only
nmap <C-Tab> gt
nmap <C-S-Tab> gT

" Astyle
nmap <silent><leader>as :%!astyle -A1 -t4 -n -m0 -k3 -p -H -U -q<CR>
" }}}

" vim:foldmethod=marker:foldlevel=0
