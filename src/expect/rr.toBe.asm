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

    push af
    push hl
        ld hl, expectedValue    ; set HL to expected value
        or a                    ; clear carry flag
        sbc hl, bc              ; set z flag if BC equals expected value

        jp z, +                 ; jp if zero/pass
            push bc
            push de
                ; Load DE with actual value
                ld d, b
                ld e, c

                ; Load BC with expected value
                ld bc, expectedValue

                ; Load HL with assertion message
                ld hl, expect.rr.toBe.defaultMessages.bc

                ; Print test failure
                call zest.runner.wordExpectationFailed
            pop de
            pop bc
        +:
    pop hl
    pop af
.endm

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
                call zest.runner.wordExpectationFailed
            pop hl
            ex de, hl   ; restore HL and DE
        +:
    pop bc
    pop af
.endm

; Default error messages for expectations
.section "expect.rr.toBe.defaultMessages" free
    expect.rr.toBe.defaultMessages.bc:
        .asc "Unexpected value in BC"
        .db $ff ; terminator byte

    expect.rr.toBe.defaultMessages.hl:
        .asc "Unexpected value in HL"
        .db $ff ; terminator byte
.ends
