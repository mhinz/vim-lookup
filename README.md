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

- Use `lookup#lookup()` to jump to the defintion of the identifier under the
  cursor.
- Use `lookup#pop()` (or the default mapping
  [`<c-o>`](https://github.com/mhinz/vim-galore/#changelist-jumplist)) to jump
  back.

### Configuration

```viml
autocmd FileType vim nnoremap <buffer><silent> <cr>  :call lookup#lookup()<cr>
```

Alternatively, you can replace the default mappings Vim uses for
[tagstack](https://neovim.io/doc/user/tagsrch.html#tag-stack) navigation:

```viml
autocmd FileType vim nnoremap <buffer><silent> <cr>  :call lookup#lookup()<cr>
autocmd FileType vim nnoremap <buffer><silent> <bs>  :call lookup#pop()<cr>
```

### Alternatives

This plugin works out-of-the-box for all Vim scripts in the runtimepath (`:h
'rtp'`). If you're a fan of tags though, you might want to use [universal
ctags](https://github.com/universal-ctags/ctags) together with one of the
numerous Vim plugins that manage tags files.
