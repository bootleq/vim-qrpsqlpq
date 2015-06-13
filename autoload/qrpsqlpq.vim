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
