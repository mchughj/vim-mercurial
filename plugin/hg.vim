
"
" Plugin for integration with Mercurial
"
" Maintainer: Jason McHugh <mchughj@fb.com>
" Created: 2013 Mar 25

" See the doc file for information about this file.

" ----------------------------------------------------------------
" Maps
" ----------------------------------------------------------------
nmap <Leader>he :edit ~/.vim/bundle/vim-mercurial/plugin/hg.vim<CR>
nmap <Leader>hE :new ~/.vim/bundle/vim-mercurial/plugin/hg.vim<CR>
nmap <Leader>hs :source ~/.vim/bundle/vim-mercurial/plugin/hg.vim<CR>

nmap <Leader>hd :call <SID>ShowDiffs()<CR>
nmap <Leader>hl :call <SID>ShowLog()<CR>
nmap <Leader>ht :call <SID>ShowTipInfo()<CR>
nmap <Leader>hb :call <SID>ShowBookmarks()<CR>


function! <SID>ClearDiffSettings()
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
    call <SID>ClearDiffSettings()
  else 
    let filename = expand("%")
    call <SID>ClearDiffSettings()
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
  put=' // ---------------------------------------'
  put=' // Files currently modified as part of tip'
  put=' // ---------------------------------------'
  put=''
  exec ":r! hg log -r. --template \"{files}\""
  1
  d
  set nomod
  set nolist

  nnoremap <buffer> <cr> :call <SID>OpenFile(0)<cr>
  nnoremap <buffer> e :call <SID>OpenFile(0)<cr>
  nnoremap <buffer> E :call <SID>OpenFile(1)<cr>

  if has("syntax") 
    syn match header              " // .*"
    hi def link header            Statement
  endif

endfunction

function! <SID>ShowBookmarks()
  new
  put=' // ---------'
  put=' // Bookmarks'
  put=' // ---------'
  put=''
  exec ":r! hg bookmarks "
  1
  d
  set nomod
  set nolist

  nnoremap <buffer> <cr> :call <SID>OpenFile(0)<cr>
  nnoremap <buffer> e :call <SID>OpenFile(0)<cr>
  nnoremap <buffer> E :call <SID>OpenFile(1)<cr>

  if has("syntax") 
    syn match header              " // .*"
    hi def link header            Statement
  endif

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
  let filename = expand("%")
  new
  silent exec ":r!hg log " . filename 
  put=''
  1

  put=' // ----------'
  put=' // - ' . filename
  put=' // ----------'
  put=''
  put=' Commands: c - show more detailed information about changeset'
  put=' Commands: e - show the file with this changest'
  put=''
  set nomod
  set nolist

  nnoremap <buffer> c :call <SID>ViewChangeSetFromLog()<cr>
  nnoremap <buffer> e :call <SID>ViewFileVersionFromLog()<cr>
  if has("syntax") 
    syn match commands            "^ Commands.*"
    syn match header              " // .*"
    syn match changeset           "^changeset:.*"
    highlight def link header     Statement
    highlight def link commands   Type
    highlight def link changeset  Underlined
  endif
endfunction


function! <SID>ViewFileVersionFromLog()
  let filename = s:GetFilenameFromLog()
  let changeset = s:GetChangeSetAtOrAboveCursor()

  call <SID>ViewFileVersion(filename,changeset)
endfunction


function! <SID>ViewChangeSetFromLog()
  let changeset = s:GetChangeSetAtOrAboveCursor()
  call <SID>ViewChangeSet(changeset)
endfunction


function! <SID>GetChangeSetAtOrAboveCursor()
  let line = getline(".")
  if matchstr( line, "^changeset:" ) == "" 
    let linenumber = search( "^changeset:", "b" )
    if linenumber == 0
      echo "No found changesets"
      return
    endif
    let line = getline(linenumber)
  endif
  let parts = split(line,":")
  let hash = parts[2]
  return hash
endfunction


function! <SID>GetFilenameFromLog()
  let line = getline("3")
  let mx='.* - \(.*\)$'
  return substitute( line, mx, '\1', '' )
endfunction


function! <SID>ViewChangeSet( hash )
  new
  put=' // ----------'
  put=' // - Hash ' . a:hash
  put=' // ----------'
  put=''

  let se=shellescape( "Description:\\n  {firstline(desc)}\\n\\nFiles:\\n  {join(files, '\\n  ')}")
  exec ":r!hg log -r " . a:hash . " --template " . se 
  put=''
  let se=shellescape( "Description:  {firstline(desc)}\\nFiles:\\n  {join(files, '\\n  ')}")
  silent exec ":r!hg log --style compact -v -p -r " . a:hash 
  put=''
  1
  set nomod

  nnoremap <buffer> <cr> :call <SID>ViewChangeSetFromLog()<cr>
  if has("syntax") 
    syn match header              " // .*"
    highlight def link header     Statement
  endif
endfunction
  

function! <SID>ViewFileVersion( filename, hash )
  new
  put=' // ----------'
  put=' // ----------'
  put=' // - Hash ' . a:hash
  put=' // ----------'
  put=' // ----------'
  put=''

  silent exec ":r!hg cat " . a:filename . " -r " a:hash
  1
  set nomod

endfunction
  

function! <SID>GetFileName( line )
  let mx='^www/\([^:]*\):'
  let line = matchstr( a:line, mx )
  return substitute( line, mx, '\1', '' )
endfunction


function! <SID>GetLineNumber( line )
  let mx='^www/[^:]*:\([^:]*\):'
  let line = matchstr( a:line, mx )
  return substitute( line, mx, '\1', '' )
endfunction

" vim: set sw=2 ts=2 :
