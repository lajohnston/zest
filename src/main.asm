; Ensure SMS header and checksum is added
.smstag

; ASCII table
.asciitable
    map " " to "~" = 0
.enda

;====
; Boot sequence
;====
.orga $0000
.section "zest.main" force
    di              ; disable interrupts
    im 1            ; Interrupt mode 1
    ld sp, $dff0    ; set stack pointer
    jp zest.runner.init
.ends

;====
; VBlank handler
;
; Detects if the Zest state has been overwritten or if the current test has
; reached its timeout limit
;====
.orga $0038
.section "zest.main.interruptHandler" force
    push af
    push hl
        ; Satisfy interrupt
        in a, (zest.vdp.STATUS_PORT)

        ; Ensure timeout limit hasn't been reached
        call zest.timeout.update
    pop hl
    pop af

    ei      ; re-enable interrupts
    reti    ; return
.ends

;====
; Pause handler
;====
.orga $0066
.section "zest.main.pauseHandler" force
    retn
.ends
