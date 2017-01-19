# vim-lookup

This plugin exposes a single function that knows how to jump to the definitions
of:

1. `s:func()`
1. `<sid>func()`
1. `autoload#func()`

If you touch VimL code from time to time, you want this plugin. Just map it to
your favourite keys, e.g.

```viml
autocmd FileType vim nnoremap <buffer><silent> <cr> :call lookup#lookup()<cr>
```

Afterwards just hit `<cr>` somewhere over the name of a variable or function to
jump to its definition.
