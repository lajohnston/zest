;====
; Assertions to test that the value in a single register matches an expection
;====

;====
; (Private) Asserts the value in register A matches the expected value,
; otherwise jumps to zest.runner.expectationFailed
;
; @in   a           the actual value
; @in   expected    the expected value
; @in   message     pointer to the failure message string
;====
.macro "expect._assertAEquals" isolated args expected message
    cp expected
    jp z, +
        push bc
        push hl
            ld b, expected
            ld hl, message
            call zest.runner.expectationFailed
        pop hl
        pop bc
    +:
.endm

;====
; Fails the test if the value in register A does not match the expected value
;
; @in   a           the actual value
; @in   expected    the expected value
;====
.macro "expect.a.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        expect._assertAEquals expected expect.a.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register B does not match the expected value
;
; @in   b           the actual value
; @in   expected    the expected value
;====
.macro "expect.b.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, b
        expect._assertAEquals expected expect.b.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register C does not match the expected value
;
; @in   c           the actual value
; @in   expected    the expected value
;====
.macro "expect.c.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, c
        expect._assertAEquals expected expect.c.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register D does not match the expected value
;
; @in   d           the actual value
; @in   expected    the expected value
;====
.macro "expect.d.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, d
        expect._assertAEquals expected expect.d.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register E does not match the expected value
;
; @in   e           the actual value
; @in   expected    the expected value
;====
.macro "expect.e.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, e
        expect._assertAEquals expected expect.e.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register H does not match the expected value
;
; @in   h           the actual value
; @in   expected    the expected value
;====
.macro "expect.h.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, h
        expect._assertAEquals expected expect.h.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register L does not match the expected value
;
; @in   l           the actual value
; @in   expected    the expected value
;====
.macro "expect.l.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, l
        expect._assertAEquals expected expect.l.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register IXH does not match the expected value
;
; @in   ixh           the actual value
; @in   expected    the expected value
;====
.macro "expect.ixh.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, ixh
        expect._assertAEquals expected expect.ixh.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register IXL does not match the expected value
;
; @in   ixl         the actual value
; @in   expected    the expected value
;====
.macro "expect.ixl.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, ixl
        expect._assertAEquals expected expect.ixl.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register IYH does not match the expected value
;
; @in   iyh         the actual value
; @in   expected    the expected value
;====
.macro "expect.iyh.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, iyh
        expect._assertAEquals expected expect.iyh.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register IYL does not match the expected value
;
; @in   iyl         the actual value
; @in   expected    the expected value
;====
.macro "expect.iyl.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, iyl
        expect._assertAEquals expected expect.iyl.toBe.defaultMessage
    pop af
.endm

;====
; Fails the test if the value in register I does not match the expected value
;
; @in   i           the actual value
; @in   expected    the expected value
;====
.macro "expect.i.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    push af
        ld a, i
        expect._assertAEquals expected expect.i.toBe.defaultMessage
    pop af
.endm

; Default error messages for expectations
.section "expect.defaultMessages" free
    expect.a.toBe.defaultMessage:
        .asc "Unexpected value in register A"
        .db $ff ; terminator byte

    expect.b.toBe.defaultMessage:
        .asc "Unexpected value in register B"
        .db $ff ; terminator byte

    expect.c.toBe.defaultMessage:
        .asc "Unexpected value in register C"
        .db $ff ; terminator byte

    expect.d.toBe.defaultMessage:
        .asc "Unexpected value in register D"
        .db $ff ; terminator byte

    expect.e.toBe.defaultMessage:
        .asc "Unexpected value in register E"
        .db $ff ; terminator byte

    expect.h.toBe.defaultMessage:
        .asc "Unexpected value in register H"
        .db $ff ; terminator byte

    expect.l.toBe.defaultMessage:
        .asc "Unexpected value in register L"
        .db $ff ; terminator byte

    expect.ixh.toBe.defaultMessage:
        .asc "Unexpected value in IXH"
        .db $ff ; terminator byte

    expect.ixl.toBe.defaultMessage:
        .asc "Unexpected value in IXL"
        .db $ff ; terminator byte

    expect.iyh.toBe.defaultMessage:
        .asc "Unexpected value in IYH"
        .db $ff ; terminator byte

    expect.iyl.toBe.defaultMessage:
        .asc "Unexpected value in IYL"
        .db $ff ; terminator byte

    expect.i.toBe.defaultMessage:
        .asc "Unexpected value in I"
        .db $ff ; terminator byte
.ends
