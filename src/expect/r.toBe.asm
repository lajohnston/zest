;====
; Assertions to test that the value in a single register matches an expection
;====

;====
; (Private) Asserts that A is equal to the expected value, otherwise fails the test
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
; @in   a               the actual value
; @in   expectedValue   the expected value
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.a.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:

    .if NARGS == 1
        zest.byteAssertion.assert expect.a._toBe expectedValue expect.a.toBe.defaultMessage
    .else
        zest.utils.validate.string message "\.: Message should be a string"
        zest.byteAssertion.assert expect.a._toBe expectedValue message
    .endif
.endm

;====
; (Private) Asserts that A is equal to the expected value, otherwise fails the test.
; Returns to the return address + 3, to skip the assertion data
;
; @in   a   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.a._toBe" free
    expect.a._toBe:
        zest.byteAssertion.loadHLPointer
            call expect._assertAEquals
        zest.byteAssertion.return.HL
.ends

;====
; Fails the test if the value in register B does not match the expected value
;
; @in   b               the actual value
; @in   expectedValue   the expected value
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.b.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:

    .if NARGS == 1
        zest.byteAssertion.assert expect.b._toBe expectedValue expect.b.toBe.defaultMessage
    .else
        zest.utils.validate.string message "\.: Message should be a string"
        zest.byteAssertion.assert expect.b._toBe expectedValue message
    .endif
.endm

;====
; (Private) Asserts that B is equal to the expected value, otherwise fails the test
;
; @in   b   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.b._toBe" free
    expect.b._toBe:
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
; @in   c               the actual value
; @in   expectedValue   the expected value
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.c.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        .if NARGS == 1
            zest.byteAssertion.assert expect.c._toBe expectedValue expect.c.toBe.defaultMessage
        .else
            zest.utils.validate.string message "\.: Message should be a string"
            zest.byteAssertion.assert expect.c._toBe expectedValue message
        .endif
.endm

;====
; (Private) Asserts that C is equal to the expected value, otherwise fails the test
;
; @in   c   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.c._toBe" free
    expect.c._toBe:
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
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.d.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        .if NARGS == 1
            zest.byteAssertion.assert expect.d._toBe expectedValue expect.d.toBe.defaultMessage
        .else
            zest.utils.validate.string message "\.: Message should be a string"
            zest.byteAssertion.assert expect.d._toBe expectedValue message
        .endif
.endm

;====
; (Private) Asserts that D is equal to the expected value, otherwise fails the test
;
; @in   d   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.d._toBe" free
    expect.d._toBe:
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
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.e.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        .if NARGS == 1
            zest.byteAssertion.assert expect.e._toBe expectedValue expect.e.toBe.defaultMessage
        .else
            zest.utils.validate.string message "\.: Message should be a string"
            zest.byteAssertion.assert expect.e._toBe expectedValue message
        .endif
.endm

;====
; (Private) Asserts that E is equal to the expected value, otherwise fails the test
;
; @in   e   the value
; @in   hl  pointer to the assertion data
;====
.section "expect.e._toBe" free
    expect.e._toBe:
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
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.h.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        .if NARGS == 1
            zest.byteAssertion.assert expect.h._toBe expectedValue expect.h.toBe.defaultMessage
        .else
            zest.utils.validate.string message "\.: Message should be a string"
            zest.byteAssertion.assert expect.h._toBe expectedValue message
        .endif
.endm

;====
; (Private) Asserts that H is equal to the expected value, otherwise fails the test
;
; @in   h   the value
; @in   de  pointer to the assertion data
;====
.section "expect.h._toBe" free
    expect.h._toBe:
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
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.l.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        .if NARGS == 1
            zest.byteAssertion.assert expect.l._toBe expectedValue expect.l.toBe.defaultMessage
        .else
            zest.utils.validate.string message "\.: Message should be a string"
            zest.byteAssertion.assert expect.l._toBe expectedValue message
        .endif
.endm

;====
; (Private) Asserts that L is equal to the expected value, otherwise fails the test
;
; @in   l   the value
; @in   de  pointer to the assertion data
;====
.section "expect.l._toBe" free
    expect.l._toBe:
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
; @in   ixh             the actual value
; @in   expectedValue   the expected value
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.ixh.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        .if NARGS == 1
            zest.byteAssertion.assert expect.ixh._toBe expectedValue expect.ixh.toBe.defaultMessage
        .else
            zest.utils.validate.string message "\.: Message should be a string"
            zest.byteAssertion.assert expect.ixh._toBe expectedValue message
        .endif
.endm

;====
; (Private) Asserts that IXH is equal to the expected value, otherwise fails the test
;
; @in   ixh the value
; @in   hl  pointer to the assertion data
;====
.section "expect.ixh._toBe" free
    expect.ixh._toBe:
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
; @in   ixl             the actual value
; @in   expectedValue   the expected value
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.ixl.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        .if NARGS == 1
            zest.byteAssertion.assert expect.ixl._toBe expectedValue expect.ixl.toBe.defaultMessage
        .else
            zest.utils.validate.string message "\.: Message should be a string"
            zest.byteAssertion.assert expect.ixl._toBe expectedValue message
        .endif
.endm

;====
; (Private) Asserts that IXL is equal to the expected value, otherwise fails the test
;
; @in   ixl the value
; @in   hl  pointer to the assertion data
;====
.section "expect.ixl._toBe" free
    expect.ixl._toBe:
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
; @in   iyh             the actual value
; @in   expectedValue   the expected value
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.iyh.toBe" args expectedValue message
     zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        .if NARGS == 1
            zest.byteAssertion.assert expect.iyh._toBe expectedValue expect.iyh.toBe.defaultMessage
        .else
            zest.utils.validate.string message "\.: Message should be a string"
            zest.byteAssertion.assert expect.iyh._toBe expectedValue message
        .endif
.endm

;====
; (Private) Asserts that IYH is equal to the expected value, otherwise fails the test
;
; @in   iyh the value
; @in   hl  pointer to the assertion data
;====
.section "expect.iyh._toBe" free
    expect.iyh._toBe:
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
; @in   iyl             the actual value
; @in   expectedValue   the expected value
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.iyl.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        .if NARGS == 1
            zest.byteAssertion.assert expect.iyl._toBe expectedValue expect.iyl.toBe.defaultMessage
        .else
            zest.utils.validate.string message "\.: Message should be a string"
            zest.byteAssertion.assert expect.iyl._toBe expectedValue message
        .endif
.endm

;====
; (Private) Asserts that IYL is equal to the expected value, otherwise fails the test
;
; @in   iyl the value
; @in   hl  pointer to the assertion data
;====
.section "expect.iyl._toBe" free
    expect.iyl._toBe:
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
; @in   i               the actual value
; @in   expectedValue   the expected value
; @in   message         (optional) Custom string assertion failure message
;====
.macro "expect.i.toBe" args expectedValue message
    zest.utils.validate.byte expectedValue "\. expects a numeric byte value"

    \@_\..{expectedValue}:
        .if NARGS == 1
            zest.byteAssertion.assert expect.i._toBe expectedValue expect.i.toBe.defaultMessage
        .else
            zest.utils.validate.string message "\.: Message should be a string"
            zest.byteAssertion.assert expect.i._toBe expectedValue message
        .endif
.endm

;====
; (Private) Asserts that I is equal to the expected value, otherwise fails the test
;
; @in   i the value
; @in   hl  pointer to the assertion data
;====
.section "expect.i._toBe" free
    expect.i._toBe:
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
