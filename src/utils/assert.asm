;====
; Prints an error message and stops the assembler
;====
.macro "zest.utils.assert.fail" args message
    .print "\n", message, "\n\n"
    .fail
.endm

;====
; Asserts that the given value is a numeric value within a given range
;
; @in   value   the value to assert
; @in   min     the minimum value
; @in   max     the maximum value
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.assert.range" args value min max message
    .if \?1 != ARG_NUMBER
        zest.utils.assert.fail message
    .endif

    .if value > max
        zest.utils.assert.fail message
    .endif

    .if value < min
        zest.utils.assert.fail message
    .endif
.endm

;====
; Asserts that the given value is a signed or unsigned byte in the value range
; of -128 to 255, otherwise fails
;
; @in   value   the value to assert
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.assert.byte" args value message
    zest.utils.assert.range value, -128, 255, message
.endm

;====
; Asserts that the given value is a signed or unsigned word in the value range
; of -32768 to 65,535, otherwise fails
;
; @in   value   the value to assert
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.assert.word" args value message
    zest.utils.assert.range value, -32768, 65535, message
.endm

;====
; Asserts that the given value is a 1 or a 0
;
; @in   value   the value to assert
;====
.macro "zest.utils.assert.boolean" args value message
    zest.utils.assert.range value 0, 1, message
.endm
