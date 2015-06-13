" Main Functions: {{{

function! qrpsqlpq#run(...) "{{{
  let method = a:0 ? a:1 : 'last'
  if method == 'last'
    let method = get(s:, 'qrpsqlpq_last_run_method', 'split')
  endif

  let b:qrpsqlpq_db = get(b:, 'qrpsqlpq_db', '')
  let split  = ''
  let cmdopt = ''

  if empty(b:qrpsqlpq_db)
    if !exists('b:rails_root')
      call RailsDetect()
    endif
    if exists('b:rails_root')
      let b:qrpsqlpq_db = rails#app().db_config('development').database
    endif
  endif
  if empty(b:qrpsqlpq_db)
    echohl WarningMsg | echomsg "Missing database config." | echohl None
    return
  endif

  let cmdopt = '-d ' . b:qrpsqlpq_db . ' -P pager=off -P format=wrapped -P expanded=auto'

  call qrpsqlpq#quit_winodws_by_filetype('^quickrun') " close previous output buffer

  if method == 'split'
    let s:qrpsqlpq_last_run_method = method
    let split = 'silent botright 16split'
  elseif method == 'vsplit'
    let s:qrpsqlpq_last_run_method = method
    let split = 'silent botright 78vsplit'
    let cmdopt .= ' -P columns=78'
  else
    echohl WarningMsg | echomsg "Unknown qrpsqlpq run method." | echohl None
  endif

  execute printf(
        \   "QuickRun -cmdopt '%s' -outputter/buffer/split '%s' %s",
        \   cmdopt,
        \   split,
        \   method == 'vsplit' ? '-hook/qrpsqlpq/output_expanded auto' : ''
        \ )
endfunction  "}}}

" }}} Main Functions


" Utils: {{{

function! qrpsqlpq#quit_winodws_by_filetype(...) "{{{
  let win_count = winnr('$')
  for pattern in a:000
    silent windo if &filetype =~ pattern | execute "quit" | endif
  endfor
  execute 'wincmd t'
  return win_count > winnr('$')
endfunction "}}}


function! qrpsqlpq#after_output_syntax() "{{{
  syntax match SQL_RECORD_HEADER /\v-*\[ RECORD \d+ \].*/
  highlight link SQL_RECORD_HEADER Title
  setlocal foldmethod=expr foldlevel=1 foldexpr=qrpsqlpq#expanded_output_fold_level(v:lnum)
  augroup qrpsqlpq_augroup
    autocmd!
  augroup END
endfunction "}}}


function! qrpsqlpq#expanded_output_fold_level(line) "{{{
  let title_pattern = '\v-*\[ RECORD \d+ \].*'
  if  getline(a:line - 1) =~ title_pattern
    return '>1'
  elseif getline(a:line + 1) =~ title_pattern
    return '<1'
  else
    return '='
  endif
endfunction "}}}

" }}} Utils
