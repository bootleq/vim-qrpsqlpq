let s:save_cpo = &cpoptions
set cpoptions&vim

let s:hook = {
      \   'name': 'psql_pack',
      \   'kind': 'hook',
      \   'config': {
      \     'enable': 0,
      \     'output_expanded': 'off'
      \   }
      \ }


function! s:hook.on_output(session, context) "{{{
  if self.config.enable
    let text      = a:context.data
    let buffer_nr = winnr('$')

    if get(self.config, 'output_expanded') != 'off'
      " Add blank line between records
      " Prefix padding to each column
      let title_pattern = '-\[ RECORD \d\+ \]-[^\n]\+'
      let lines = []
      for line in split(text, '\n')
        if line =~ title_pattern
          if line =~ 'RECORD 1 '
            let line = "-"   . line
          else
            let line = "\n-" . line
          endif
        else
          let line = ' ' . line
        endif
        call add(lines, line)
      endfor
      unlet line
      let a:context.data = join(lines, "\n")

      " Narrow down window width to release unused space
      let last_col = len(matchstr(text, title_pattern))
      if last_col && last_col < winwidth(buffer_nr)
        execute buffer_nr . 'wincmd w'
        execute 'vertical resize ' . (last_col + 1)
        wincmd p
      endif

    endif
  endif
endfunction "}}}


function! s:hook.on_outputter_buffer_opened(session, context) "{{{
  if self.config.enable
    setlocal nonumber nowrap sidescrolloff=0
    nnoremap <buffer> <Leader>r <Nop>

    command! -buffer PGExplanTimeFormat call <SID>postgres_explan_time_format()

    if get(self.config, 'output_expanded') != 'off'
      augroup quickrun_psql_pack_augroup
        autocmd! Syntax <buffer> call quickrun_psql_pack#quickrun_sql_after_output_syntax()
      augroup END
    endif
  endif
endfunction "}}}


function! quickrun#hook#psql_pack#new() abort "{{{
  return deepcopy(s:hook)
endfunction "}}}


let &cpoptions = s:save_cpo
unlet s:save_cpo
