;====
; Main suite
;====
.bank zest.mapper.SUITE_BANK_1 slot zest.mapper.SUITE_SLOT

;====
; The start of the default suite
;====
.section "zest.suite" free keep
    zest.suite:
.ends

;====
; The end of the default suite
;====
.section "zest.suite.end" after zest.suite keep
    ; Perform postTest checks for the last test
    jp zest.runner.postTest ; jp/ret
.ends
