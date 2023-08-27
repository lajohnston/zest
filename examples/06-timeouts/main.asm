;====
; This example demonstrates Zest's timeout mechanism
;====

; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
.incdir "."

; Include any code you want to test
.include "slowRoutine.asm"

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "slowRoutine.test.asm"
.ends
