if exists('g:loaded_textobj_verbatimstring')
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

call textobj#user#plugin('verbatimstring', {
    \ '-' : {
    \        '*sfile*': expand('<sfile>:p'),
    \        'select-a': 'a@',
    \        'select-a-function': 's:select_verbatimstring_a',
    \        'select-i': 'i@',
    \        'select-i-function': 's:select_verbatimstring_i'
    \   }
    \ })

function! s:char(ch, n, isnot)
    let i = getpos('.')[2] - a:n
    if 0 <= i && i < col('$') - 2
        if a:isnot
            return getline('.')[i] != a:ch
        else
            return getline('.')[i] == a:ch
        endif
    else
        return 0
    endif
endfunction

function! s:curr_isnot(ch)
    return s:char(a:ch, 1, 1)
endfunction

function! s:curr_is(ch)
    return s:char(a:ch, 1, 0)
endfunction

function! s:next_is(ch)
    return s:char(a:ch, 0, 0)
endfunction

function! s:prev_is(ch)
    return s:char(a:ch, 2, 0)
endfunction

function! s:select_verbatimstring_a()
    let saved_pos = getpos('.')
    while (s:prev_is('"') && s:curr_is('"')) || s:curr_isnot('"')
        normal! f"
        if saved_pos == getpos('.')
            break
        endif
    endwhile
    while s:next_is('"')
        normal! lf"
    endwhile
    if s:curr_is('"')
        let tail_pos = getpos('.')
        normal! F"
        while s:prev_is('"')
            normal! hF"
        endwhile
    else
        " Cursor is right side of the verbatim-string or verbatim-string no exists.
        return 0
    endif
    if s:prev_is('@')
        normal! h
        let head_pos = getpos('.')
        if head_pos[2] + 1 == tail_pos[2]
            " Cursor is left side of the verbatim-string.
            normal! 2l
            return s:select_verbatimstring_a()
        else
            return ['v', head_pos, tail_pos]
        endif
    else
        " It's not verbatim-string.
        return 0
    endif
endfunction

function! s:select_verbatimstring_i()
    let xs = s:select_verbatimstring_a()
    if type(xs) == type([])
        let v = xs[0]
        let head_pos = xs[1]
        let head_pos[2] = head_pos[2] + 2
        let tail_pos = xs[2]
        let tail_pos[2] = tail_pos[2] - 1
        return [v, head_pos, tail_pos]
    else
        return 0
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_textobj_verbatimstring = 1

