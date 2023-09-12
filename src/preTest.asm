;====
; Prepares the start of a new test
;
; @in   hl  pointer to the test description
;====
.section "zest.preTest" free keep
    zest.preTest:
        nop
.ends

.section "zest.preTest.end" after zest.preTest keep
    ei  ; ensure CPU interrupts are enabled
    ret
.ends
