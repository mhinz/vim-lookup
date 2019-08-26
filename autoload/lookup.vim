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
  let name = matchstr(name, '\c\v^%(s:|\<sid\>)?\zs.{-}\ze[\("'']?$')
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

" s:find_local_func_def() {{{1
function! s:find_local_func_def(funcname) abort
  if search('\c\v<fu%[nction]!?\s+%(s:|\<sid\>)\zs\V'.a:funcname.'\>', 'bsw') != 0
    return
  endif

  let lang = v:lang
  language message C
  redir => funcloc
    silent! execute 'verbose function' a:funcname
  redir END
  silent! execute 'language message' lang
  if funcloc =~# 'E\d\{2,3}:'
    return
  endif

  let file = substitute(split(funcloc, '\n')[1], '.*Last set from \ze', '', '')
  let file = substitute(file, ' line [0-9]\+$', '', 'g')
  execute 'edit' file

  let fn = substitute(a:funcname, '^g:', '', '')
  call search('\c\v<fu%[nction]!?\s+%(g:)?\zs\V'.fn.'\>', 'bsw')
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
