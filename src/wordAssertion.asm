;====
; Word (16-bit value) assertion
;====
.struct "zest.WordAssertion"
    expectedValue:  dw
    messagePointer: dw
.endst

;====
; Asserts the given condition at runtime
;
; @in   routine         the assertion routine to call, accepting HL as a pointer
;                       to the zest.WordAssertion instance
; @in   expectedValue   the expected word value
; @in   message         pointer to a assertion failure message, or a custom
;                       message string
;====
.macro "zest.wordAssertion.assert" isolated args routine expectedValue message
    ; Assert arguments (assemble-time)
    zest.utils.assert.equals NARGS 3 "\.: Unexpected number of arguments"
    zest.utils.assert.label routine "\.: routine argument should be a label"
    zest.utils.assert.word expectedValue "\. expectedValue should be a 16-bit value"

    ; Define data
    .if \?3 == ARG_STRING
        jp +
            _assertionData:
                .dw expectedValue
                .dw _customMessage
                _customMessage:
                    zest.console.defineString message
        +:
    .elif \?3 == ARG_LABEL
        jr +
            _assertionData:
                .dw expectedValue
                .db <(message)
                .db >(message)
        +:
    .else
        zest.utils.assert.fail "\.: message should be a string or a label"
    .endif

    ; Call assertion routine
    push hl
        ld hl, _assertionData
        call routine
    pop hl
.endm

;====
; Prints the assertion failure message to the on-screen console
;
; @in   ix  pointer to the word zest.assertion.Word instance
;====
.section "zest.wordAssertion.printMessage" free
    zest.wordAssertion.printMessage:
        push hl
            zest.console.newlines 3

            ; Write assertion message
            ld hl, zest.console.data.separatorText
            call zest.console.out

            zest.console.newlines 2

            ld l, (ix + zest.WordAssertion.messagePointer)
            ld h, (ix + zest.WordAssertion.messagePointer + 1)
            call zest.console.out
        pop hl

        ret
.ends

;====
; Prints the expected word value to the on-screen console
;
; @in   ix  pointer to the zest.assertion.Word instance
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
