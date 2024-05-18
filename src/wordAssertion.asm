;====
; Word (16-bit value) assertion
;====
.struct "zest.WordAssertion"
    expectedValue:  dw
    messagePointer: dw
.endst

;====
; Defines inline assertion data and sets zest.wordAssertion.define.returnValue
; to the addres
;
; @in   expectedValue   the expected word value
; @in   message         pointer to a assertion failure message, or a custom
;                       message string
;
; @out zest.wordAssertion.define.returnValue    address of the data
;====
.macro "zest.wordAssertion.define" isolated args expectedValue message
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

    .redefine zest.wordAssertion.define.returnValue (\.\@_assertionData)
.endm

;====
; Prints the assertion failure message to the on-screen console
;
; @in   ix  pointer to the word zest.assertion.Word instance
;====
.section "zest.wordAssertion.printMessage" free
    zest.wordAssertion.printMessage:
        push hl
            ld l, (ix + zest.WordAssertion.messagePointer)
            ld h, (ix + zest.WordAssertion.messagePointer + 1)
            call zest.console.out
        pop hl

        ret
.ends

;====
; Prints the expected word value to the on-screen console
;
; @in   ix  pointer to the zest.WordAssertion instance
;====
.section "zest.wordAssertion.printExpected"
    zest.wordAssertion.printExpected:
        push bc
            ld c, (ix + 0)
            ld b, (ix + 1)
            call zest.console.outputHexBC
        pop bc
        ret
.ends
