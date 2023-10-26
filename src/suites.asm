;====
; Main suite
;====

;====
; Run each of the test suites
;====
.macro "zest.suites.run"
    call zest.suite
.endm

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
.section "zest.suite.end" appendto zest.suite priority zest.FOOTER_PRIORITY
    ret
.ends
