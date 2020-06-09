
scriptencoding utf-8

let s:TEST_LOG = expand('<sfile>:h:h:gs?\?/?') . '/test.log'

function! verbatimstring#parse(xs) abort
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

function! verbatimstring#run_tests() abort
    if filereadable(s:TEST_LOG)
        call delete(s:TEST_LOG)
    endif

    let v:errors = []

    if !empty(v:errors)
        call writefile(v:errors, s:TEST_LOG)
        for err in v:errors
            echohl Error
            echo err
            echohl None
        endfor
    endif
endfunction

