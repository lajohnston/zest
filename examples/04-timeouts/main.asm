;====
; This example demonstrates Zest's timeout mechanism
;====

; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
.incdir "."

; Include any code you want to test
.include "slowRoutine.asm"

; Define a zest.suite label
.section "suite" free
    zest.suite:
        ; Include the test files
        .include "slowRoutine.test.asm"

        ; Remember to return afterwards
        ret
.ends
