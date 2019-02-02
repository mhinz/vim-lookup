[![Build Status](https://travis-ci.org/mhinz/vim-lookup.svg?branch=master)](https://travis-ci.org/mhinz/vim-lookup)

# vim-lookup
> An forked repo which is based on SpaceVim API.

This plugin is meant for VimL programmers. It jumps to definitions of variables
or functions even when they're in other files:

- [x] `s:var`
- [x] `s:func()`
- [x] `<sid>func()`
- [x] `autoload#foo#var`
- [x] `autoload#foo#func()`
- [x] `'autoload#foo#func'`

No tags file needed. It simply uses your
[runtimepath](https://neovim.io/doc/user/options.html#'rtp').

It also works for global functions if they're defined or found in the current
file:

- [x] `GlobalFunc()`
- [x] `g:GlobalFunc()`

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

### Other useful VimL plugins

- [exception.vim](https://github.com/tweekmonster/exception.vim)
- [helpful.vim](https://github.com/tweekmonster/helpful.vim)
- [vim-scriptease](https://github.com/tpope/vim-scriptease)
