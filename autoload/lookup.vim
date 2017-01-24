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
  let name = matchstr(getline('.'), '\k*\%'.col('.').'c\k*(\=')
  let &iskeyword = isk
  let is_func = name  =~ '($' ? 1 : 0
  let name = matchstr(name, '\v^%(s:|\<sid\>)?\zs.{-}\ze\(?$')
  let is_auto = name =~ '#' ? 1 : 0
  call dispatch[is_auto][is_func](name)
  normal! zv
endfunction

function! s:find_local_func_def(name) abort
  call search('\c\v<fu%[nction]!?\s+%(s:|\<sid\>)\zs\V'. a:name, 'bsw')
endfunction

function! s:find_local_var_def(name) abort
  call search('\c\v<let\s+s:\zs\V'.a:name.'\>', 'bsw')
endfunction

function! s:find_autoload_func_def(name) abort
  let [path, func] = split(a:name, '.*\zs#')
  let pattern = '\c\v<fu%[nction]!?\s+\zs\V'. path .'#'. func .'\>'
  call s:find_autoload_def(path, pattern)
endfunction

function! s:find_autoload_var_def(name) abort
  let [path, var] = split(a:name, '.*\zs#')
  let pattern = '\c\v<let\s+\zs\V'. path .'#'. var .'\>'
  call s:find_autoload_def(path, pattern)
endfunction

function! s:find_autoload_def(name, pattern) abort
  let path = printf('autoload/%s.vim', substitute(a:name, '#', '/', 'g'))
  let aufiles = globpath(&runtimepath, path, '', 1)
  if empty(aufiles) && exists('b:git_dir')
    let aufiles = [fnamemodify(b:git_dir, ':h') .'/'. path]
  endif
  if empty(aufiles)
    call search(a:pattern)
  else
    for file in aufiles
      if !filereadable(file)
        continue
      endif
      let lnum = match(readfile(file), a:pattern)
      if lnum > -1
        execute 'edit +'. (lnum+1) file
        call search(a:pattern)
        break
      endif
    endfor
  endif
endfunction
