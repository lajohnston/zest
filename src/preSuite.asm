;====
; Code block that runs at the start of the test suite. Append custom code to
; zest.preSuite using .section "foo" appendto zest.preSuite
;====
.section "zest.preSuite" free   ; adding keep fixes it
    zest.preSuite:
        nop
.ends

; .section "zest.preSuiteNop" appendto zest.preSuite
;     nop
; .ends

;====
; Returns at the end of the preSuite hook
;====
.section "zest.preSuite.end" keep after zest.preSuite
    ret
.ends


; .section "header" free keep
;     header:
;         nop
; .ends

; .section "body" free keep
;     nop
; .ends

; .section "footer" after someSection keep
;     ret
; .ends