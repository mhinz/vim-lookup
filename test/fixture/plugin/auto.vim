function! Foo(...)
endfunction

call Foo(auto#foo#var,v:lang)
call Foo(auto#foo#func())
" silent! echomsg auto#foo#var
" silent! echomsg auto#foo#func()
