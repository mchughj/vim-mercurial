
"
" Plugin for integration with Mercurial
"
" Maintainer: Jason McHugh <mchughj@fb.com>
" Created: 2013 Mar 25

" ----------------------------------------------------------------
" Maps
" ----
"   <Leader>hd  Diff       - Show me this file diff'ed against the master
"   <Leader>hl  log        - Show me the modifications to this file
"   <Leader>ht  Tip        - Show me information about the tip and what files have changed
"
"   <Leader>he  Edit       - Edit this file
"   <Leader>hs  Source     - Source this file
"

" ----------------------------------------------------------------
" Maps
" ----------------------------------------------------------------
nmap <Leader>he :edit ~/.vim/plugin/hg.vim<CR>
nmap <Leader>hE :new ~/.vim/plugin/hg.vim<CR>
nmap <Leader>hs :source ~/.vim/plugin/hg.vim<CR>

nmap <Leader>hd :call <SID>ShowDiffs()<CR>
nmap <Leader>hl :call <SID>ShowLog()<CR>
nmap <Leader>ht :call <SID>ShowTipInfo()<CR>


function! s:ClearDiffSettings()
  set nofoldenable
  set foldcolumn=0
  set nodiff
  diffoff!
endfunction

function! <SID>ShowDiffs()
	if &diff
    if ! exists("b:filediff")
      winc w
    endif 
    silent exec ":bd!"
    call s:ClearDiffSettings()
  else 
    let filename = expand("%")
    call s:ClearDiffSettings()
    diffthis
    only
    vnew
    let b:filediff="true"
    silent exec ":r!hg cat " . filename . " -r master"
    1
    silent exec ":d"
    set nomod
    diffthis

  endif
endfunction

function! <SID>ShowTipInfo()
  new
  exec ":r! hg log -r. --template \"{files}\""
  exec ":%s/ //g"
  1
  exec ":d"
  set nomod
  set nolist

  nnoremap <buffer> <cr> :call <SID>OpenFile(0)<cr>
  nnoremap <buffer> e :call <SID>OpenFile(0)<cr>
  nnoremap <buffer> E :call <SID>OpenFile(1)<cr>
endfunction


function! <SID>OpenFile(newWindow)
  let l = getline(".")
  if a:newWindow == 0 
    exe ":e " . l
  else
    exe ":new " . l
  end
endfunction


function! <SID>ShowLog()
  new
  let filename = expand("%")
  exec ":r! hg log " . g:filename " --follow"
  put=''
  1
  exec ":d"

  put=' // ----------'
  put=' // ----------'
  put=' // - ' . filename
  put=' // ----------'
  put=' // ----------'
  put=''
  set nomod
  set nolist

" nnoremap <buffer> d    :call <SID>DeleteTask()<cr>
" nnoremap <buffer> w    :call <SID>WriteTask()<cr>
" if has("syntax") 
"   syn match header              " // .*"

"   hi def link header            Statement
  endif
endfunction

function! s:GetFileName( line )
  let mx='^www/\([^:]*\):'
  let line = matchstr( a:line, mx )
  return substitute( line, mx, '\1', '' )
endfunction

function! s:GetLineNumber( line )
  let mx='^www/[^:]*:\([^:]*\):'
  let line = matchstr( a:line, mx )
  return substitute( line, mx, '\1', '' )
endfunction

" vim: set sw=2 ts=2 :
