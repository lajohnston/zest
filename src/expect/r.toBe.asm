;====
; Assertions to test that the value in a single register matches an expection
;====

;====
; Asserts that A is equal to the expected value, otherwise fails the test
;
; @in   a   the value
; @in   hl  pointer to the assertion data
;====
.section "expect._assertAEquals" free
    expect._assertAEquals:
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
.macro "expect.a.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.a.toBe expectedValue expect.a.toBe.defaultMessage
.endm

;====
; Asserts that A is equal to the expected value, otherwise fails the test.
; Returns to the return address + 3, to skip the assertion data
;
; @in   a   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.a.toBe" free
    expect.a.toBe:
        zest.byteAssertion.loadHLPointer
            call expect._assertAEquals
        zest.byteAssertion.return.HL
.ends

;====
; Fails the test if the value in register B does not match the expected value
;
; @in   b           the actual value
; @in   expected    the expected value
;====
.macro "expect.b.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.b.toBe expectedValue expect.b.toBe.defaultMessage
.endm

;====
; Asserts that B is equal to the expected value, otherwise fails the test
;
; @in   b   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.b.toBe" free
    expect.b.toBe:
        zest.byteAssertion.loadHLPointer

        push af
            ld a, b
            call expect._assertAEquals
        pop af

        zest.byteAssertion.return.HL
.ends

;====
; Fails the test if the value in register C does not match the expected value
;
; @in   c           the actual value
; @in   expected    the expected value
;====
.macro "expect.c.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.c.toBe expectedValue expect.c.toBe.defaultMessage
.endm

;====
; Asserts that C is equal to the expected value, otherwise fails the test
;
; @in   c   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.c.toBe" free
    expect.c.toBe:
        zest.byteAssertion.loadHLPointer

        push af
            ld a, c
            call expect._assertAEquals
        pop af

        zest.byteAssertion.return.HL
.ends

;====
; Fails the test if the value in register D does not match the expected value
;
; @in   d               the actual value
; @in   expectedValue   the expected value
;====
.macro "expect.d.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.d.toBe expectedValue expect.d.toBe.defaultMessage
.endm

;====
; Asserts that D is equal to the expected value, otherwise fails the test
;
; @in   d   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.d.toBe" free
    expect.d.toBe:
        zest.byteAssertion.loadHLPointer

        push af
            ld a, d
            call expect._assertAEquals
        pop af

        zest.byteAssertion.return.HL
.ends

;====
; Fails the test if the value in register E does not match the expected value
;
; @in   e               the actual value
; @in   expectedValue   the expected value
;====
.macro "expect.e.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.e.toBe expectedValue expect.e.toBe.defaultMessage
.endm

;====
; Asserts that E is equal to the expected value, otherwise fails the test
;
; @in   e   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.e.toBe" free
    expect.e.toBe:
        zest.byteAssertion.loadHLPointer

        push af
            ld a, e
            call expect._assertAEquals
        pop af

        zest.byteAssertion.return.HL
.ends

;====
; Fails the test if the value in register H does not match the expected value
;
; @in   h               the actual value
; @in   expectedValue   the expected value
;====
.macro "expect.h.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.h.toBe expectedValue expect.h.toBe.defaultMessage
.endm

;====
; Asserts that H is equal to the expected value, otherwise fails the test
;
; @in   h   the value
; @in   de  pointer to the assertion data
;====
.section "expect.h.toBe" free
    expect.h.toBe:
        zest.byteAssertion.loadDEPointer

        push af
            ld a, h
            ex de, hl
                call expect._assertAEquals
            ex de, hl
        pop af

        zest.byteAssertion.return.DE
.ends

;====
; Fails the test if the value in register L does not match the expected value
;
; @in   l               the actual value
; @in   expectedValue   the expected value
;====
.macro "expect.l.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.l.toBe expectedValue expect.l.toBe.defaultMessage
.endm

;====
; Asserts that L is equal to the expected value, otherwise fails the test
;
; @in   l   the value
; @in   de  pointer to the assertion data
;====
.section "expect.l.toBe" free
    expect.l.toBe:
        zest.byteAssertion.loadDEPointer

        push af
            ld a, l
            ex de, hl
                call expect._assertAEquals
            ex de, hl
        pop af

        zest.byteAssertion.return.DE
.ends

;====
; Fails the test if the value in register IXH does not match the expected value
;
; @in   ixh           the actual value
; @in   expected    the expected value
;====
.macro "expect.ixh.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.ixh.toBe expectedValue expect.ixh.toBe.defaultMessage
.endm

;====
; Asserts that IXH is equal to the expected value, otherwise fails the test
;
; @in   ixh the value
; @in   hl  pointer to the assertion data
;====
.section "expect.ixh.toBe" free
    expect.ixh.toBe:
        zest.byteAssertion.loadHLPointer

        push af
            ld a, ixh
            call expect._assertAEquals
        pop af

        zest.byteAssertion.return.HL
.ends

;====
; Fails the test if the value in register IXL does not match the expected value
;
; @in   ixl         the actual value
; @in   expected    the expected value
;====
.macro "expect.ixl.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.ixl.toBe expectedValue expect.ixl.toBe.defaultMessage
.endm

;====
; Asserts that IXL is equal to the expected value, otherwise fails the test
;
; @in   ixl the value
; @in   hl  pointer to the assertion data
;====
.section "expect.ixl.toBe" free
    expect.ixl.toBe:
        zest.byteAssertion.loadHLPointer

        push af
            ld a, ixl
            call expect._assertAEquals
        pop af

        zest.byteAssertion.return.HL
.ends

;====
; Fails the test if the value in register IYH does not match the expected value
;
; @in   iyh         the actual value
; @in   expected    the expected value
;====
.macro "expect.iyh.toBe" args expectedValue
     zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.iyh.toBe expectedValue expect.iyh.toBe.defaultMessage
.endm

;====
; Asserts that IYH is equal to the expected value, otherwise fails the test
;
; @in   iyh the value
; @in   hl  pointer to the assertion data
;====
.section "expect.iyh.toBe" free
    expect.iyh.toBe:
        zest.byteAssertion.loadHLPointer

        push af
            ld a, iyh
            call expect._assertAEquals
        pop af

        zest.byteAssertion.return.HL
.ends

;====
; Fails the test if the value in register IYL does not match the expected value
;
; @in   iyl         the actual value
; @in   expected    the expected value
;====
.macro "expect.iyl.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.iyl.toBe expectedValue expect.iyl.toBe.defaultMessage
.endm

;====
; Asserts that IYL is equal to the expected value, otherwise fails the test
;
; @in   iyl the value
; @in   hl  pointer to the assertion data
;====
.section "expect.iyl.toBe" free
    expect.iyl.toBe:
        zest.byteAssertion.loadHLPointer

        push af
            ld a, iyl
            call expect._assertAEquals
        pop af

        zest.byteAssertion.return.HL
.ends

;====
; Fails the test if the value in register I does not match the expected value
;
; @in   i           the actual value
; @in   expected    the expected value
;====
.macro "expect.i.toBe" args expectedValue
    zest.utils.assert.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        zest.byteAssertion.assert expect.i.toBe expectedValue expect.i.toBe.defaultMessage
.endm

;====
; Asserts that I is equal to the expected value, otherwise fails the test
;
; @in   i the value
; @in   hl  pointer to the assertion data
;====
.section "expect.i.toBe" free
    expect.i.toBe:
        zest.byteAssertion.loadHLPointer

        push af
            ld a, i
            call expect._assertAEquals
        pop af

        zest.byteAssertion.return.HL
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
