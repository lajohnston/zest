;====
; Prepares the start of a new test
;
; @in   hl  pointer to the test description
;====
.section "zest.preTest" free
    zest.preTest:
        zest.test.setTestDescription

        ; Update checksum + VRAM backup
        zest.test.preTest

        ; Reset timeout counter
        zest.timeout.reset

        ; Set test in progress flag
        ld a, (zest.runner.flags)
        or zest.runner.TEST_IN_PROGRESS_MASK
        ld (zest.runner.flags), a

        ; Disable display
        in a, (zest.vdp.STATUS_PORT)    ; clear pending interrupts
        zest.vdp.setRegister1 %10100000 ; enable VBlank interrupts

        ; Custom hooks will go here

        ; zest.preTest.end will add the return at the end
.ends

;====
; Returns at the end of the preTest hook
; The negative priority ensures it's placed after the other sections
;====
.section "zest.preTest.end" appendto zest.preTest priority zest.FOOTER_PRIORITY
    zest.preTest.end:
        ei  ; ensure CPU interrupts are enabled
        ret
.ends
