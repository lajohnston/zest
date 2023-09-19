;====
; Master System event handlers (boot, interrupts, pause)
;====

; Ensure SMS header and checksum is added
.smstag

;====
; Boot sequence
;====
.orga $0000
.section "zest.handlers.boot" force
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
.section "zest.handlers.interrupts" force
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
.section "zest.handlers.pause" force
    retn
.ends
