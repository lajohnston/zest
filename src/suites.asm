;====
; Main suite
;====

;====
; The start of the default suite
;====
.section "zest.suite" free bank zest.mapper.SUITE_BANK_1 slot zest.mapper.SUITE_SLOT
    zest.suite:
        call zest.preSuite

        ; Tests get appended here

        ; zest.suite.end finishes the code block
.ends

;====
; The end of the default suite
;====
.section "zest.suite.end" appendto zest.suite priority -9999999999
    jp zest.runner.finish
.ends
