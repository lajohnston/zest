;====
; Code block that runs at the start of the test suite. Append custom code to
; zest.preSuite using .section "foo" appendto zest.preSuite
;====
.section "zest.preSuite" free keep
    zest.preSuite:
.ends

;====
; Returns at the end of the preSuite hook
; The negative priority ensures it's placed after the other sections
;====
.section "zest.preSuite.end" appendto zest.preSuite priority zest.FOOTER_PRIORITY
    ret
.ends
