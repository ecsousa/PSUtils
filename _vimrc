set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

set diffexpr=MyDiff()
function MyDiff()
  let opt = ''
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  silent execute '!diff -a ' . opt . v:fname_in . ' ' . v:fname_new . ' > ' . v:fname_out
endfunction

if has("gui_running")
    colo torte
endif

set shiftwidth=4 tabstop=4
syntax on
set nobackup
set nowritebackup
set nowrap
set ignorecase

autocmd BufNewFile,BufRead *.vb set ft=vbnet
autocmd BufNewFile,BufRead *._ps1 set ft=ps1
autocmd BufNewFile,BufRead *.ps1 set ft=ps1
autocmd BufNewFile,BufRead *.psm1 set ft=ps1
autocmd BufNewFile,BufRead *.msbuild set ft=xml
autocmd BufNewFile,BufRead *.targets set ft=xml
autocmd BufNewFile,BufRead *.properties set ft=xml
autocmd BufNewFile,BufRead *.tasks set ft=xml
autocmd BufNewFile,BufRead *.proj set ft=xml
autocmd BufNewFile,BufRead *.props set ft=xml
autocmd BufNewFile,BufRead *.fsx set ft=fs

autocmd BufNewFile,BufRead *.wxi set ft=xml
autocmd BufNewFile,BufRead *.wxs set ft=xml

autocmd BufNewFile,BufRead COMMIT_EDITMSG set enc=utf8
autocmd BufNewFile,BufRead *.config set tabstop=2 shiftwidth=2 enc=utf8
autocmd BufNewFile,BufRead *.xml set tabstop=2 shiftwidth=2 enc=utf8
autocmd BufNewFile,BufRead *.wxi set tabstop=2 shiftwidth=2 enc=utf8
autocmd BufNewFile,BufRead *.wxs set tabstop=2 shiftwidth=2 enc=utf8
autocmd BufNewFile,BufRead *.nuspec set tabstop=2 shiftwidth=2 enc=utf8

nunmap <C-A>
nunmap <C-Y>

nmap <SPACE> <SPACE>:noh<CR>
nmap ,t <Esc>:tabnew<CR>
nmap ,n <Esc>:tabn<CR>
nmap ,p <Esc>:tabp<CR>
nmap ,f <Esc>:tabfirst<CR>
nmap ,l <Esc>:tablast<CR>

source $VIMRUNTIME/delmenu.vim
set langmenu=none
let do_syntax_sel_menu = 1
source $VIMRUNTIME/menu.vim

vnoremap > >gv
vnoremap < <gv

set nu

set expandtab

set guioptions-=T "remove toolbar
set guioptions-=m "remove menu

set directory=%TEMP%

" setup TFS integration
function! Tfedit()
exe '!tf checkout "' expand('%:p') '"'
endfunction
command! Tfedit :call Tfedit()

function! Tfcheckin()
exe '!tf checkin "' expand('%:p') '"'
endfunction
command! Tfcheckin :call Tfcheckin()

function! Tfundo()
exe '!tf undo "' expand('%:p') '"'
endfunction
command! Tfundo :call Tfundo()

function! Tfhist()
if bufnr("Tfhist") >0
exe "sb Tfhist"
else
exe "split Tfhist"
endif
setlocal noswapfile
set buftype=nofile
setlocal modifiable
silent! exe 'r!"tf history "#""'
setlocal nomodified
normal 1G
wincmd J
endfunction
command! Tfhist :call Tfhist() 

function! Msbuild()
if bufnr("Msbuild") >0
exe "sb Msbuild"
else
exe "split Msbuild"
endif
setlocal noswapfile
set buftype=nofile
setlocal modifiable
silent! exe 'r!"powershell -Command "buildcur #""'
setlocal nomodified
normal 1G
wincmd J
endfunction
command! Msbuild :call Msbuild() 



