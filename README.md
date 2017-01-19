# vim-lookup

This plugin knows how to jump to definitions in a Vim buffer:

1. **script-local variables**: _s:var_
1. **script-local functions**: _s:func()_, _<sid>func()_
1. **autoload functions**: _autoload#func()_

### Usage

The plugin exposes only a single function that should be mapped to your
favourite keys, e.g.

```viml
autocmd FileType vim nnoremap <buffer><silent> <cr>  :call lookup#lookup()<cr>
```

Afterwards just hit `<cr>` somewhere over the name of a variable or function to
jump to its definition.

In ambiguous cases, `<cr>` will cycle through all occurrences. This is done on
purpose. If you want a list of all occurences, have a look at plugins like
[vim-grepper](https://github.com/mhinz/vim-grepper) instead.
