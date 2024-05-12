;====
; Asserts the register pairs match the expected 16-bit value
;====

;====
; Asserts the value in BC matches the expected value
;
; @in   bc              value
; @in   expectedValue   the expected value
;====
.macro "expect.bc.toBe" isolated args expectedValue
    \@_\..{expectedValue}:
    zest.utils.assert.word expectedValue "\. expects a 16-bit value"
    zest.wordAssertion.assert expect.bc.toBe expectedValue expect.rr.toBe.defaultMessages.bc
.endm

;====
; Asserts that BC is equal to the expected value, otherwise fails the test
;
; @in   hl  pointer to the assertion data
;====
.section "expect.bc.toBe" free
    expect.bc.toBe:
        push de
            ld d, b
            ld e, c
            call expect.de.toBe
        pop de
        ret
.ends

;====
; Asserts the value in DE matches the expected value
;
; @in   de              value
; @in   expectedValue   the expected value
;====
.macro "expect.de.toBe" isolated args expectedValue
    \@_\..{expectedValue}:
    zest.utils.assert.word expectedValue "\. expects a 16-bit value"
    zest.wordAssertion.assert expect.de.toBe expectedValue expect.rr.toBe.defaultMessages.de
.endm

;====
; Asserts that DE is equal to the expected value, otherwise fails the test
;
; @in   hl  pointer to the assertion data
;====
.section "expect.de.toBe" free
    expect.de.toBe:
        push af
        push hl
            ; Set HL to expected value
            ld a, (hl)
            inc hl
            ld h, (hl)
            ld l, a

            or a            ; clear carry flag
            sbc hl, de      ; subtract actual from expected
            jr nz, _fail    ; jp if the values didn't match
        pop hl
        pop af
        ret

    _fail:
        ; Pop message pointer into IX
        pop ix

        ; Fail test with message
        ; DE = actual value
        jp zest.runner.wordExpectationFailed
.ends

;====
; Asserts the value in HL matches the expected value
;
; @in   hl              value
; @in   expectedValue   the expected value
;====
.macro "expect.hl.toBe" isolated args expectedValue
    \@_\..{expectedValue}:
    zest.utils.assert.word expectedValue "\. expects a 16-bit value"
    zest.wordAssertion.assert expect.hl.toBe expectedValue expect.rr.toBe.defaultMessages.hl "de"
.endm

;====
; Asserts that HL is equal to the expected value, otherwise fails the test
;
; @in   hl  the actual value
; @in   de  pointer to the assertion data
;====
.section "expect.hl.toBe" free
    expect.hl.toBe:
        ex de, hl           ; set HL to assertion pointer and DE to actual value
        call expect.de.toBe
        ex de, hl           ; switch values back
        ret
.ends

;====
; Asserts the value in IX matches the expected value
;
; @in   ix              value
; @in   expectedValue   the expected value
;====
.macro "expect.ix.toBe" isolated args expectedValue
    \@_\..{expectedValue}:
    zest.utils.assert.word expectedValue "\. expects a 16-bit value"
    zest.wordAssertion.assert expect.ix.toBe expectedValue expect.rr.toBe.defaultMessages.ix
.endm

;====
; Asserts that IX is equal to the expected value, otherwise fails the test
;
; @in   hl  pointer to the assertion data
;====
.section "expect.ix.toBe" free
    expect.ix.toBe:
        push de
            ld d, ixh
            ld e, ixl
            call expect.de.toBe
        pop de
        ret
.ends

;====
; Asserts the value in IY matches the expected value
;
; @in   iy              value
; @in   expectedValue   the expected value
;====
.macro "expect.iy.toBe" isolated args expectedValue
    \@_\..{expectedValue}:
    zest.utils.assert.word expectedValue "\. expects a 16-bit value"
    zest.wordAssertion.assert expect.iy.toBe expectedValue expect.rr.toBe.defaultMessages.iy
.endm

;====
; Asserts that IY is equal to the expected value, otherwise fails the test
;
; @in   hl  pointer to the assertion data
;====
.section "expect.iy.toBe" free
    expect.iy.toBe:
        push de
            ld d, iyh
            ld e, iyl
            call expect.de.toBe
        pop de
        ret
.ends

; Default error messages for expectations
.section "expect.rr.toBe.defaultMessages" free
    expect.rr.toBe.defaultMessages.bc:
        .asc "Unexpected value in BC"
        .db $ff ; terminator byte

    expect.rr.toBe.defaultMessages.de:
        .asc "Unexpected value in DE"
        .db $ff ; terminator byte

    expect.rr.toBe.defaultMessages.hl:
        .asc "Unexpected value in HL"
        .db $ff ; terminator byte

    expect.rr.toBe.defaultMessages.ix:
        .asc "Unexpected value in IX"
        .db $ff ; terminator byte

    expect.rr.toBe.defaultMessages.iy:
        .asc "Unexpected value in IY"
        .db $ff ; terminator byte
.ends
