if exists('g:loaded_qrpsqlpq')
  finish
endif
let g:loaded_qrpsqlpq = 1
let s:save_cpo = &cpoptions
set cpoptions&vim


" Setup: {{{

if executable('psql')
  function! s:quickrun_sql_config() "{{{
    let g:quickrun_config['sql'] = {
          \   'outputter/buffer/into': 0,
          \   'hook/qrpsqlpq/enable': 1,
          \   'outputter/buffer/name': '[QR] %{expand("%:t")}  \@%{strftime("%T")}'
          \ }
    nmap <buffer> <Leader>r [quickrun]
    nnoremap <silent> <buffer> [quickrun]j :call <SID>quickrun_sql_run('j')<CR>
    nnoremap <silent> <buffer> [quickrun]l :call <SID>quickrun_sql_run('l')<CR>
    nnoremap <silent> <buffer> [quickrun]r :call <SID>quickrun_sql_run('last')<CR>
  endfunction "}}}

  function! s:quickrun_sql_run(method) "{{{
    let method = a:method == 'last' ? get(s:, 'qrpsqlpq_last_run_method', 'j') : a:method
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

    if method == 'j'
      let s:qrpsqlpq_last_run_method = method
      let split = 'silent botright 16split'
    elseif method == 'l'
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
          \   method == 'l' ? '-hook/qrpsqlpq/output_expanded auto' : ''
          \ )
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
