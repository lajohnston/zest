;====
; Prepares the start of a new test
;
; @in   hl  pointer to the test description
;====
.section "zest.preTest" free
    zest.preTest:
        ; Ensure interrupts are disabled
        di

        ; Run checks for previous test
        call zest.postTest

        pop hl  ; set HL to test description (return address)
        dec sp  ; point stack back to test description
        dec sp

        ; Set the test description
        inc hl  ; inc past the string length
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
        pop hl      ; pop caller (description pointer) from stack
        ld a, (hl)  ; set A to test description/data size

        ; Add description size to return address, to skip it
        add a, l    ; A = A+L
        ld l, a     ; L = A+L
        adc a, h    ; A = A+L+H+carry
        sub l       ; A = H+carry
        ld h, a     ; H = H+carry

        ld sp, zest.runner.DEFAULT_STACK_POINTER    ; reset stack
        ei      ; ensure CPU interrupts are enabled
        jp (hl) ; return to caller (skipping over test description)
.ends
