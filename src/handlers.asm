;====
; Master System event handlers (boot, interrupts, pause)
;====

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
        ; Reset VDP status flags to satisfy interrupt
        in a, (zest.vdp.STATUS_PORT)
        rlca                ; rotate 7th/VBlank bit into Carry
        jr nc, _onHBlank    ; jump if VBlank bit was not set

        push hl
            ; Ensure timeout limit hasn't been reached
            call zest.timeout.update

            ; Set a flag indicating a VBlank occurred
            zest.runner.setVBlankFlag 1
        pop hl
        +:
    pop af

    zest.onVBlank.invokeCallback
    ei      ; re-enable interrupts
    ret     ; return; ret is faster than reti, which is not needed on SMS

    _onHBlank:
        pop af
        ei
        ret
.ends

;====
; Pause handler
;====
.orga $0066
.section "zest.handlers.pause" force
    zest.runner.fail "Test terminated by pause button"
.ends
