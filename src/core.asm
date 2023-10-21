;====
; Imports the core framework without plugins
;====

; ASCII table
.asciitable
    map " " to "~" = 0
.enda

; Utils
.include "./src/utils/assert.asm"

; Memory mapper
.include "./src/mapper.asm"
.bank zest.mapper.ZEST_BANK slot zest.mapper.ZEST_SLOT

; Handlers (boot, interrupts, pause)
.include "./src/handlers.asm"

; Console
.include "./src/vdp.asm"
.include "./src/console/console.asm"
.include "./src/console/data.asm"

; Runner
.include "./src/suites.asm"
.include "./src/runner.asm"
.include "./src/test.asm"
.include "./src/timeout.asm"

; Assertions
.include "./src/expect/flags.asm"
.include "./src/expect/r.toBe.asm"
.include "./src/expect/rr.toBe.asm"

; Hooks
.include "./src/preSuite.asm"
.include "./src/preTest.asm"
.include "./src/postTest.asm"

;====
; Global aliases (zest namespace)
;====

.define zest.RAM_SLOT   zest.mapper.RAM_SLOT

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

;====
; Fails the current test with an assertion message
;
; @in   [message]   optional failure message
;====
.macro "zest.fail" args message
    zest.runner.fail message
.endm