" 起動時にruntimepathにNeoBundleのパスを追加する
if has('vim_starting')
 	if &compatible
     	set nocompatible
	endif
	set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" NeoBundle設定の開始
call neobundle#begin(expand('~/.vim/bundle'))

" NeoBundleのバージョンをNeoBundle自身で管理する
NeoBundleFetch 'Shougo/neobundle.vim'

" インストールしたいプラグインを記述
" 下記は unite.vimというプラグインをインストールする例
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'Shougo/vimproc.vim', {
            \ 'build' : {
            \ 'windows' : 'make -f make_mingw32.mak',
            \ 'cygwin' : 'make -f make_cygwin.mak',
            \ 'mac' : 'make -f make_mac.mak',
            \ 'unix' : 'make -f make_unix.mak',
            \ },
            \ }
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'justmao945/vim-clang'

"set clang options for vim-clang
let g:clang_c_options = '-std=c11'
let g:clang_cpp_options = '-std=c++1z -stdlib=libc++ --pedantic-errors'

" NeoBundle設定の終了
call neobundle#end()

filetype plugin indent on

" vim起動時に未インストールのプラグインをインストールする
NeoBundleCheck

set tabstop=4
set autoindent
set shiftwidth=41
set clipboard=unnamed,autoselect
set whichwrap=b,s,[,],<,>
set backspace=indent,eol,start
:syntax on
set laststatus=2
