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
; Asserts that the parity/overflow flag matches the expected state
;
; @in   f               flags
; @in   expectedValue   either a 1 or a 0
;====
.macro "expect.parityOverflow.toBe" args expectedValue
    zest.utils.assert.boolean expectedValue "\. expects a boolean (0 or 1) value"

    .if expectedValue == 1
        jp pe, +     ; jp/pass if parity/overflow is set
            expect.flags._fail expectedValue expect.flags.defaultMessages.parityOverflow
        +:
    .else
        jp po, +    ; jp/pass if parity/overflow reset
            expect.flags._fail expectedValue expect.flags.defaultMessages.parityOverflow
        +:
    .endif
.endm

;====
; Asserts that the sign flag matches the expected state
;
; @in   f               flags
; @in   expectedValue   either a 1 or a 0
;====
.macro "expect.sign.toBe" args expectedValue
    zest.utils.assert.boolean expectedValue "\. expects a boolean (0 or 1) value"

    .if expectedValue == 1
        jp m, +     ; jp/pass if sign flag is set
            expect.flags._fail expectedValue expect.flags.defaultMessages.sign
        +:
    .else
        jp p, +     ; jp/pass if sign flag is reset
            expect.flags._fail expectedValue expect.flags.defaultMessages.sign
        +:
    .endif
.endm

;====
; Asserts that the zero flag matches the expected state
;
; @in   f               flags
; @in   expectedValue   either a 1 or a 0
;====
.macro "expect.zeroFlag.toBe" args expectedValue
    zest.utils.assert.boolean expectedValue "\. expects a boolean (0 or 1) value"

    .if expectedValue == 1
        jp z, +     ; jp/pass if zero flag is set
            expect.flags._fail expectedValue expect.flags.defaultMessages.zeroFlag
        +:
    .else
        jp nz, +     ; jp/pass if zero flag is reset
            expect.flags._fail expectedValue expect.flags.defaultMessages.zeroFlag
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

    expect.flags.defaultMessages.parityOverflow:
        .asc "Unexpected parity/overflow"
        .db $ff

    expect.flags.defaultMessages.sign:
        .asc "Unexpected sign flag state"
        .db $ff

    expect.flags.defaultMessages.zeroFlag:
        .asc "Unexpected zero flag state"
        .db $ff
.ends
