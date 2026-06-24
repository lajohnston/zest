;====
; Zest - input mocking example
;====

; Include Zest
.incdir "../../"
    .include "zest.asm"
.incdir "."

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "waitForActiveDisplay.test.asm"
.ends
