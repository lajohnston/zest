;====
; Word (16-bit value) assertion
;====
.struct "zest.assertion.byte"
    expectedValue:  db
    messagePointer: dw
.endst

;====
; Generates a call the given routine followed by the assertion data. The routine
; should use zest.assertion.byte.loadHLPointer or loadDEPointer to pop the
; assertion data pointer from the stack.
;
; If the assertion passes, the routine should return to the caller using
; zest.assertion.byte.return.HL or return.DE.
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
; Should be called at the beginning of the assertion routine to preserve HL and
; pop the assertion data pointer from the stack
;
; @out  de  pointer to the zest.assertion.byte instance
;====
.macro "zest.assertion.byte.loadDEPointer" isolated args routine
    ld (zest.runner.tempWord), de   ; preserve DE
    pop de                          ; pop data pointer to DE
.endm

;====
; Should be called at the beginning of the assertion routine to preserve HL and
; pop the assertion data pointer from the stack
;
; @out  hl  pointer to the zest.assertion.byte instance
;====
.macro "zest.assertion.byte.loadHLPointer" isolated args routine
    ld (zest.runner.tempWord), hl   ; preserve HL
    pop hl                          ; pop data pointer to HL
.endm

;====
; Should be called at the end of the assertion routine if it passes. This
; restores DE and returns to the test/caller, skipping over the inline assertion
; data
;====
.macro "zest.assertion.byte.return.DE"
    ; Skip over the byte assertion data
    .repeat _sizeof_zest.assertion.byte
        inc de
    .endr

    ; Push the new return address to RAM
    push de
    ld de, (zest.runner.tempWord)   ; restore DE
    ret ; return to the address we pushed
.endm

;====
; Should be called at the end of the assertion routine if it passes. This
; restores HL and returns to the test/caller, skipping over the inline assertion
; data
;====
.macro "zest.assertion.byte.return.HL"
    ; Skip over the byte assertion data
    .repeat _sizeof_zest.assertion.byte
        inc hl
    .endr

    ; Push the new return address to RAM
    push hl
    ld hl, (zest.runner.tempWord)   ; restore HL
    ret ; return to the address we pushed
.endm

;====
; Prints the assertion failure message to the on-screen console
;
; @in   ix  pointer to the word zest.assertion.Word instance
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
