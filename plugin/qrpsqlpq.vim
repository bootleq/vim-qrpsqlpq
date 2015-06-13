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
