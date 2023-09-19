;====
; Zest - input mocking example
;====

; Include Zest
.incdir "../../"
    .include "zest.asm"
.incdir "."

;====
; Rather than importing the real 'readPort' macro, we'll define this fake one
; that calls the Zest input macros instead
;===
.macro "readPort" args portNumber
    .if portNumber == $dc
        zest.loadFakePortDC
    .elif portNumber == $dd
        zest.loadFakePortDD
    .endif
.endm

; Include the files to test
.include "player.asm"

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "player.test.asm"
.ends
