; Include the smsspec lib
.incdir "../../"
    .include "smsspec.asm"
.incdir "."

; Include any code you want to test
.include "increment.asm"

; Define an smsspec.suite label
.section "suite" free
    smsspec.suite:
        ; Include the test files
        .include "increment.test.asm"

        ; Remember to return afterwards
        ret
.ends
