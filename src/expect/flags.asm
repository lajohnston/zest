;====
; Assert the values in the Flags register
;====

;====
; Fails the test with the given message
;
; @in   expectedValue   either a 1 or a 0
; @in   message         pointer to the failure message
;====
.macro "expect.flags._fail" args expectedValue message
    push hl
    push af
        ld a, expectedValue
        ld hl, message
        call zest.runner.booleanExpectationFailed
    pop af
    pop hl
.endm

;====
; Asserts that the carry flag matches the expected state
;
; @in   f               flags
; @in   expectedValue   either a 1 or a 0
;====
.macro "expect.carry.toBe" args expectedValue
    zest.utils.assert.boolean expectedValue "\. expects a boolean (0 or 1) value"

    .if expectedValue == 1
        jp c, +     ; jp/pass if carry set
            expect.flags._fail expectedValue expect.flags.defaultMessages.carry
        +:
    .else
        jp nc, +    ; jp/pass if carry reset
            expect.flags._fail expectedValue expect.flags.defaultMessages.carry
        +:
    .endif
.endm

;====
; Assertion messages
;====
.section "expect.flags.defaultMessages" free
    expect.flags.defaultMessages.carry:
        .asc "Unexpected carry flag state"
        .db $ff
.ends
