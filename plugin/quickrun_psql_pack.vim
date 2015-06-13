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
          \   'outputter/buffer/name': '[QR] %{expand("%:t")}  \@%{strftime("%T")}'
          \ }
    nmap <buffer> <Leader>r [quickrun]
    nnoremap <silent> <buffer> [quickrun]j :call <SID>quickrun_sql_run('j')<CR>
    nnoremap <silent> <buffer> [quickrun]l :call <SID>quickrun_sql_run('l')<CR>
    nnoremap <silent> <buffer> [quickrun]r :call <SID>quickrun_sql_run('last')<CR>
  endfunction "}}}

  let s:hook = {
        \   'name': 'psql_extra',
        \   'kind': 'hook',
        \   'config': {
        \     'enabled': 1
        \   }
        \ }

  function! s:hook.on_output(session, context) "{{{
    if self.config.enabled
      let text      = a:context.data
      let cmdopt    = get(a:session.config, 'cmdopt', '')
      let buffer_nr = winnr('$')

      if !empty(cmdopt)
        if get(t:, 'quickrun_psql_expanded_format')
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
    endif
  endfunction "}}}

  function! s:hook.on_outputter_buffer_opened(session, context) "{{{
    if self.config.enabled
      setlocal nonumber nowrap sidescrolloff=0
      nnoremap <buffer> <Leader>r <Nop>

      command! -buffer PGExplanTimeFormat call <SID>postgres_explan_time_format()

      if get(t:, 'quickrun_psql_expanded_format')
        augroup my_vimrc_quickrun_psql
          autocmd! Syntax <buffer> call <SID>quickrun_sql_after_output_syntax()
        augroup END
      endif
    endif
  endfunction "}}}

  call quickrun#module#register(s:hook, 1)
  unlet s:hook

  function! s:quickrun_sql_after_output_syntax() "{{{
    syntax match SQL_RECORD_HEADER /\v-*\[ RECORD \d+ \].*/
    highlight link SQL_RECORD_HEADER Title
    setlocal foldmethod=expr foldlevel=1 foldexpr=PsqlExpandOutputFoldLevel(v:lnum)
    augroup my_vimrc_quickrun_psql
      autocmd!
    augroup END
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
