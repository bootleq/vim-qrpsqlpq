" Utils: {{{

function! quickrun_psql_pack#quit_winodws_by_filetype(...) "{{{
  let win_count = winnr('$')
  for pattern in a:000
    silent windo if &filetype =~ pattern | execute "quit" | endif
  endfor
  execute 'wincmd t'
  return win_count > winnr('$')
endfunction "}}}

" }}} Utils
