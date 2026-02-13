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

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "addressAssertions.test.asm"
    .include "assertions.test.asm"
    .include "pointerAssertions.test.asm"
    .include "stackAssertions.test.asm"
.ends
