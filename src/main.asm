;==============================================================
; WLA-DX banking setup
;==============================================================
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
.sdsctag 1.2,"SMSSpec", "Sega Master System Unit Test Runner", "eljay"

/**
 * Boot sequence
 */
.orga $0000
.section "smsspec.main" force
    di              ; disable interrupts
    im 1            ; Interrupt mode 1
    ld sp, $dff0    ; set stack pointer
    jp smsspec.init
.ends

.section "smsspec.init" free
    smsspec.init:
        ; Set up VDP registers
        ld hl, smsspec.vdp_init_data
        ld b, smsspec.vdp_init_data_end - smsspec.vdp_init_data
        ld c, smsspec.ports.vdp.control
        otir

        call smsspec.clearVram

        ; Load palette
        ld hl, $0000 | smsspec.vdp.CRAMWrite
        call smsspec.setVDPAddress
        ld hl, smsspec.palette_data
        ld bc, smsspec.palette_data_end - smsspec.palette_data
        call smsspec.copyToVDP

        ; Load tiles
        ld hl,$0000 | smsspec.vdp.VRAMWrite
        call smsspec.setVDPAddress         ; Set VRAM write address to tile index 0

        ; Output tile data
        ld hl, smsspec.font_data              ; Location of tile data
        ld bc, smsspec.font_data_end - smsspec.font_data          ; Counter for number of bytes to write
        call smsspec.copyToVDP

        ; Init console
        ld hl, smsspec.console.cursor_pos
        ld (hl), $01
        inc hl
        ld (hl), $00

        ; Turn screen on
        ld a,%01000000
    ;          ||||||`- Zoomed sprites -> 16x16 pixels
    ;          |||||`-- Doubled sprites -> 2 tiles per sprite, 8x16
    ;          ||||`--- Mega Drive mode 5 enable
    ;          |||`---- 30 row/240 line mode
    ;          ||`----- 28 row/224 line mode
    ;          |`------ VBlank interrupts
    ;          `------- Enable display
        out (smsspec.ports.vdp.control), a
        ld a, $81
        out (smsspec.ports.vdp.control), a

        call smsspec.suite
        -: jr -
.ends
