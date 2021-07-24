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
  endif
endfunction "}}}


function! s:hook.on_success(session, context) "{{{
  if self.config.enable
    call s:jump_to_output_window()

    if qrpsqlpq#detect_explain_output()
      call s:discard_running_mark()
      call qrpsqlpq#format_explain_output()
    endif

    execute printf(
          \   'call qrpsqlpq#after_output_syntax(%s)',
          \   (get(self.config, 'output_expanded') != 'off' ? '"expanded"' : '')
          \ )

    wincmd p
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
  let threshold   = get(g:, 'qrpsqlpq_expanded_format_max_lines', 10000)
  let input_lines = split(a:context.data, '\n')
  if threshold != -1 && len(input_lines) > threshold
    return
  endif

  let lines = []
  let title_pattern = '-\[ RECORD \d\+ \]-[^\n]\+'

  for line in input_lines
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


function! s:jump_to_output_window() abort "{{{
  let winnr = winnr('$')
  execute winnr . 'wincmd w'
endfunction "}}}


function! s:discard_running_mark() abort "{{{
  if exists('b:quickrun_running_mark')
    silent undo
    unlet b:quickrun_running_mark
  endif
endfunction "}}}

" }}} Helper Functions


let &cpoptions = s:save_cpo
unlet s:save_cpo
