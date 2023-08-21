;====
; Zest - input mocking example
;
; At times it will be necessary to stub/mock out parts of the code to simulate
; particularly scenarios. One such case is with input handling, as we want to
; simulate certain inputs without having to manually press these on the joypad
;
; First, it will be necessary to separate out the code that reads the input
; and ensure it doesn't get included into this test suite. This could be a
; simple macro in a file that reads the player 1 input using 'in a, $df'
;
; We can then mock this routine out so each test can define its own fake routine
; and return a particular value.
;====

; Include Zest
.incdir "../../"
    .include "zest.asm"
.incdir "."

;====
; Define mock instances in RAM
;====
.ramsection "mock instances" appendto zest.mocks
    readPlayer1Input instanceof zest.mock
.ends

;====
; As readPlayer1Input would be a macro, we'll create a dummy macro with the
; same name that just calls the mock instance we created in RAM
;====
.macro "readPlayer1Input"
    call readPlayer1Input
.endm

; Include the files to test
.include "player.asm"

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "player.test.asm"
.ends
