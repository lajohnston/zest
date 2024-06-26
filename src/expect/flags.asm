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
        call zest.assertion.boolean.failed
    pop af
    pop hl
.endm

;====
; Asserts that the carry flag matches the expected state
;
; @in   f               flags
; @in   expectedValue   either a 1 or a 0
;====
.macro "expect.carry.toBe" isolated args expectedValue
    zest.utils.validate.boolean expectedValue "\. expects a boolean (0 or 1) value"

    \@_\..{expectedValue}:

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
.macro "expect.parityOverflow.toBe" isolated args expectedValue
    zest.utils.validate.boolean expectedValue "\. expects a boolean (0 or 1) value"

    \@_\..{expectedValue}:

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
.macro "expect.sign.toBe" isolated args expectedValue
    zest.utils.validate.boolean expectedValue "\. expects a boolean (0 or 1) value"

    \@_\..{expectedValue}:

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
.macro "expect.zeroFlag.toBe" isolated args expectedValue
    zest.utils.validate.boolean expectedValue "\. expects a boolean (0 or 1) value"

    \@_\..{expectedValue}:

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
        zest.console.defineString "Unexpected carry flag state"

    expect.flags.defaultMessages.parityOverflow:
        zest.console.defineString "Unexpected parity/overflow"

    expect.flags.defaultMessages.sign:
        zest.console.defineString "Unexpected sign flag state"

    expect.flags.defaultMessages.zeroFlag:
        zest.console.defineString "Unexpected zero flag state"
.ends
