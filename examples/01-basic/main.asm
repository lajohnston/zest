; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
.incdir "."

; Include any code you want to test
.include "increment.asm"

; Define a zest.suite label
.section "suite" free
    zest.suite:
        ; Include the test files
        .include "increment.test.asm"

        ; Remember to return afterwards
        ret
.ends
