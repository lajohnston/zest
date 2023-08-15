;====
; Prints an error message and stops the assembler
;====
.macro "zest.utils.assert.fail" args message
    .print "\n", message, "\n\n"
    .fail
.endm

;====
; Asserts that the given value is a signed or unsigned byte in the value range
; of -128 to 255, otherwise fails
;
; @in   value   the value to assert
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.assert.byte" args value message
    .if \?1 != ARG_NUMBER
        zest.utils.assert.fail message
    .endif

    .if value > 255
        zest.utils.assert.fail message
    .endif

    .if value < -128
        zest.utils.assert.fail message
    .endif
.endm

;====
; Asserts that the given value is a signed or unsigned word in the value range
; of -32768 to 65,535, otherwise fails
;
; @in   value   the value to assert
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.assert.word" args value message
    .if \?1 != ARG_NUMBER
        zest.utils.assert.fail message
    .endif

    .if value > 65535
        zest.utils.assert.fail message
    .endif

    .if value < -32768
        zest.utils.assert.fail message
    .endif
.endm

;====
; Asserts that the given value is a 1 or a 0
;
; @in   value   the value to assert
;====
.macro "zest.utils.assert.boolean" args value message
    .if \?1 != ARG_NUMBER
        zest.utils.assert.fail message
    .endif

    .if value > 1
        zest.utils.assert.fail message
    .endif

    .if value < 0
        zest.utils.assert.fail message
    .endif
.endm
