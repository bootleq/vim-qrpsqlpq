let s:save_cpo = &cpoptions
set cpoptions&vim

let s:hook = {
      \   'name': 'qrpsqlpq',
      \   'kind': 'hook',
      \   'config': {
      \     'enable': 0,
      \     'output_expanded': 'off'
      \   }
      \ }


function! s:hook.on_output(session, context) "{{{
  if self.config.enable
    if get(self.config, 'output_expanded') != 'off'
      call s:format_expanded_output(a:context)
      call s:resize_expanded_window(a:context)
    endif
  endif
endfunction "}}}


function! s:hook.on_outputter_buffer_opened(session, context) "{{{
  if self.config.enable
    setlocal nonumber nowrap sidescrolloff=0

    " unmap <plug>(quickrun) FIXME: should not involved with this plugin
    nnoremap <buffer> <Leader>r <Nop>

    " FIXME: no implementation
    " command! -buffer PGExplanTimeFormat call <SID>postgres_explan_time_format()

    if get(self.config, 'output_expanded') != 'off'
      augroup qrpsqlpq_augroup
        autocmd! Syntax <buffer> call qrpsqlpq#after_output_syntax()
      augroup END
    endif
  endif
endfunction "}}}


function! quickrun#hook#qrpsqlpq#new() abort "{{{
  return deepcopy(s:hook)
endfunction "}}}


" Helper Functions: {{{

function! s:resize_expanded_window(context) "{{{
  let text = a:context.data
  let output_width = len(matchstr(text, '\v-*\[ RECORD 1 \]-[^\n]+'))
  let output_buffer = winnr('$')

  if output_width && output_width < winwidth(output_buffer)
    execute output_buffer . 'wincmd w'
    execute 'vertical resize ' . (output_width)
    wincmd p
  endif
endfunction "}}}


function! s:format_expanded_output(context) "{{{
  let lines = []
  let title_pattern = '-\[ RECORD \d\+ \]-[^\n]\+'

  for line in split(a:context.data, '\n')
    if line =~ title_pattern
      " Add blank line between records
      if line =~ 'RECORD 1 '
        let line =   "-" . line
      else
        let line = "\n-" . line
      endif
    else
      " Prefix padding to each column
      let line = ' ' . line
    endif
    call add(lines, line)
  endfor
  let a:context.data = join(lines, "\n")
endfunction "}}}

" }}} Helper Functions


let &cpoptions = s:save_cpo
unlet s:save_cpo
