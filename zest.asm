;====
; Zest - Sega Master System/Z80 Test Runner
;
; Ensure you point to the Zest directory before including this file, i.e,
;
; .incdir "../zest"             ; point to Zest directory
;     .include "zest.asm"       ; include this file
; .incdir "."                   ; return to current directory (optional)
;====

; Core framework
.include "./src/core.asm"

;===
; Core plugins
;===
.ifndef zest.plugin.mockInput
    .include "./src/plugins/mockInput.asm"
.endif

.ifndef zest.plugin.mock
    .include "./src/plugins/mock.asm"
.endif
