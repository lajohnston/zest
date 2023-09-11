;====
; Main suite
;====

;====
; The start of the default suite
;====
.section "zest.suite" free bank zest.mapper.SUITE_BANK_1 slot zest.mapper.SUITE_SLOT keep
    zest.suite:
        call zest.preSuite

        ; Tests get appended here

        ; zest.suite.end finished the code block
.ends

;====
; The end of the default suite
;====
.section "zest.suite.end" after zest.suite keep
    jp zest.runner.finish
.ends
