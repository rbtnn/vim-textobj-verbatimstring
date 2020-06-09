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

function! s:parse_line(xs)
    let pairs = []
    let last = len(a:xs) - 1
    let j = 0
    while j <= last
        if ('@' == a:xs[j]) && ('"' == get(a:xs, j + 1, ''))
            let k = j + 2
            while k <= last
                if '"' == a:xs[k]
                    if '"' == get(a:xs, k + 1, '')
                        let k += 2
                    else
                        let pairs += [{
                            \ 'begin_idx' : j,
                            \ 'end_idx' : k,
                            \ 'begin_col' : len(join(a:xs[:j] ,'')),
                            \ 'end_col' : len(join(a:xs[:k], '')),
                            \ }]
                        let j = k
                        break
                    endif
                else
                    let k += 1
                endif
            endwhile
        elseif '"' == a:xs[j]
            let k = j + 1
            while k <= last
                if '\' == a:xs[k]
                    let k += 2
                elseif '"' == a:xs[k]
                    let j = k
                    break
                else
                    let k += 1
                endif
            endwhile
        endif
        let j += 1
    endwhile
    return pairs
endfunction

function! s:select_verbatimstring_a()
    let line = getline('.')
    let xs = split(line, '\zs')
    let pairs = s:parse_line(xs)
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

