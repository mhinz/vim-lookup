" lookup#lookup() {{{1
"
" Entry point. Map this function to your favourite keys.
"
" autocmd FileType vim nnoremap <buffer><silent> <cr> :call lookup#lookup()<cr>
"
function! lookup#lookup() abort
  let dispatch = [
        \ [function('s:find_local_var_def'), function('s:find_local_func_def')],
        \ [function('s:find_autoload_var_def'), function('s:find_autoload_func_def')]]
  let isk = &iskeyword
  setlocal iskeyword+=:,<,>,#
  let name = matchstr(getline('.'), '\k*\%'.col('.').'c\k*[("'']\?')
  let &iskeyword = isk
  let is_func = name =~ '($' ? 1 : 0
  let could_be_funcref = name =~ '[''"]$' ? 1 : 0
  let name = matchstr(name, '\v^%(s:|\<sid\>)?\zs.{-}\ze[\("'']?$')
  let is_auto = name =~ '#' ? 1 : 0
  let position = s:getcurpos()
  if !dispatch[is_auto][is_func](name) && !is_func && could_be_funcref
    let is_func = 1
    call dispatch[is_auto][is_func](name)
  endif
  let didmove = position != s:getcurpos() ? 1 : 0
  if didmove
    call s:push(position)
  endif
  normal! zv
  return didmove
endfunction

" lookup#pop() {{{1
function! lookup#pop()
  if !has_key(w:, 'lookup_stack') || empty(w:lookup_stack)
    echohl ErrorMsg
    echo "lookup stack empty"
    echohl NONE
    return
  endif
  let pos = remove(w:lookup_stack, 0)
  execute (bufexists(pos[0]) ? 'buffer' : 'edit') fnameescape(pos[0])
  call cursor(pos[1:])
endfunction

" lookup#errors() {{{1
"
" Parses errors from :messages and displays them in the quickfix window.
" Since the last error is often not the origin error, a list of consecutive
" exceptions are collected.
function! lookup#errors() abort
  let lines = reverse(s:exec_lines('silent messages'))
  if len(lines) < 3
    return
  endif

  let i = 0
  let e = 0
  let errors = []

  while i < len(lines)
    if i > 1 && lines[i] =~# '^Error detected while processing function '
          \ && lines[i-1] =~? '^line\s\+\d\+'
      let lnum = matchstr(lines[i-1], '\d\+')
      let stack = printf('%s[%d]', lines[i][41:-2], lnum)
      call add(errors, {
            \  'stack': reverse(split(stack, '\.\.')),
            \  'msg': lines[i-2],
            \ })
      let e = i
    endif

    let i += 1
    if e && i - e > 3
      break
    endif
  endwhile

  if empty(errors)
    return
  endif

  let errlist = []

  for err in errors
    let nw = len(len(err.stack))
    let i = 0
    call add(errlist, {
          \   'text': err.msg,
          \   'lnum': 0,
          \   'bufnr': 0,
          \   'type': 'E',
          \ })

    for t in err.stack
      let func = matchstr(t, '.\{-}\ze\[\d\+\]$')
      let lnum = str2nr(matchstr(t, '\[\zs\d\+\ze\]$'))

      let verb = s:exec_lines('silent! verbose function '.func)
      if len(verb) < 2
        continue
      endif

      let src = fnamemodify(matchstr(verb[1], 'Last set from \zs.\+'), ':p')
      if !filereadable(src)
        continue
      endif

      let pat = '\C^\s*fu\%[nction]!\?\s\+'
      if func =~# '^<SNR>'
        let pat .= '\%(<\%(sid\|SID\)>\|s:\)'
        let func = matchstr(func, '<SNR>\d\+_\zs.\+')
      endif
      let pat .= func.'\>'

      for line in readfile(src)
        if line =~# pat
          break
        endif
        let lnum += 1
      endfor

      if !empty(src) && !empty(func)
        let fname = fnamemodify(src, ':.')
        call add(errlist, {
              \   'text': printf('%*s. %s', nw, '#'.i, t),
              \   'filename': fname,
              \   'lnum': str2nr(lnum),
              \   'type': 'I',
              \ })
      endif

      let i += 1
    endfor
  endfor

  let s:defaults = [
        \   {
        \     'cmd': ['pbcopy', 'pbpaste'],
        \     '+': ['', ''],
        \     '*': ['', ''],
        \   },
        \   {
        \     'cmd': 'xsel',
        \     '+': ['--nodetach -i -b', '-o -b'],
        \     '*': ['--nodetach -i -p', '-o -p'],
        \   },
        \   ...
        \ ]

  if !empty(errlist)
    call setqflist(errlist, 'r')
    copen
  endif
endfunction

" s:find_local_func_def() {{{1
function! s:find_local_func_def(name) abort
  return search('\c\v<fu%[nction]!?\s+%(s:|\<sid\>)\zs\V'. a:name, 'bsw')
endfunction

" s:find_local_var_def() {{{1
function! s:find_local_var_def(name) abort
  return search('\c\v<let\s+s:\zs\V'.a:name.'\>', 'bsw')
endfunction

" s:find_autoload_func_def() {{{1
function! s:find_autoload_func_def(name) abort
  let [path, func] = split(a:name, '.*\zs#')
  let pattern = '\c\v<fu%[nction]!?\s+\zs\V'. path .'#'. func .'\>'
  return s:find_autoload_def(path, pattern)
endfunction

" s:find_autoload_var_def() {{{1
function! s:find_autoload_var_def(name) abort
  let [path, var] = split(a:name, '.*\zs#')
  let pattern = '\c\v<let\s+\zs\V'. path .'#'. var .'\>'
  return s:find_autoload_def(path, pattern)
endfunction

" s:find_autoload_def() {{{1
function! s:find_autoload_def(name, pattern) abort
  let path = printf('autoload/%s.vim', substitute(a:name, '#', '/', 'g'))
  let aufiles = globpath(&runtimepath, path, '', 1)
  if empty(aufiles) && exists('b:git_dir')
    let aufiles = [fnamemodify(b:git_dir, ':h') .'/'. path]
  endif
  if empty(aufiles)
    return search(a:pattern)
  else
    for file in aufiles
      if !filereadable(file)
        continue
      endif
      let lnum = match(readfile(file), a:pattern)
      if lnum > -1
        execute 'edit +'. (lnum+1) fnameescape(file)
        call search(a:pattern)
        return 1
        break
      endif
    endfor
  endif
  return 0
endfunction

" s:push() {{{1
function! s:push(position) abort
  if !has_key(w:, 'lookup_stack') || empty(w:lookup_stack)
    let w:lookup_stack = [a:position]
    return
  endif
  if w:lookup_stack[0] != a:position
    call insert(w:lookup_stack, a:position)
  endif
endfunction

" s:getcurpos() {{{1
function! s:getcurpos() abort
  return [expand('%:p')] + getcurpos()[1:]
endfunction

" s:exec_lines() {{{1
function! s:exec_lines(cmd) abort
  if exists('*execute')
    return split(execute(a:cmd), "\n")
  endif

  redir => output
  execute a:cmd
  redir END
  return split(output, "\n")
endfunction

" }}}
" vim: set ft=vim fdm=marker ts=2 sw=2 et :
