;====
; Constants
;====
.define smsspec.ports.vdp.control $bf
.define smsspec.ports.vdp.data $be
.define smsspec.ports.vdp.status $be ; same as Vdp.data, as that is write only and this is read only
.define smsspec.vdp.VRAMWrite $4000
.define smsspec.vdp.CRAMWrite $c000

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

;====
; Boot sequence
;====
.orga $0000
.section "smsspec.main" force
    di              ; disable interrupts
    im 1            ; Interrupt mode 1
    ld sp, $dff0    ; set stack pointer
    jp smsspec.init
.ends

;====
; VBlank handler
;====
.orga $0038
.section "Interrupt handler" force
    push af
        in a, (smsspec.ports.vdp.status) ; satisfy interrupt
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

;====
; Initialise the system and run the test suite
;====
.section "smsspec.init" free
    smsspec.init:
        ; Set up VDP registers
        ld hl, smsspec.vdp_init_data
        ld b, smsspec.vdp_init_data_end - smsspec.vdp_init_data
        ld c, smsspec.ports.vdp.control
        otir

        ; Clear VRAM
        call smsspec.vdp.clearVram

        ; Initialise console
        call smsspec.console.init
        call smsspec.vdp.enableDisplay

        ; Run the test suite (label defined by user)
        call smsspec.suite

        ; All tests passed. Display message
        ld hl, smsspec.console.data.heading
        call smsspec.console.out
        call smsspec.console.newline
        call smsspec.console.newline

        ld hl, smsspec.console.data.allTestsPassed
        call smsspec.console.out

        ; End
        -: jr -
.ends
