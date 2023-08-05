;====
; SMSSPec - input mocking example
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

; Include smsspec
.incdir "../../"
    .include "smsspec.asm"
.incdir "."

;====
; Define mock instances in RAM
;====
.ramsection "mock instances" appendto smsspec.mocks
    readPlayer1Input instanceof smsspec.mock
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

; Define an smsspec.suite label, which smsspec will call
.section "smsspec.suite" free
    smsspec.suite:
        ; Include your test suite files
        .include "player.test.asm"

        ; End of test suite
        ret
.ends
