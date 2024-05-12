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
        push af
        push de
        push hl
            ; Set DE to expected value
            ld e, (hl)
            inc hl
            ld d, (hl)

            ; Set HL to actual value
            ld h, b
            ld l, c

            or a            ; clear carry flag
            sbc hl, de      ; subtract actual from expected
            jr nz, _fail    ; jp if the values didn't match
        pop hl
        pop de
        pop af
        ret

    _fail:
        ; Pop message pointer into IX
        pop ix

        ; Set DE to actual value
        ld d, b
        ld e, c

        ; Fail test with message
        jp zest.runner.wordExpectationFailed
.ends

;====
; Asserts the value in DE matches the expected value
;
; @in   de              value
; @in   expectedValue   the expected value
;====
.macro "expect.de.toBe" isolated args expectedValue
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
    zest.utils.assert.word expectedValue "\. expects a 16-bit value"

    push af
    push bc
        ld bc, expectedValue
        or a            ; clear carry flag

        push hl
            sbc hl, bc  ; set z flag if HL == BC (expected value)
        pop hl

        jp z, +         ; jp if zero/pass
            ex de, hl   ; move actual value to DE
            push hl
                ; Print test failure
                ld hl, expect.rr.toBe.defaultMessages.hl
                call zest.runner.wordExpectationFailedV1
            pop hl
            ex de, hl   ; restore HL and DE
        +:
    pop bc
    pop af
.endm

;====
; Asserts the value in IX matches the expected value
;
; @in   ix              value
; @in   expectedValue   the expected value
;====
.macro "expect.ix.toBe" isolated args expectedValue
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
        push af
        push de
        push hl
            ; Set HL to expected value
            ld a, (hl)
            inc hl
            ld h, (hl)
            ld l, a

            ; Set DE to actual value
            ld d, ixh
            ld e, ixl

            or a            ; clear carry flag
            sbc hl, de      ; subtract actual from expected
            jr nz, _fail    ; jp if the values didn't match
        pop hl
        pop de
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
; Asserts the value in IY matches the expected value
;
; @in   iy              value
; @in   expectedValue   the expected value
;====
.macro "expect.iy.toBe" isolated args expectedValue
    zest.utils.assert.word expectedValue "\. expects a 16-bit value"

    push af
    push hl
    push de
        ; Set HL to expected value
        ld hl, expectedValue

        ; Set DE to actual value
        ld d, iyh
        ld e, iyl

        or a                    ; clear carry flag
        sbc hl, de              ; set z flag if DE equals expected value

        jp z, +                 ; jp if zero/pass
            push bc
                ; Load BC with expected value
                ld bc, expectedValue

                ; Load HL with assertion message
                ld hl, expect.rr.toBe.defaultMessages.iy

                ; Print test failure
                call zest.runner.wordExpectationFailedV1
            pop bc
        +:
    pop de
    pop hl
    pop af
.endm

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
