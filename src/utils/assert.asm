;====
; Prints an error message and stops the assembler
;====
.macro "zest.utils.assert.fail" args message
    .print "\n", message, "\n\n"
    .fail
.endm

;====
; Asserts that the given value is a signed or unsigned byte in the value range
; of -128 to 255
;
; @in   value   the value to assert
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
