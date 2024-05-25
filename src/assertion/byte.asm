;====
; Byte (8-bit value) assertion
;====
.struct "zest.assertion.byte"
    expectedValue:  db
    messagePointer: dw
.endst

;====
; Generates a call the given routine followed immediately by the assertion data.
; The routine should use ex (sp), hl to pop the assertion data pointer from the
; stack.
;
; If the assertion passes, the routine should return to the caller using
; zest.assertion.byte.return
;
; @in   routine         the routine label to call
; @in   expectedValue   the expected byte value
; @in   message         pointer to a assertion failure message, or a custom
;                       message string
;====
.macro "zest.assertion.byte.assert" isolated args routine expectedValue message
    ; Assert arguments (assemble-time)
    zest.utils.validate.equals NARGS 3 "\.: Unexpected number of arguments"
    zest.utils.validate.byte expectedValue "\. expectedValue should be an 8-bit value"

    .if \?3 == ARG_STRING
        jp +
            \.\@messagePointer:
                zest.console.defineString message
        +:
    .elif \?3 == ARG_LABEL
        .redefine \.\@messagePointer message
    .else
        zest.utils.validate.fail "\.: message should be a string or a label"
    .endif

    ; Call the assertion routine
    call routine

    ; Define the assertion data. The routine should skip over this if it returns
    _assertionData:
        .db expectedValue
        .dw \.\@messagePointer
.endm

;====
; Displays details about a byte/single register assertion that doesn't match
; the expectation, then stops the program
;
; @in   a   the actual value
; @in   ix  pointer to the assertion data
;====
.section "zest.assertion.byte.failed" free
    zest.assertion.byte.failed:
        call zest.assertion.printTestDescription

        ; Print assertion message
        call zest.assertion.printSeparator
        call zest.assertion.byte.printMessage

        ; Print 'Expected:' label
        call zest.assertion.printExpectedLabel

        ; Print expected value
        call zest.assertion.byte.printExpected

        ; Print 'Actual:' label
        call zest.assertion.printActualLabel

        ; Print actual value
        call zest.console.outputHexA
        jp zest.console.displayAndStop
.ends

;====
; Should be called at the end of the assertion routine if it passes. This
; restores HL and returns to the test/caller, skipping over the inline assertion
; data defined directly after it by zest.assertion.byte.assert
;
; @in       hl          pointer to zest.assertion.byte instance
; @in       stack{0}    original value of HL
;====
.macro "zest.assertion.byte.return"
    ; Skip over the byte assertion data
    .repeat _sizeof_zest.assertion.byte
        inc hl
    .endr

    ; Push the new return address to RAM
    ex (sp), hl     ; restore HL; push return address to stack
    ret             ; return to the address we pushed
.endm

;====
; (Private) Asserts that A is equal to the expected value, otherwise fails the test
;
; @in   a   the value
; @in   hl  pointer to zest.assertion.byte instance
;====
.section "zest.assertion.byte.assertAEquals" free
    zest.assertion.byte.assertAEquals:
        push af
            cp (hl)
            jr nz, _fail
        pop af
        ret

    _fail:
        ; Set IX to pointer
        push hl
        pop ix

        jp zest.assertion.byte.failed
.ends

;====
; Prints the assertion failure message to the on-screen console
;
; @in   ix  pointer to the zest.assertion.byte instance
;====
.section "zest.assertion.byte.printMessage" free
    zest.assertion.byte.printMessage:
        push hl
            ld l, (ix + zest.assertion.byte.messagePointer)
            ld h, (ix + zest.assertion.byte.messagePointer + 1)
            call zest.console.out
        pop hl

        ret
.ends

;====
; Prints the expected word value to the on-screen console
;
; @in   ix  pointer to the zest.assertion.byte instance
;====
.section "zest.assertion.byte.printExpected"
    zest.assertion.byte.printExpected:
        push af
            ; Set A to expected value
            ld a, (ix + zest.assertion.byte.expectedValue)
            call zest.console.outputHexA
        pop af
        ret
.ends
