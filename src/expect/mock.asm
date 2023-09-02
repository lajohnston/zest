;====
; Fails the test if the given mock wasn't called at least once
;
; @in   mock        the mock (instance in RAM)
;====
.macro "expect.mock.toHaveBeenCalled" args mock
    \@_\.:

    push af
        zest.mock.getTimesCalled mock
        or a    ; update flags
        jp nz, +; jp if not zero
            ; Mock was called zero times - fail the test
            push hl
                ld hl, expect.mock.toHaveBeenCalled.defaultMessage
                call zest.runner.expectationFailed
            pop hl
        +:
    pop af
.endm

; Default error messages for expectations
.section "expect.mock.defaultMessages" free
    expect.mock.toHaveBeenCalled.defaultMessage:
        zest.console.defineString "Expected mock to have been called at least once, but it was not"
.ends