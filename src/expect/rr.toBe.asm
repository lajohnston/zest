;====
; Asserts the register pairs match the expected 16-bit value
;====

;====
; Asserts the value in BC matches the expected value
;
; @in   bc              value
; @in   expectedValue   the expected value
; @in   message         (optional) custom string assertion failure message
;====
.macro "expect.bc.toBe" isolated args expectedValue message
    zest.utils.validate.wordOrLabel expectedValue "\. expects a 16-bit value or a label"

    \@_\..:

    .if NARGS == 1
        zest.assertion.word.assert expect.bc._toBe expectedValue expect.rr.toBe.defaultMessages.bc
    .else
        zest.utils.validate.string message "\.: Message should be a string"
        zest.assertion.word.assert expect.bc._toBe expectedValue message
    .endif
.endm

;====
; Asserts the value in DE matches the expected value
;
; @in   de              value
; @in   expectedValue   the expected value
; @in   message         (optional) custom string assertion failure message
;====
.macro "expect.de.toBe" isolated args expectedValue message
    zest.utils.validate.wordOrLabel expectedValue "\. expects a 16-bit value or a label"

    \@_\..:

    .if NARGS == 1
        zest.assertion.word.assert expect.de._toBe expectedValue expect.rr.toBe.defaultMessages.de
    .else
        zest.utils.validate.string message "\.: Message should be a string"
        zest.assertion.word.assert expect.de._toBe expectedValue message
    .endif
.endm

;====
; Asserts the value in HL matches the expected value
;
; @in   hl              value
; @in   expectedValue   the expected value
; @in   message         (optional) custom string assertion failure message
;====
.macro "expect.hl.toBe" isolated args expectedValue message
    zest.utils.validate.wordOrLabel expectedValue "\. expects a 16-bit value or a label"

    \@_\..:

    .if NARGS == 1
        zest.assertion.word.assert expect.hl._toBe expectedValue expect.rr.toBe.defaultMessages.hl
    .else
        zest.utils.validate.string message "\.: Message should be a string"
        zest.assertion.word.assert expect.hl._toBe expectedValue message
    .endif
.endm

;====
; Asserts the value in IX matches the expected value
;
; @in   ix              value
; @in   expectedValue   the expected value
; @in   message         (optional) custom string assertion failure message
;====
.macro "expect.ix.toBe" isolated args expectedValue message
    zest.utils.validate.wordOrLabel expectedValue "\. expects a 16-bit value or a label"

    \@_\..:

    .if NARGS == 1
        zest.assertion.word.assert expect.ix._toBe expectedValue expect.rr.toBe.defaultMessages.ix
    .else
        zest.utils.validate.string message "\.: Message should be a string"
        zest.assertion.word.assert expect.ix._toBe expectedValue message
    .endif
.endm

;====
; Asserts the value in IY matches the expected value
;
; @in   iy              value
; @in   expectedValue   the expected value
; @in   message         (optional) custom string assertion failure message
;====
.macro "expect.iy.toBe" isolated args expectedValue message
    zest.utils.validate.wordOrLabel expectedValue "\. expects a 16-bit value or a label"

    \@_\..:

    .if NARGS == 1
        zest.assertion.word.assert expect.iy._toBe expectedValue expect.rr.toBe.defaultMessages.iy
    .else
        zest.utils.validate.string message "\.: Message should be a string"
        zest.assertion.word.assert expect.iy._toBe expectedValue message
    .endif
.endm

;====
; (Private) Asserts BC is equal to the expected value, otherwise fails the test
;
; @in   stack{0}    pointer to the assertion data
; @in   bc          the actual value
;====
.section "expect.bc._toBe" free
    expect.bc._toBe:
        ex (sp), hl

        push de
            ld d, b
            ld e, c
            call zest.assertion.word.assertDEEquals
        pop de

        zest.assertion.word.return
.ends

;====
; (Private) Asserts DE is equal to the expected value, otherwise fails the test
;
; @in   stack{0}    pointer to the assertion data
; @in   de          the actual value
;====
.section "expect.de._toBe" free
    expect.de._toBe:
        ex (sp), hl
        call zest.assertion.word.assertDEEquals
        zest.assertion.word.return
.ends

;====
; (Private) Asserts HL is equal to the expected value, otherwise fails the test
;
; @in   stack{0}    pointer to the assertion data
; @in   hl          the actual value
;====
.section "expect.hl._toBe" free
    expect.hl._toBe:
        ex de, hl               ; set DE to actual value
            ex (sp), hl         ; set HL to assertion data pointer
            call zest.assertion.word.assertDEEquals

            ; Skip over the word assertion data
            .repeat _sizeof_zest.assertion.word
                inc hl          ; inc return address past the assertion data
            .endr

            ex (sp), hl         ; restore HL; set return address to stack
        ex de, hl               ; switch values back
        ret
.ends

;====
; (Private) Asserts IX is equal to the expected value, otherwise fails the test
;
; @in   stack{0}    pointer to the assertion data
; @in   ix          the actual value
;====
.section "expect.ix._toBe" free
    expect.ix._toBe:
        ex (sp), hl

        push de
            ld d, ixh
            ld e, ixl
            call zest.assertion.word.assertDEEquals
        pop de

        zest.assertion.word.return
.ends

;====
; (Private) Asserts IY is equal to the expected value, otherwise fails the test
;
; @in   stack{0}    pointer to the assertion data
; @in   iy          the actual value
;====
.section "expect.iy._toBe" free
    expect.iy._toBe:
        ex (sp), hl

        push de
            ld d, iyh
            ld e, iyl
            call zest.assertion.word.assertDEEquals
        pop de

        zest.assertion.word.return
.ends

;====
; Default error messages for expectations
;====
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
