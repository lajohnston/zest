; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
    ; .include "./src/mapper.asm"
.incdir "."

; ;====
; ; Boot sequence
; ;====
; .orga $0000
; .section "zest.main" force
;     di              ; disable interrupts
;     im 1            ; Interrupt mode 1
;     ld sp, $dff0    ; set stack pointer
;     jp zest.suite
; .ends

; .section "zest.runner.finish" free
;     zest.runner.finish:
;         ret
; .ends

; .section "zest.preSuite" free keep
;     zest.preSuite:
;         nop
; .ends

; .section "zest.preSuite.end" after zest.preSuite keep
;     ret
; .ends

; .section "zest.suite" free bank 1 slot 1 keep
;     zest.suite:
;         call zest.preSuite

;         ; Tests get appended here

;         ; zest.suite.end finished the code block
; .ends

; ;====
; ; The end of the default suite
; ;====
; .section "zest.suite.end" after zest.suite keep
;     jp zest.runner.finish
;     ; ret
; .ends