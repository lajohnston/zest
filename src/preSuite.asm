;====
; Code block that runs at the start of the test suite. Append custom code to
; zest.preSuite using .section "foo" appendto zest.preSuite
;====
.section "zest.preSuite" free keep
    zest.preSuite:
.ends

;====
; Returns at the end of the preSuite hook
;====
.section "zest.preSuite.end" appendto zest.preSuite keep
    ret
.ends
