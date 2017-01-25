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

No tags file needed. It simply uses your
[runtimepath](https://neovim.io/doc/user/options.html#'rtp').

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
autocmd FileType vim nnoremap <buffer><silent> <c-]>  :call lookup#lookup()<cr>
autocmd FileType vim nnoremap <buffer><silent> <c-t>  :call lookup#pop()<cr>
```

### Alternatives

If you're a fan of tags, you might want to use [universal
ctags](https://github.com/universal-ctags/ctags) to generate a proper tags file
for your Vim scripts first and then use it together with one of the numerous Vim
plugins that manage tags files.
