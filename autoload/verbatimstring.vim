
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

function! verbatimstring#run_test(line, col, expected) abort
    let actual = []
    try
        new
        call setline(1, a:line)
        for pair in verbatimstring#parse(split(getline('.'), '\zs'))
            if (a:col < pair.begin_col) || ((pair.begin_col <= a:col) && (a:col <= pair.end_col))
                call setpos('.', [0, line('.'), pair.begin_col, 0])
                call feedkeys('v', 'nx')
                call setpos('.', [0, line('.'), pair.end_col, 0])
                call feedkeys('"*y', 'nx')
                let actual = [@*]
                break
            endif
        endfor
    finally
        quit!
    endtry
    call assert_equal(actual, a:expected)
endfunction

function! verbatimstring#run_tests() abort
    if filereadable(s:TEST_LOG)
        call delete(s:TEST_LOG)
    endif

    let v:errors = []

    let line = ''
    call verbatimstring#run_test(line, 1, [])

    let line = ' @"" '
    for col in range(1, 4)
        call verbatimstring#run_test(line, col, ['@""'])
    endfor
    call verbatimstring#run_test(line, 5, [])

    let line = ' @"abc" '
    for col in range(1, 7)
        call verbatimstring#run_test(line, col, ['@"abc"'])
    endfor
    call verbatimstring#run_test(line, 8, [])

    let line = ' @"""a@""b\" '
    for col in range(1, 12)
        call verbatimstring#run_test(line, col, ['@"""a@""b\"'])
    endfor
    call verbatimstring#run_test(line, 13, [])

    let line = ' @"x" "\n" @"y" "\"" @"z" '
    for col in range(1, 5)
        call verbatimstring#run_test(line, col, ['@"x"'])
    endfor
    for col in range(6, 15)
        call verbatimstring#run_test(line, col, ['@"y"'])
    endfor
    for col in range(16, 25)
        call verbatimstring#run_test(line, col, ['@"z"'])
    endfor
    call verbatimstring#run_test(line, 26, [])

    if !empty(v:errors)
        call writefile(v:errors, s:TEST_LOG)
        for err in v:errors
            echohl Error
            echo err
            echohl None
        endfor
    endif
endfunction

call verbatimstring#run_tests()

