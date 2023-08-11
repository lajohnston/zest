;====
; Zest - Assertion tests
;
; This example just demonstrates various assertions the library currently
; offers out of the box, but you can always write your own if needed :)
;====

; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
.incdir "."

; Define a zest.suite label
.section "suite" free
    zest.suite:
        ; Include the test files
        .include "assertions.test.asm"

        ; Remember to return afterwards
        ret
.ends
