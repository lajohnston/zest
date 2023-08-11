;====
; Zest - Sega Master System/Z80 Test Runner
;
; Ensure you point to the Zest directory before including this file, i.e,
;
; .incdir "../zest"             ; point to Zest directory
;     .include "zest.asm"       ; include this file
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
    zest.runner.describe message
.endm

;====
; Define a test scenario. Generates the code to reset some of the system state
; such as register values
;
; @in   message     a description string of the test
;====
.macro "it" args message
    zest.runner.startTest message
.endm

;====
; Alias for 'it'
;
; @in   message     a description string of the test
;====
.macro "test" args message
    it message
.endm
