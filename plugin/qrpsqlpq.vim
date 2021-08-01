if exists('g:loaded_qrpsqlpq')
  finish
endif
let g:loaded_qrpsqlpq = 1
let s:save_cpo = &cpoptions
set cpoptions&vim


" Setup: {{{

if !exists('g:quickrun_config')
  let g:quickrun_config = {}
endif

if !exists('g:quickrun_config["sql/qrpsqlpq"]')
  let g:quickrun_config['sql/qrpsqlpq'] = {}
endif

call extend(
      \ g:quickrun_config['sql/qrpsqlpq'],
      \ {
      \   'command': 'psql',
      \   'exec': ['%c %o -f %s'],
      \   'outputter/buffer/into': 0,
      \   'hook/qrpsqlpq/enable': 1
      \ },
      \ 'keep')

" }}} Setup


" Finish:  {{{

let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}} Finish


" modeline {{{
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
