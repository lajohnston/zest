;====
; SMSSpec - Sega Master System/Z80 Test Runner
;
; Ensure you point to the smsspec directory before including this file, i.e,
;
; .incdir "../smsspec"          ; point to smsspec directory
;   .include "smsspec.asm"      ; include this file
; .incdir "."                   ; return to current directory
;====

.include "./src/main.asm"

.include "./src/expect.asm"
.include "./src/mock.asm"
.include "./src/runner.asm"
.include "./src/vdp.asm"

.include "./src/console/console.asm"
.include "./src/console/data.asm"

;====
; Global aliases
;====

;====
; Can be used to describe the unit being tested
;
; @in   message     a description string of the unit
;====
.macro "describe" args message
    smsspec.runner.describe message
.endm

;====
; Define a test scenario. Generates the code to reset some of the system state
; such as register values
;
; @in   message     a description string of the test
;====
.macro "it" args message
    smsspec.runner.startTest message
.endm
