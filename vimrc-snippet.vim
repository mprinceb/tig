" >>> gitlens-tui >>>
" gitlens-tui block managed by install.sh.
" Uninstall guidance: delete this block, including marker lines.
function! s:GitlensCurrentFile() abort
  let l:file = expand('%:p')
  if empty(l:file)
    echohl WarningMsg | echom 'TigFile/TigBlame: buffer has no file path.' | echohl None
    return ''
  endif
  if !filereadable(l:file)
    echohl WarningMsg | echom 'TigFile/TigBlame: file is not readable on disk.' | echohl None
    return ''
  endif
  return l:file
endfunction

function! s:GitlensRun(cmd) abort
  if exists(':terminal') == 2
    execute 'terminal ' . a:cmd
  else
    execute 'silent !' . a:cmd
    redraw!
  endif
endfunction

function! s:GitlensTigFile() abort
  let l:file = s:GitlensCurrentFile()
  if empty(l:file)
    return
  endif
  call s:GitlensRun('tig -- ' . shellescape(l:file))
endfunction

function! s:GitlensTigBlame() abort
  let l:file = s:GitlensCurrentFile()
  if empty(l:file)
    return
  endif
  call s:GitlensRun('tig blame -- ' . shellescape(l:file))
endfunction

function! s:GitlensTigGrep(query) abort
  if empty(a:query)
    call s:GitlensRun('tig grep')
    return
  endif
  call s:GitlensRun('tig grep -- ' . shellescape(a:query))
endfunction

if exists(':TigFile') == 0
  command! -bar TigFile call s:GitlensTigFile()
endif

if exists(':TigBlame') == 0
  command! -bar TigBlame call s:GitlensTigBlame()
endif

if exists(':TigStatus') == 0
  command! -bar TigStatus call s:GitlensRun('tig status')
endif

if exists(':TigRefs') == 0
  command! -bar TigRefs call s:GitlensRun('tig refs')
endif

if exists(':TigReflog') == 0
  command! -bar TigReflog call s:GitlensRun('tig reflog')
endif

if exists(':TigLog') == 0
  command! -bar TigLog call s:GitlensRun('tig')
endif

if exists(':TigGrep') == 0
  command! -bar -nargs=* TigGrep call s:GitlensTigGrep(<q-args>)
endif

if maparg('<leader>gh', 'n') ==# ''
  nnoremap <silent> <leader>gh :TigFile<CR>
endif

if maparg('<leader>gb', 'n') ==# ''
  nnoremap <silent> <leader>gb :TigBlame<CR>
endif

if maparg('<leader>gs', 'n') ==# ''
  nnoremap <silent> <leader>gs :TigStatus<CR>
endif

if maparg('<leader>gr', 'n') ==# ''
  nnoremap <silent> <leader>gr :TigRefs<CR>
endif

if maparg('<leader>gR', 'n') ==# ''
  nnoremap <silent> <leader>gR :TigReflog<CR>
endif

if maparg('<leader>gl', 'n') ==# ''
  nnoremap <silent> <leader>gl :TigLog<CR>
endif

if maparg('<leader>gg', 'n') ==# ''
  nnoremap <silent> <leader>gg :TigGrep<CR>
endif
" <<< gitlens-tui <<<
