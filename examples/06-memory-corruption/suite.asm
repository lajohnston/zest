;====
; This example demonstrates code that goes rogue and corrupts other contents in
; RAM. Zest should detect when its own RAM has been overwritten and stop the
; suite
;====

; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
.incdir "."

; Include any code you want to test
.include "corruption.asm"

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "corruption.test.asm"
.ends
