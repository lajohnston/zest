; Include the Zest lib
.incdir "../"           ; point to directory containing zest.asm
.include "zest.asm"
.incdir "."             ; return to current directory

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "tests/example.test.asm"
.ends
