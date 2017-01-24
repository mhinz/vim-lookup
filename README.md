[![Build Status](https://travis-ci.org/mhinz/vim-lookup.svg?branch=master)](https://travis-ci.org/mhinz/vim-lookup)

# vim-lookup

This plugin is meant for VimL programmers. It knows how to jump to the
definitions of script-local and autoload variables or functions:

- [x] `s:var`
- [x] `s:func()`
- [x] `<sid>func()`
- [x] `autoload#foo#var`
- [x] `autoload#foo#func()`
- [x] `'autoload#foo#func'`

### Usage

The plugin exposes only a single function that should be mapped to your
favourite keys, e.g.

```viml
autocmd FileType vim nnoremap <buffer><silent> <cr>  :call lookup#lookup()<cr>
```

Afterwards just hit `<cr>` somewhere over the name of a variable or function to
jump to its definition.

In ambiguous cases, `<cr>` will cycle through all occurrences. This is done on
purpose. If you want a list of all occurences, have a look at `:h [I` or plugins
like [vim-grepper](https://github.com/mhinz/vim-grepper) instead.

### Alternatives

This plugin works for out-of-the-box for all Vim scripts in the runtimepath (`:h
'rtp'`). If you're a fan of tags though, you might want to use [universal
ctags](https://github.com/universal-ctags/ctags) together with one of the
numerous Vim plugins that manage tags files.
