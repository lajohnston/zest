;====
; Prints an error message and stops the assembler
;====
.macro "zest.utils.validate.fail" args message
    .print "\nZest error:\n  ", message, "\n\n"
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
.macro "zest.utils.validate.range" args value min max message
    .if \?1 != ARG_NUMBER
        zest.utils.validate.fail message
    .endif

    .if value > max
        zest.utils.validate.fail message
    .endif

    .if value < min
        zest.utils.validate.fail message
    .endif
.endm

;====
; Asserts that the value matches the expected value
;
; @in   actual      actual value
; @in   expected    expected value
; @in   message     the message to print to the terminal if the actual value is
;                   not equal to the expected value
;====
.macro "zest.utils.validate.equals" args actual expected message
    .if actual != expected
        zest.utils.validate.fail message
    .endif
.endm

;====
; Asserts that the given value is a signed or unsigned byte in the value range
; of -128 to 255, otherwise fails
;
; @in   value   the value to assert
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.validate.byte" args value message
    zest.utils.validate.range value, -128, 255, message
.endm

;====
; Asserts that the given value is a signed or unsigned word in the value range
; of -32768 to 65,535, otherwise fails
;
; @in   value   the value to assert
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.validate.word" args value message
    zest.utils.validate.range value, -32768, 65535, message
.endm

;====
; Asserts that the given value is a signed or unsigned word in the value range
; of -32768 to 65,535, or a label, otherwise fails
;
; @in   value   the value to assert
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.validate.wordOrLabel" args value message
    .if \?1 == ARG_NUMBER
        zest.utils.validate.word value, message
    .elif \?1 != ARG_LABEL
        zest.utils.validate.fail message
    .endif
.endm

;====
; Asserts that the given value is a 1 or a 0
;
; @in   value   the value to assert
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.validate.boolean" args value message
    zest.utils.validate.range value 0, 1, message
.endm

;====
; Asserts that the given value is a label
;
; @in   value   the value to assert
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.validate.label" args value message
    .if \?1 != ARG_LABEL
        zest.utils.validate.fail message
    .endif
.endm

;====
; Asserts that the given value is a string
;
; @in   value   the value to assert
; @in   message the message to print to the terminal if the value is not valid
;====
.macro "zest.utils.validate.string" args value message
    .if \?1 != ARG_STRING
        zest.utils.validate.fail message
    .endif
.endm
