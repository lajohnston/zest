; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
.incdir "."

; Include any code you want to test
.include "increment.asm"

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "increment.test.asm"
.ends
