[![Build Status](https://travis-ci.org/mhinz/vim-lookup.svn?branch=master)](https://travis-ci.org/mhinz/vim-lookup)

# vim-lookup

This plugin is meant for VimL programmers. It knows how to jump to the
definitions of script-local and autoload variables or functions:

- [x] `s:var`
- [x] `s:func()`
- [x] `<sid>func()`
- [x] `autoload#foo#var`
- [x] `autoload#foo#func()`

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
