;====
; Word (16-bit value) assertion
;====
.struct "zest.assertion.word"
    expectedValue:  dw
    messagePointer: dw
.endst

;====
; Defines inline assertion data and sets zest.assertion.word.define.returnValue
; to the addres
;
; @in   expectedValue   the expected word value
; @in   message         pointer to a assertion failure message, or a custom
;                       message string
;
; @out zest.assertion.word.define.returnValue    address of the data
;====
.macro "zest.assertion.word.define" isolated args expectedValue message
    ; Assert arguments (assemble-time)
    zest.utils.validate.equals NARGS 2 "\.: Unexpected number of arguments"
    zest.utils.validate.word expectedValue "\. expectedValue should be a 16-bit value"

    ; Define data
    .if \?2 == ARG_STRING
        jp +
            \.\@_assertionData:
                .dw expectedValue
                .dw _customMessage
                _customMessage:
                    zest.console.defineString message
        +:
    .elif \?2 == ARG_LABEL
        jr +
            \.\@_assertionData:
                .dw expectedValue
                .db <(message)
                .db >(message)
        +:
    .else
        zest.utils.validate.fail "\.: message should be a string or a label"
    .endif

    .redefine zest.assertion.word.define.returnValue (\.\@_assertionData)
.endm

;====
; Generates a call the given routine followed immediately by the assertion data.
; The routine should use ex (sp), hl to pop the assertion data pointer from the
; stack.
;
; If the assertion passes, the routine should return to the caller using
; zest.assertion.byte.return.HL or return.DE.
;
; @in   routine         the routine label to call
; @in   expectedValue   the expected word value
; @in   message         pointer to a assertion failure message, or a custom
;                       message string
;====
.macro "zest.assertion.word.assert" isolated args routine expectedValue message
    ; Assert arguments (assemble-time)
    zest.utils.validate.equals NARGS 3 "\.: Unexpected number of arguments"
    zest.utils.validate.word expectedValue "\. expectedValue should be a word value"

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
        .dw expectedValue
        .dw \.\@messagePointer
.endm

;====
; Should be called at the end of the assertion routine if it passes. This
; restores HL and returns to the test/caller, skipping over the inline assertion
; data defined directly after it by zest.assertion.word.assert
;
; @in       hl          pointer to zest.assertion.word instance
; @in       stack{0}    original value of HL
;====
.macro "zest.assertion.word.return"
    ; Skip over the word assertion data
    .repeat _sizeof_zest.assertion.word
        inc hl
    .endr

    ; Push the new return address to RAM
    ex (sp), hl     ; restore HL; push return address to stack
    ret             ; return to the address we pushed
.endm

;====
; Asserts DE is equal to the expected value, otherwise fails the test
;
; @in   de  the actual value
; @in   hl  the expected value
;====
.section "zest.assertion.word.assertDEEquals" free
    zest.assertion.word.assertDEEquals:
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
        jp zest.assertion.word.failed
.ends

;====
; Displays details about a 16-bit value assertion that doesn't match
; the expectation, then stops the program
;
; @in   de  the actual value
; @in   ix  pointer to the assertion.Word instance, containing the expected
;           value and assertion message
;====
.section "zest.assertion.word.failed" free
    zest.assertion.word.failed:
        call zest.assertion.printTestDescription

        ; Print assertion message
        call zest.assertion.printSeparator
        call zest.assertion.word.printMessage

        ; Print expected label
        call zest.assertion.printExpectedLabel

        ; Print expected value
        call zest.assertion.word.printExpected

        ; Print actual label
        call zest.assertion.printActualLabel

        ; Print actual value
        call zest.console.outputHexDE
        jp zest.console.displayAndStop
.ends

;====
; Prints the assertion failure message to the on-screen console
;
; @in   ix  pointer to the word zest.assertion.Word instance
;====
.section "zest.assertion.word.printMessage" free
    zest.assertion.word.printMessage:
        push hl
            ld l, (ix + zest.assertion.word.messagePointer)
            ld h, (ix + zest.assertion.word.messagePointer + 1)
            call zest.console.out
        pop hl

        ret
.ends

;====
; Prints the expected word value to the on-screen console
;
; @in   ix  pointer to the zest.assertion.word instance
;====
.section "zest.assertion.word.printExpected"
    zest.assertion.word.printExpected:
        push bc
            ld c, (ix + 0)
            ld b, (ix + 1)
            call zest.console.outputHexBC
        pop bc
        ret
.ends
