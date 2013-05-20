
"
" Plugin for integration with Mercurial
"
" Maintainer: Jason McHugh <mchughj@fb.com>
" Created: 2013 Mar 25
" Last updated: 2013 May 20

" See the doc file for information about this file.

" ----------------------------------------------------------------
" Maps
" ----------------------------------------------------------------
nmap <Leader>hd :call <SID>ShowFileDiffs()<CR>
nmap <Leader>hl :call <SID>ShowLog()<CR>
nmap <Leader>ht :call <SID>ShowTipInfo()<CR>
nmap <Leader>hb :call <SID>ShowBookmarks()<CR>
nmap <Leader>hc :call <SID>ShowChangesetDiffs()<CR>


" The following are convenience functions that are useful mostly
" during development.  They are defined only when you are running a debug 
" environment.

if exists("g:hg_easy_debug")
  nmap <Leader>he :edit ~/.vim/bundle/vim-mercurial/plugin/hg.vim<CR>
  nmap <Leader>hE :new ~/.vim/bundle/vim-mercurial/plugin/hg.vim<CR>
  nmap <Leader>hs :source ~/.vim/bundle/vim-mercurial/plugin/hg.vim<CR>
endif


if !exists("g:hg_change_set_template")
  let g:hg_change_set_template = "Description:\\n  {firstline(desc)}\\n\\nFiles:\\n  {join(files, '\\n  ')}"
end


if !exists("g:hg_default_root_revision")
  let g:hg_default_root_revision = "master"
end


function! <SID>ClearDiffSettings()
  set nofoldenable
  set foldcolumn=0
  set nodiff
  diffoff!
endfunction


function! <SID>ShowChangesetDiffs()
  new
  put=' // -------'
  put=' // Diffs between tip and '. g:hg_default_root_revision
  put=' // -------'
  put=''
  let se=shellescape( g:hg_change_set_template )
  exec ":r!hg diff -r . -r " . g:hg_default_root_revision
  1
  d
  set nomod
  set nolist
  set nonu
  set filetype=diff
endfunction


function! <SID>ShowFileDiffs()
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
  put=' // -------'
  put=' // The tip'
  put=' // -------'
  put=''
  let se=shellescape( g:hg_change_set_template )
  exec ":r!hg log -r. --template " . se 
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
  let file_type = &filetype
  new
  silent exec ":r!hg log " . filename 
  put=''
  1
  let b:file_type = file_type

  put=' // ----------'
  put=' // - ' . filename
  put=' // ----------'
  put=''
  put='Put your cursor anywhere inside of a changeset description and then:'
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
  let file_type = b:file_type
  let filename = s:GetFilenameFromLog()
  let changeset = s:GetChangeSetAtOrAboveCursor()

  call <SID>ViewFileVersion(filename,changeset,file_type)
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

  let se=shellescape( g:hg_change_set_template )
  exec ":r!hg log -r " . a:hash . " --template " . se 
  put=''
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
  

function! <SID>ViewFileVersion( filename, hash, file_type )
  new
  put=' /// ----------'
  put=' /// ----------'
  put=' /// - Hash ' . a:hash
  put=' /// ----------'
  put=' /// ----------'
  put=''

  silent exec ":r!hg cat " . a:filename . " -r " a:hash
  1
  set nomod

  exec ":set filetype=".a:file_type
  if has("syntax") 
    syn match hg_header              " /// -.*"
    highlight def link hg_header     Error
  endif

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
