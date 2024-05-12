;====
; Word (16-bit value) assertion
;====
.struct "zest.ByteAssertion"
    expectedValue:  db
    messagePointer: dw
.endst

;====
; Defines inline assertion data and sets zest.byteAssertion.define.returnValue
; to the addres
;
; @in   expectedValue   the expected byte value
; @in   message         pointer to a assertion failure message, or a custom
;                       message string
;
; @out zest.byteAssertion.define.returnValue    address of the data
;====
.macro "zest.byteAssertion.define" isolated args expectedValue message
    ; Assert arguments (assemble-time)
    zest.utils.assert.equals NARGS 2 "\.: Unexpected number of arguments"
    zest.utils.assert.byte expectedValue "\. expectedValue should be an 8-bit value"

    ; Define data
    .if \?2 == ARG_STRING
        jp +
            \.\@_assertionData:
                .db expectedValue
                .dw _customMessage
                _customMessage:
                    zest.console.defineString message
        +:
    .elif \?2 == ARG_LABEL
        jr +
            \.\@_assertionData:
                .db expectedValue
                .db <(message)
                .db >(message)
        +:
    .else
        zest.utils.assert.fail "\.: message should be a string or a label"
    .endif

    .redefine zest.byteAssertion.define.returnValue (\.\@_assertionData)
.endm

;====
; Prints the assertion failure message to the on-screen console
;
; @in   ix  pointer to the word zest.assertion.Word instance
;====
.section "zest.byteAssertion.printMessage" free
    zest.byteAssertion.printMessage:
        push hl
            ld l, (ix + zest.ByteAssertion.messagePointer)
            ld h, (ix + zest.ByteAssertion.messagePointer + 1)
            call zest.console.out
        pop hl

        ret
.ends

;====
; Prints the expected word value to the on-screen console
;
; @in   ix  pointer to the zest.ByteAssertion instance
;====
.section "zest.byteAssertion.printExpected"
    zest.byteAssertion.printExpected:
        push af
            ; Set A to expected value
            ld a, (ix + zest.ByteAssertion.expectedValue)
            call zest.console.outputHexA
        pop af
        ret
.ends
