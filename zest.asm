;====
; Zest - Sega Master System/Z80 Test Runner
;
; Ensure you point to the Zest directory before including this file, i.e,
;
; .incdir "../zest"             ; point to Zest directory
;     .include "zest.asm"       ; include this file
; .incdir "."                   ; return to current directory
;====

;====
; Process options
;====
.include "./src/utils/assert.asm"

;====
; Include library
;====

.include "./src/mapper.asm"

.bank zest.mapper.ZEST_BANK slot zest.mapper.ZEST_SLOT

.include "./src/main.asm"
.include "./src/vdp.asm"

.include "./src/console/console.asm"
.include "./src/console/data.asm"

.include "./src/timeout.asm"

.include "./src/test.asm"
.include "./src/mock.asm"
.include "./src/runner.asm"

.include "./src/expect/flags.asm"
.include "./src/expect/mock.asm"
.include "./src/expect/r.toBe.asm"
.include "./src/expect/rr.toBe.asm"

.include "./src/suites.asm"

;====
; Global aliases
;====

.define zest.RAM_SLOT zest.mapper.RAM_SLOT

;====
; Describes the unit being tested
;
; @in   message     a description string of the unit
;====
.macro "describe" args message
    zest.runner.startDescribeBlock message
.endm

;====
; Describes a test scenario and generates prep code to run it
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

;====
; Sets the expected number of full frames a test should pass within, otherwise
; timeout and fail the test.
;
; @in   frames  the number of full frames (1-255)
;====
.macro "zest.setTimeout" args frames
    zest.timeout.setCurrent frames
.endm