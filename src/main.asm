;====
; WLA-DX banking setup
;====
.memorymap
    defaultslot 0
    slotsize $4000
    slot 0 $0000
    slot 1 $4000

    slotsize $2000      ; 8KB RAM
    slot 2 $C000
.endme

; ROM - 2 x 16KB ROM Slots
.rombankmap
    bankstotal 2
    banksize $4000
    banks 2
.endro

; SDSC tag and SMS rom header
.sdsctag 1.2, "smsspec", "Sega Master System Unit Test Runner", "lajohnston"

; ASCII table
.asciitable
    map " " to "~" = 0
.enda

;====
; Boot sequence
;====
.orga $0000
.section "smsspec.main" force
    di              ; disable interrupts
    im 1            ; Interrupt mode 1
    ld sp, $dff0    ; set stack pointer
    jp smsspec.runner.init
.ends

;====
; VBlank handler
;====
.orga $0038
.section "Interrupt handler" force
    push af
        in a, (smsspec.vdp.STATUS_PORT) ; satisfy interrupt
        ret
    pop af
    ei
    reti
.ends

;====
; Pause handler
;====
.bank 0 slot 0
.orga $0066
.section "Pause handler" force
    retn
.ends
