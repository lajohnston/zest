; SDSC tag and SMS rom header
.sdsctag 1.2, "Zest", "Sega Master System Unit Test Runner", "lajohnston"

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
.section "main.interruptHandler" force
    push af
        ; Satisfy interrupt
        in a, (zest.vdp.STATUS_PORT)

        ; Ensure Zest state hasn't been overwritten
        call zest.runner.assertChecksum

        ; Ensure timeout limit hasn't been reached
        call zest.runner.updateTimeoutCounter
    pop af

    ei      ; re-enable interrupts
    reti    ; return
.ends

;====
; Pause handler
;====
.orga $0066
.section "main.pauseHandler" force
    retn
.ends
