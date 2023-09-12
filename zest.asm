;====
; Zest - Sega Master System/Z80 Test Runner
;
; Ensure you point to the Zest directory before including this file, i.e,
;
; .incdir "../zest"             ; point to Zest directory
;     .include "zest.asm"       ; include this file
; .incdir "."                   ; return to current directory
;====

;====
; Process options
;====
.include "./src/utils/assert.asm"

;====
; Include library
;====

.include "./src/mapper.asm"

.bank zest.mapper.ZEST_BANK slot zest.mapper.ZEST_SLOT

.include "./src/main.asm"
.include "./src/vdp.asm"

.include "./src/console/console.asm"

.include "./src/runner.asm"

.include "./src/preSuite.asm"
.include "./src/preTest.asm"
