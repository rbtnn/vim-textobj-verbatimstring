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

function! s:select_verbatimstring_a()
    let line = getline('.')
    let xs = split(line, '\zs')
    let pairs = verbatimstring#parse(xs)
    let col = col('.')

    for pair in pairs
        if col < pair.begin_col
            return ['v', [0, line('.'), pair.begin_col, -1], [0, line('.'), pair.end_col, 0]]
        elseif (pair.begin_col <= col) && (col <= pair.end_col)
            return ['v', [0, line('.'), pair.begin_col, -1], [0, line('.'), pair.end_col, 0]]
        endif
    endfor

    return 0
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

