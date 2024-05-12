;====
; Assertions to test that the value in a single register matches an expection
;====

;====
; (Private) Asserts the value in register A matches the expected value,
; otherwise jumps to zest.runner.byteExpectationFailed
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
            call zest.runner.byteExpectationFailed
        pop hl
        pop bc
    +:
.endm

;====
; Asserts that A is equal to the expected value, otherwise fails the test
;
; @in   a   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.a.toBe" free
    expect.a.toBe:
        push af
            cp (hl)
            jr nz, _fail
        pop af
        ret

    _fail:
        ; Set IX to pointer
        push hl
        pop ix

        call zest.runner.byteExpectationFailed
.ends

;====
; Fails the test if the value in register A does not match the expected value
;
; @in   a           the actual value
; @in   expected    the expected value
;====
.macro "expect.a.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    \@_\..{expected}:

    ; Define assertion data
    zest.byteAssertion.define expected expect.a.toBe.defaultMessage

    ; Call routine
    push hl
        ld hl, zest.byteAssertion.define.returnValue
        call expect.a.toBe
    pop hl
.endm

;====
; Fails the test if the value in register B does not match the expected value
;
; @in   b           the actual value
; @in   expected    the expected value
;====
.macro "expect.b.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    \@_\..{expected}:

    ; Define assertion data
    zest.byteAssertion.define expected expect.b.toBe.defaultMessage

    ; Call routine
    push hl
        ld hl, zest.byteAssertion.define.returnValue
        call expect.b.toBe
    pop hl
.endm

;====
; Asserts that B is equal to the expected value, otherwise fails the test
;
; @in   b   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.b.toBe" free
    expect.b.toBe:
        push af
            ld a, b
            call expect.a.toBe
        pop af
        ret
.ends

;====
; Fails the test if the value in register C does not match the expected value
;
; @in   c           the actual value
; @in   expected    the expected value
;====
.macro "expect.c.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    ; Define assertion data
    zest.byteAssertion.define expected expect.c.toBe.defaultMessage

    ; Call routine
    push hl
        ld hl, zest.byteAssertion.define.returnValue
        call expect.c.toBe
    pop hl
.endm

;====
; Asserts that C is equal to the expected value, otherwise fails the test
;
; @in   c   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.c.toBe" free
    expect.c.toBe:
        push af
            ld a, c
            call expect.a.toBe
        pop af
        ret
.ends

;====
; Fails the test if the value in register D does not match the expected value
;
; @in   d           the actual value
; @in   expected    the expected value
;====
.macro "expect.d.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    ; Define assertion data
    zest.byteAssertion.define expected expect.d.toBe.defaultMessage

    ; Call routine
    push hl
        ld hl, zest.byteAssertion.define.returnValue
        call expect.d.toBe
    pop hl
.endm

;====
; Asserts that D is equal to the expected value, otherwise fails the test
;
; @in   d   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.d.toBe" free
    expect.d.toBe:
        push af
            ld a, d
            call expect.a.toBe
        pop af
        ret
.ends

;====
; Fails the test if the value in register E does not match the expected value
;
; @in   e           the actual value
; @in   expected    the expected value
;====
.macro "expect.e.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    \@_\..{expected}:

    ; Define assertion data
    zest.byteAssertion.define expected expect.e.toBe.defaultMessage

    ; Call routine
    push hl
        ld hl, zest.byteAssertion.define.returnValue
        call expect.e.toBe
    pop hl
.endm

;====
; Asserts that E is equal to the expected value, otherwise fails the test
;
; @in   e   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.e.toBe" free
    expect.e.toBe:
        push af
            ld a, e
            call expect.a.toBe
        pop af
        ret
.ends

;====
; Fails the test if the value in register H does not match the expected value
;
; @in   h           the actual value
; @in   expected    the expected value
;====
.macro "expect.h.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    \@_\..{expected}:

    ; Define assertion data
    zest.byteAssertion.define expected expect.h.toBe.defaultMessage

    ; Call routine
    push de
        ld de, zest.byteAssertion.define.returnValue
        call expect.h.toBe
    pop de
.endm

;====
; Asserts that H is equal to the expected value, otherwise fails the test
;
; @in   h   the value
; @in   de  pointer to the assertion data
;====
.section "expect.h.toBe" free
    expect.h.toBe:
        push af
            ld a, h
            ex de, hl
            call expect.a.toBe
            ex de, hl
        pop af
        ret
.ends

;====
; Fails the test if the value in register L does not match the expected value
;
; @in   l           the actual value
; @in   expected    the expected value
;====
.macro "expect.l.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    \@_\..{expected}:

    ; Define assertion data
    zest.byteAssertion.define expected expect.l.toBe.defaultMessage

    ; Call routine
    push de
        ld de, zest.byteAssertion.define.returnValue
        call expect.l.toBe
    pop de
.endm

;====
; Asserts that L is equal to the expected value, otherwise fails the test
;
; @in   l   the value
; @in   de  pointer to the assertion data
;====
.section "expect.l.toBe" free
    expect.l.toBe:
        push af
            ld a, l
            ex de, hl
            call expect.a.toBe
            ex de, hl
        pop af
        ret
.ends

;====
; Fails the test if the value in register IXH does not match the expected value
;
; @in   ixh           the actual value
; @in   expected    the expected value
;====
.macro "expect.ixh.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    \@_\..{expected}:

    ; Define assertion data
    zest.byteAssertion.define expected expect.ixh.toBe.defaultMessage

    ; Call routine
    push hl
        ld hl, zest.byteAssertion.define.returnValue
        call expect.ixh.toBe
    pop hl
.endm

;====
; Asserts that IXH is equal to the expected value, otherwise fails the test
;
; @in   ixh the value
; @in   hl  pointer to the assertion data
;====
.section "expect.ixh.toBe" free
    expect.ixh.toBe:
        push af
            ld a, ixh
            call expect.a.toBe
        pop af
        ret
.ends

;====
; Fails the test if the value in register IXL does not match the expected value
;
; @in   ixl         the actual value
; @in   expected    the expected value
;====
.macro "expect.ixl.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    \@_\..{expected}:

    ; Define assertion data
    zest.byteAssertion.define expected expect.ixl.toBe.defaultMessage

    ; Call routine
    push hl
        ld hl, zest.byteAssertion.define.returnValue
        call expect.ixl.toBe
    pop hl
.endm

;====
; Asserts that IXL is equal to the expected value, otherwise fails the test
;
; @in   ixl the value
; @in   hl  pointer to the assertion data
;====
.section "expect.ixl.toBe" free
    expect.ixl.toBe:
        push af
            ld a, ixl
            call expect.a.toBe
        pop af
        ret
.ends

;====
; Fails the test if the value in register IYH does not match the expected value
;
; @in   iyh         the actual value
; @in   expected    the expected value
;====
.macro "expect.iyh.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    \@_\..{expected}:

    ; Define assertion data
    zest.byteAssertion.define expected expect.iyh.toBe.defaultMessage

    ; Call routine
    push hl
        ld hl, zest.byteAssertion.define.returnValue
        call expect.iyh.toBe
    pop hl
.endm

;====
; Asserts that IYH is equal to the expected value, otherwise fails the test
;
; @in   iyh the value
; @in   hl  pointer to the assertion data
;====
.section "expect.iyh.toBe" free
    expect.iyh.toBe:
        push af
            ld a, iyh
            call expect.a.toBe
        pop af
        ret
.ends

;====
; Fails the test if the value in register IYL does not match the expected value
;
; @in   iyl         the actual value
; @in   expected    the expected value
;====
.macro "expect.iyl.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    \@_\..{expected}:

    ; Define assertion data
    zest.byteAssertion.define expected expect.iyl.toBe.defaultMessage

    ; Call routine
    push hl
        ld hl, zest.byteAssertion.define.returnValue
        call expect.iyl.toBe
    pop hl
.endm

;====
; Asserts that IYL is equal to the expected value, otherwise fails the test
;
; @in   iyl the value
; @in   hl  pointer to the assertion data
;====
.section "expect.iyl.toBe" free
    expect.iyl.toBe:
        push af
            ld a, iyl
            call expect.a.toBe
        pop af
        ret
.ends

;====
; Fails the test if the value in register I does not match the expected value
;
; @in   i           the actual value
; @in   expected    the expected value
;====
.macro "expect.i.toBe" args expected
    zest.utils.assert.byte expected "\. expects a numeric byte value"

    \@_\..{expected}:

    ; Define assertion data
    zest.byteAssertion.define expected expect.i.toBe.defaultMessage

    ; Call routine
    push hl
        ld hl, zest.byteAssertion.define.returnValue
        call expect.i.toBe
    pop hl
.endm

;====
; Asserts that I is equal to the expected value, otherwise fails the test
;
; @in   i the value
; @in   hl  pointer to the assertion data
;====
.section "expect.i.toBe" free
    expect.i.toBe:
        push af
            ld a, i
            call expect.a.toBe
        pop af
        ret
.ends

; Default error messages for expectations
.section "expect.defaultMessages" free
    expect.a.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in register A"

    expect.b.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in register B"

    expect.c.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in register C"

    expect.d.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in register D"

    expect.e.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in register E"

    expect.h.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in register H"

    expect.l.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in register L"

    expect.ixh.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in IXH"

    expect.ixl.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in IXL"

    expect.iyh.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in IYH"

    expect.iyl.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in IYL"

    expect.i.toBe.defaultMessage:
        zest.console.defineString "Unexpected value in I"
.ends
