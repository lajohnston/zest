;====
; Performs post-test checks
;====
.section "zest.postTest" free
    zest.postTest:
        ; Ensure interrupts are disabled
        di

        ; If no test is in progress, return
        ld a, (zest.runner.flags)
        bit zest.runner.TEST_IN_PROGRESS_BIT, a
        ret z   ; return if a test isn't in progress

        ; Reset the test in progress flag
        and (zest.runner.TEST_IN_PROGRESS_MASK ~ $ff)   ; reset the bit
        ld (zest.runner.flags), a                       ; store

        ; Set Z if checksum is valid
        zest.test.validateChecksum
        jp nz, zest.runner.memoryOverwriteDetected

        ; Increment tests passed
        ld hl, (zest.runner.tests_passed)
        inc hl
        ld (zest.runner.tests_passed), hl

        ; Custom hooks go here

        ; zest.postTest.end returns
.ends

;====
; Returns after the zest.postTest hook
; The negative priority ensures it's placed after the other sections
;====
.section "zest.postTest.end" appendto zest.postTest priority zest.FOOTER_PRIORITY
    ret
.ends
