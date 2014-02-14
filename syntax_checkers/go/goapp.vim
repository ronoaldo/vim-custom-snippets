"============================================================================
"File:        goapp.vim
"Description: Check go syntax using 'gofmt -l' followed by
"             'goapp [build|test]'. 'goapp' is used to allow the appengien/*
"             packages to be found and use the standad go syntax checker from
"             syntastic.
"Maintainer:  Kamil Kisiel <kamil@kamilkisiel.net>
"             Ronoaldo JLP <ronoaldo@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" This syntax checker does not reformat your source code.
" Use a BufWritePre autocommand to that end:
"   autocmd FileType go autocmd BufWritePre <buffer> Fmt
"============================================================================

if exists("g:loaded_syntastic_go_goapp_checker")
    finish
endif
let g:loaded_syntastic_go_goapp_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_go_goapp_IsAvailable() dict
    return executable('goapp') && executable('gofmt')
endfunction

function! SyntaxCheckers_go_goapp_GetLocList() dict
    " Check with gofmt first, since `go build` and `go test` might not report
    " syntax errors in the current file if another file with syntax error is
    " compiled first.
    let makeprg = self.makeprgBuild({
        \ 'exe': 'gofmt',
        \ 'args': '-l',
        \ 'tail': '> ' . syntastic#util#DevNull() })

    let errorformat =
        \ '%f:%l:%c: %m,' .
        \ '%-G%.%#'

    let errors = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'type': 'e'} })
    if !empty(errors)
        return errors
    endif

    " Test files, i.e. files with a name ending in `_test.go`, are not
    " compiled by `go build`, therefore `goapp test` must be called for those.
    if match(expand('%'), '\m_test\.go$') == -1
        let makeprg = 'goapp build ' . syntastic#c#NullOutput()
        let cleanup = 0
    else
        let makeprg = 'goapp test -c ' . syntastic#c#NullOutput()
        let cleanup = 1
    endif

    let errorformat =
        \ '%E%f:%l:%c:%m,' .
        \ '%E%f:%l:%m,' .
        \ '%C%\s%\+%m,' .
        \ '%-G#%.%#'

    " The go compiler needs to either be run with an import path as an
    " argument or directly from the package directory. Since figuring out
    " the proper import path is fickle, just cwd to the package.

    let errors = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'cwd': expand('%:p:h'),
        \ 'defaults': {'type': 'e'} })

    if cleanup
        call delete(expand('%:p:h') . syntastic#util#Slash() . expand('%:p:h:t') . '.test')
    endif

    return errors
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'go',
    \ 'name': 'goapp'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
