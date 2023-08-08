;====
; SMSSpec - Sega Master System/Z80 Test Runner
;
; Ensure you point to the smspec directory before including this file, i.e,
;
; .incdir "../smsspec"          ; point to smspec directory
;   .include "smsspec.asm"      ; include this file
; .incdir "."                   ; return to current directory
;====

.include "./src/main.asm"

.include "./src/expect.asm"
.include "./src/mock.asm"
.include "./src/runner.asm"
.include "./src/vdp.asm"

.include "./src/console/console.asm"
.include "./src/console/data.asm"
