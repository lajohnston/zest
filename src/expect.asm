;====
; Fails the test if the value in register a does not match the expected value
;
; @in   a           the value to test
; @in   expected    the expected value
;====
.macro "expect.a.toBe" isolated args expected
    push af
        cp expected
        jp z, +
            ld b, expected
            ld hl, expect.a.toBe.defaultMessage
            jp smsspec.runner.expectationFailed
        +:
    pop af
.endm

; Default error messages for expectations
.section "expect.defaultMessages" free
    expect.a.toBe.defaultMessage:
        .asc "Unexpected value in register A"
        .db $ff ; terminator byte
.ends
