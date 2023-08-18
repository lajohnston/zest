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
;====
.orga $0038
.section "Interrupt handler" force
    push af
        in a, (zest.vdp.STATUS_PORT)    ; satisfy interrupt
        ret
    pop af
    ei
    reti
.ends

;====
; Pause handler
;====
.orga $0066
.section "Pause handler" force
    retn
.ends
