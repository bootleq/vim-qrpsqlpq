" Main Functions: {{{

function! qrpsqlpq#run(...) "{{{
  let method = a:0 ? a:1 : 'last'
  if method == 'last'
    let method = get(s:, 'qrpsqlpq_last_run_method', 'split')
  endif

  let db_name = s:get_db_name()
  let split   = ''
  let cmdopt  = ''

  if empty(db_name)
    echohl WarningMsg | echomsg "Missing database config." | echohl None
    return
  endif

  let cmdopt = '-d ' . db_name . ' -P pager=off -P format=wrapped -P expanded=auto'

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
        \   "QuickRun -type sql/qrpsqlpq -cmdopt '%s' -outputter/buffer/split '%s' %s",
        \   cmdopt,
        \   split,
        \   method == 'vsplit' ? '-hook/qrpsqlpq/output_expanded auto' : ''
        \ )
endfunction  "}}}

" }}} Main Functions


" Utils: {{{

function! s:get_db_name() "{{{
  let name = get(
        \   b:,
        \   'qrpsqlpq_db_name',
        \   get(g:, 'qrpsqlpq_db_name', '')
        \ )

  if empty(name)
    if exists('*RailsDetect')
      if !exists('b:rails_root')
        call RailsDetect()
      endif
      if exists('b:rails_root')
        let name = rails#app().db_config('development').database
      endif
    endif
  endif

  return name
endfunction "}}}


function! qrpsqlpq#detect_explain_output() "{{{
  return search('\v^\s+QUERY PLAN\s*$', 'npw')
endfunction "}}}


function! qrpsqlpq#quit_winodws_by_filetype(...) "{{{
  let win_count = winnr('$')
  for pattern in a:000
    silent windo if &filetype =~ pattern | execute "quit" | endif
  endfor
  execute 'wincmd t'
  return win_count > winnr('$')
endfunction "}}}


function! qrpsqlpq#after_output_syntax(...) "{{{
  let context = a:0 ? a:1 : ''

  if qrpsqlpq#detect_explain_output()
    let context = 'explain'
  endif

  if context == 'expanded'
    syntax match SQL_RECORD_HEADER /\v-*\[ RECORD \d+ \].*/
    highlight link SQL_RECORD_HEADER Title
    setlocal foldmethod=expr foldlevel=1 foldexpr=qrpsqlpq#expanded_output_fold_level(v:lnum)
  elseif context == 'explain'
    syntax match qrpsqlpqExplainCost /\v\(COST: \d+\.\d+\)/
    syntax match qrpsqlpqExplainActual /\v\(ACTUAL: \d+\.\d+\)/
    syntax match qrpsqlpqExplainCostDigit /\v[0-9.]+/ containedin=qrpsqlpqExplainCost contained
    syntax match qrpsqlpqExplainActualDigit /\v[0-9.]+/ containedin=qrpsqlpqExplainActual contained
    highlight link qrpsqlpqExplainCostDigit Statement
    highlight link qrpsqlpqExplainActualDigit Identifier
  endif
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


function! qrpsqlpq#format_explain_output() "{{{
  " Show SQL EXPLAIN ANALYZE time as 'time difference'
  execute '%substitute/' .
        \ '\v(cost|actual\_s+%(\.\n \.)?time)\=' .
        \   '(\_[0-9. ]+)' .
        \   'rows' .
        \   '\_[^\)]+' .
        \ '/\=s:explain_time_replacer()' .
        \ '/ge'
endfunction "}}}


function! s:explain_time_replacer() "{{{
  let [column, time_expr] = [submatch(1), submatch(2)]

  let column = matchstr(column, '\v\w+')
  let time_expr  = substitute(time_expr,  '\v\.\n \.', '', '')  " psql might wrap long line with '.\n .'
  let [begin, end] = split(time_expr, '\V..')

  return printf(
        \   '%s: %s',
        \   toupper(column),
        \   string(str2float(end) - str2float(begin))
        \ )
endfunction "}}}

" }}} Utils
