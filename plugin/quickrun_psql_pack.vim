if exists('g:loaded_quickrun_psql_pack')
  finish
endif
let g:loaded_quickrun_psql_pack = 1
let s:save_cpo = &cpoptions
set cpoptions&vim


" Setup: {{{

if executable('psql')
  function! s:quickrun_sql_config() "{{{
    let g:quickrun_config['sql'] = {
          \   'outputter/buffer/into': 0,
          \   'hook/psql_pack/enable': 1,
          \   'outputter/buffer/name': '[QR] %{expand("%:t")}  \@%{strftime("%T")}'
          \ }
    nmap <buffer> <Leader>r [quickrun]
    nnoremap <silent> <buffer> [quickrun]j :call <SID>quickrun_sql_run('j')<CR>
    nnoremap <silent> <buffer> [quickrun]l :call <SID>quickrun_sql_run('l')<CR>
    nnoremap <silent> <buffer> [quickrun]r :call <SID>quickrun_sql_run('last')<CR>
  endfunction "}}}

  function! s:quickrun_sql_run(method) "{{{
    let method = a:method == 'last' ? get(s:, 'quickrun_sql_run_last_method', 'j') : a:method
    let b:quickrun_db_name = get(b:, 'quickrun_db_name', '')
    let split  = ''
    let cmdopt = ''

    if empty(b:quickrun_db_name)
      if !exists('b:rails_root')
        call RailsDetect()
      endif
      if exists('b:rails_root')
        let b:quickrun_db_name = rails#app().db_config('development').database
      endif
    endif
    if empty(b:quickrun_db_name)
      echohl WarningMsg | echomsg "Missing database config." | echohl None
      return
    endif

    let cmdopt = '-d ' . b:quickrun_db_name . ' -P pager=off -P format=wrapped -P expanded=auto'

    call quickrun_psql_pack#quit_winodws_by_filetype('^quickrun') " close previous output buffer

    if method == 'j'
      let s:quickrun_sql_run_last_method = method
      let split = 'silent botright 16split'
    elseif method == 'l'
      let s:quickrun_sql_run_last_method = method
      let split = 'silent botright 78vsplit'
      let cmdopt .= ' -P columns=78'
      let t:quickrun_psql_expanded_format = 1 " NOTE: didn't detect really output with expanded format
    else
      echohl WarningMsg | echomsg "Unknown quickrun helper run method." | echohl None
    endif

    execute printf(
          \   "QuickRun -cmdopt '%s' -outputter/buffer/split '%s'",
          \   cmdopt,
          \   split
          \ )

    unlet! t:quickrun_psql_expanded_format
  endfunction "}}}

  autocmd FileType sql call s:quickrun_sql_config()
endif

" }}} Setup


" Finish:  {{{

let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}} Finish


" modeline {{{
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
