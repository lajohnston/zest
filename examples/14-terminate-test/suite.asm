;====
; This example demonstrates manually terminating a test
;====

; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
.incdir "."

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "terminate-test.asm"
.ends
