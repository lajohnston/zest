;====
; Performs post-test checks
;====
.section "zest.postTest" free
    zest.postTest:
        ; Ensure interrupts are disabled
        di

        ; If no test is in progress, return
        zest.runner.cpTestInProgress
        ret z

        ; Reset the test in progress flag
        zest.runner.setTestInProgress 0

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
