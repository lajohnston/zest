;========================================
; console/vdp/constants.asm
;========================================
.define smsspec.ports.vdp.control $bf
.define smsspec.ports.vdp.data $be
.define smsspec.ports.vdp.status $be ; same as Vdp.data, as that is write only and this is read only
.define smsspec.vdp.VRAMWrite $4000
.define smsspec.vdp.CRAMWrite $c000

;========================================
; main.asm
;========================================
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

        ; Init console
        call smsspec.console.init

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

;========================================
; assertions/assert-acc-equals.asm
;========================================
.macro "assertAccEquals" args expected
    cp expected

    jr z, +
        assertionFailed "Failed"
    +:
.endm

;========================================
; console/console.asm
;========================================
;===================================================================
; Console
;===================================================================

.define smsspec.console.COLUMNS 31

.ramsection "smsspec.console.variables" slot 2
    smsspec.console.cursor_pos:  dw ; x (1-byte), y (1-byte)
.ends

.section "smsspec.console" free
    smsspec.console.init:
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
      ld hl, smsspec.console.data.font              ; Location of tile data
      ld bc, smsspec.console.data.font_end - smsspec.console.data.font          ; Counter for number of bytes to write
      call smsspec.copyToVDP

      ; Initial cursor position
      ld hl, smsspec.console.cursor_pos
      ld (hl), $01 ; y
      inc hl
      ld (hl), $00 ; x

      ret

    /**
     * Write text to the console
     * @param hl    the address of the text to write. The text should be
     *              terminated by an $FF byte
     * @clobbers hl
     */
    smsspec.console.out:
        push bc
        push de
            ; Calculate and set VRAM write address based on x and y caret position
            push hl
                ld hl, (smsspec.console.cursor_pos)
                ld b, l     ; y offset

                ; Set de to x tile (x pos * 2), always an 8-bit number
                ld d, 0
                ld e, h     ; x offset
                sla e       ; multiply by 2 (2 bytes per tile)

                ; Get first tile addr and add x offset
                ld hl, $3800 | smsspec.vdp.VRAMWrite
                add hl, de

                ; Add 66 for each y offset
                ld de, 66
                -:
                    add hl, de
                    djnz -

                call smsspec.setVDPAddress
                ld hl, (smsspec.console.cursor_pos)
                ld d, h     ; x tile
                ld e, l     ; y tile
            pop hl

            ; Write each character
            -:
                ld a, (hl)

                ; If $FF terminator, stop
                cp $FF
                jr z, _stopWrite

                out (smsspec.ports.vdp.data), a
                xor a   ; set a to 0
                out (smsspec.ports.vdp.data), a
                inc hl

                ; Calculate x and y tiles
                inc e
                ld a, e
                cp 31
                jr nz, -

                ; Wrap x tile, calculate next y tile
                ld e, 0     ; wrap x tile
                inc d
                ld a, d
                cp 31
                jr z, -
                ld d, 0     ; wrap y tile

            jr -

    _stopWrite:
        ; Store new cursor positions
        ld hl, smsspec.console.cursor_pos
        ld (hl), e
        inc hl
        ld (hl), d

        pop bc
        pop de
        ret
.ends

.section "smsspec.console.newlineSection" free
    smsspec.console.newline:
        ld hl, (smsspec.console.cursor_pos)
        ld d, h
        ld e, l

        ld b, 0
        ld c, 66

        ; Add 66 until address is higher than cursor
        ld hl, $3800 | smsspec.vdp.VRAMWrite
        -:
            add hl, bc

            ; cp 16 bits
            or a ; reset carry flag
            sbc hl, de
            add hl, de
        jp -
.ends

;========================================
; console/data.asm
;========================================
.section "smsspec.console.data" free
    .asciitable
    map " " to "~" = 0
    .enda

    smsspec.heading:
    .asc "SMSSpec"
    .db $ff

    smsspec.palette_data:
        .db $00,$0C,$03 ; Black, green, red
    smsspec.palette_data_end:

    ; VDP initialisation data
    smsspec.vdp_init_data:
    .db $04,$80,$00,$81,$ff,$82,$ff,$85,$ff,$86,$ff,$87,$00,$88,$00,$89,$ff,$8a
    smsspec.vdp_init_data_end:

    ; Console font
    smsspec.console.data.font:
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $6C,$00,$00,$00,$6C,$00,$00,$00,$6C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $36,$00,$00,$00,$36,$00,$00,$00,$7F,$00,$00,$00,$36,$00,$00,$00
    .db $7F,$00,$00,$00,$36,$00,$00,$00,$36,$00,$00,$00,$00,$00,$00,$00
    .db $0C,$00,$00,$00,$3F,$00,$00,$00,$68,$00,$00,$00,$3E,$00,$00,$00
    .db $0B,$00,$00,$00,$7E,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $60,$00,$00,$00,$66,$00,$00,$00,$0C,$00,$00,$00,$18,$00,$00,$00
    .db $30,$00,$00,$00,$66,$00,$00,$00,$06,$00,$00,$00,$00,$00,$00,$00
    .db $38,$00,$00,$00,$6C,$00,$00,$00,$6C,$00,$00,$00,$38,$00,$00,$00
    .db $6D,$00,$00,$00,$66,$00,$00,$00,$3B,$00,$00,$00,$00,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$30,$00,$00,$00
    .db $30,$00,$00,$00,$18,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00
    .db $30,$00,$00,$00,$18,$00,$00,$00,$0C,$00,$00,$00,$0C,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$7E,$00,$00,$00,$3C,$00,$00,$00
    .db $7E,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$7E,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7E,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$06,$00,$00,$00,$0C,$00,$00,$00,$18,$00,$00,$00
    .db $30,$00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$6E,$00,$00,$00,$7E,$00,$00,$00
    .db $76,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$38,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$06,$00,$00,$00,$0C,$00,$00,$00
    .db $18,$00,$00,$00,$30,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$06,$00,$00,$00,$1C,$00,$00,$00
    .db $06,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $0C,$00,$00,$00,$1C,$00,$00,$00,$3C,$00,$00,$00,$6C,$00,$00,$00
    .db $7E,$00,$00,$00,$0C,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00,$06,$00,$00,$00
    .db $06,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $1C,$00,$00,$00,$30,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$06,$00,$00,$00,$0C,$00,$00,$00,$18,$00,$00,$00
    .db $30,$00,$00,$00,$30,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$3E,$00,$00,$00
    .db $06,$00,$00,$00,$0C,$00,$00,$00,$38,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $00,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$60,$00,$00,$00
    .db $30,$00,$00,$00,$18,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $30,$00,$00,$00,$18,$00,$00,$00,$0C,$00,$00,$00,$06,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$0C,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$6E,$00,$00,$00,$6A,$00,$00,$00
    .db $6E,$00,$00,$00,$60,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$7E,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $7C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$7C,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$7C,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00
    .db $60,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $78,$00,$00,$00,$6C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$6C,$00,$00,$00,$78,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$60,$00,$00,$00,$6E,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$7E,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $3E,$00,$00,$00,$0C,$00,$00,$00,$0C,$00,$00,$00,$0C,$00,$00,$00
    .db $0C,$00,$00,$00,$6C,$00,$00,$00,$38,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$6C,$00,$00,$00,$78,$00,$00,$00,$70,$00,$00,$00
    .db $78,$00,$00,$00,$6C,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $63,$00,$00,$00,$77,$00,$00,$00,$7F,$00,$00,$00,$6B,$00,$00,$00
    .db $6B,$00,$00,$00,$63,$00,$00,$00,$63,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$76,$00,$00,$00,$7E,$00,$00,$00
    .db $6E,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $7C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$7C,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $6A,$00,$00,$00,$6C,$00,$00,$00,$36,$00,$00,$00,$00,$00,$00,$00
    .db $7C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$7C,$00,$00,$00
    .db $6C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$60,$00,$00,$00,$3C,$00,$00,$00
    .db $06,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$3C,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $63,$00,$00,$00,$63,$00,$00,$00,$6B,$00,$00,$00,$6B,$00,$00,$00
    .db $7F,$00,$00,$00,$77,$00,$00,$00,$63,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$18,$00,$00,$00
    .db $3C,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $7E,$00,$00,$00,$06,$00,$00,$00,$0C,$00,$00,$00,$18,$00,$00,$00
    .db $30,$00,$00,$00,$60,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $7C,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$60,$00,$00,$00,$30,$00,$00,$00,$18,$00,$00,$00
    .db $0C,$00,$00,$00,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $3E,$00,$00,$00,$06,$00,$00,$00,$06,$00,$00,$00,$06,$00,$00,$00
    .db $06,$00,$00,$00,$06,$00,$00,$00,$3E,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$3C,$00,$00,$00,$66,$00,$00,$00,$42,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$00
    .db $1C,$00,$00,$00,$36,$00,$00,$00,$30,$00,$00,$00,$7C,$00,$00,$00
    .db $30,$00,$00,$00,$30,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3C,$00,$00,$00,$06,$00,$00,$00
    .db $3E,$00,$00,$00,$66,$00,$00,$00,$3E,$00,$00,$00,$00,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$7C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3C,$00,$00,$00,$66,$00,$00,$00
    .db $60,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $06,$00,$00,$00,$06,$00,$00,$00,$3E,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3E,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3C,$00,$00,$00,$66,$00,$00,$00
    .db $7E,$00,$00,$00,$60,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $1C,$00,$00,$00,$30,$00,$00,$00,$30,$00,$00,$00,$7C,$00,$00,$00
    .db $30,$00,$00,$00,$30,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3E,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$3E,$00,$00,$00,$06,$00,$00,$00,$3C,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$7C,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$00,$00,$00,$00,$38,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$00,$00,$00,$00,$38,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$70,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$66,$00,$00,$00,$6C,$00,$00,$00
    .db $78,$00,$00,$00,$6C,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $38,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$36,$00,$00,$00,$7F,$00,$00,$00
    .db $6B,$00,$00,$00,$6B,$00,$00,$00,$63,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$7C,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3C,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$7C,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$7C,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3E,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$3E,$00,$00,$00,$06,$00,$00,$00,$07,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$6C,$00,$00,$00,$76,$00,$00,$00
    .db $60,$00,$00,$00,$60,$00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$3E,$00,$00,$00,$60,$00,$00,$00
    .db $3C,$00,$00,$00,$06,$00,$00,$00,$7C,$00,$00,$00,$00,$00,$00,$00
    .db $30,$00,$00,$00,$30,$00,$00,$00,$7C,$00,$00,$00,$30,$00,$00,$00
    .db $30,$00,$00,$00,$30,$00,$00,$00,$1C,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$66,$00,$00,$00,$3E,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$3C,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$63,$00,$00,$00,$6B,$00,$00,$00
    .db $6B,$00,$00,$00,$7F,$00,$00,$00,$36,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$66,$00,$00,$00,$3C,$00,$00,$00
    .db $18,$00,$00,$00,$3C,$00,$00,$00,$66,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$66,$00,$00,$00,$66,$00,$00,$00
    .db $66,$00,$00,$00,$3E,$00,$00,$00,$06,$00,$00,$00,$3C,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$7E,$00,$00,$00,$0C,$00,$00,$00
    .db $18,$00,$00,$00,$30,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00
    .db $0C,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$70,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
    .db $30,$00,$00,$00,$18,$00,$00,$00,$18,$00,$00,$00,$0E,$00,$00,$00
    .db $18,$00,$00,$00,$18,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00
    .db $31,$00,$00,$00,$6B,$00,$00,$00,$46,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    smsspec.console.data.font_end:
.ends

;========================================
; handlers/pause.asm
;========================================
.bank 0 slot 0
    .orga $0066
    retn

;========================================
; handlers/vblank.asm
;========================================
.orga $0038
.section "Interrupt handler" force
    push af
        in a, (smsspec.ports.vdp.status) ; satisfy interrupt
        call smsspec.onVBlank
    pop af
    ei
    reti
.ends

.section "smsspec.onVBlank" free
    smsspec.onVBlank:
        ret
.ends

;========================================
; mock/mock.asm
;========================================
;===================================================================
; Label mocks
;===================================================================

/**
 * Structure for mock instances in RAM, which hold a counter for the times
 * the mock has been called and the address to jump to to handle the
 * mock logic
 */
.struct smsspec.mock
    times_called    db
    address         dw
.endst


/**
 * Calls a handler for a mock, which is stored within the mock instance
 * in RAM.
 */
.macro "smsspec.mock.call" args mock
    push hl
        ld hl, mock
        jp smsspec.mock.mediator
    ; pop hl handled by mediator
.endm


/**
 * Set the destination address for a label mock
 */
.macro "smsspec.mock.set" args mock, address
    push hl
    push de
        ld de, address
        ld hl, mock
        inc hl
        ld (hl), e
        inc hl
        ld (hl), d
    pop de
    pop hl
.endm


/**
 * Reserves space in RAM to store temporary opcodes for use when jumping to a
 * mock handler without clobbing hl
 */
.ramsection "smsspec.mock.jump" slot 2
    smsspec.mock.jump.pop:  db
    smsspec.mock.jump.jp:   db
    smsspec.mock.jump.jp_address:   dw
.ends

.section "smsspec.mock" free
    /**
     * Defines a procedure that mocks run by default
     */
    smsspec.mock.default_handler:
        ; by default, mocks just return to caller
        ret


    /**
     * Jumps to an address defined in RAM at runtime without clobbing hl.
     * It does this by writing 'pop hl' and 'jp, n' opcodes to RAM and executing
     * them from there so that control is passed to the destination code as if
     * this mediator didn't exist, and so there's no need to have a pop hl instruction
     * in the destination code
     *
     * @param hl    the start address of the smsspec mock in RAM
     */
    smsspec.mock.mediator:
        ; Increment mock's times_called counter in RAM
        push af
            inc (hl)
            ; TODO - add overflow logic
        pop af

        push de
            ; Load address of mock handler from RAM into DE
            inc hl
            ld e, (hl)
            inc hl
            ld d, (hl)

            ; To jump to handler without clobbing hl, write a couple of instructions
            ; to RAM which will pop hl then jp to the address

            ; Write 'pop hl' opcode to RAM
            ld hl, smsspec.mock.jump.pop
            ld (hl), $E1    ; $E1 = pop hl

            ; Write jp opcode to RAM
            inc hl
            ld (hl), $C3    ; $C3 = jp, n

            ; Write jump address to RAM
            inc hl
            ld (hl), e
            inc hl
            ld (hl), d
        pop de

        ; Jump to opcodes in RAM
        jp smsspec.mock.jump.pop
.ends

;========================================
; testing/assertion-failed.asm
;========================================
.section "smsspec.testing.assertionFailedSection" free
    smsspec.testing.assertionFailed:
        ld hl, (smsspec.current_describe_message_addr)
        call smsspec.console.out

        ld hl, (smsspec.current_test_message_addr)
        call smsspec.console.out

        ;smsspec.current_test_message_addr: dw

        ; Stop program
        -: jp -
.ends

.macro "assertionFailed" args message, actual
    jp smsspec.testing.assertionFailed
.endm

;========================================
; testing/clear-system-state.asm
;========================================
.section "smsspec.clearSystemState" free
    smsspec.clearSystemState:
        ; Clear mocks to defaults
        ld b, (smsspec.mocks.end - smsspec.mocks.start - 1) / 3 ; number of mocks

        _clearMocks:
            ld hl, smsspec.mocks.start

            -:  ; Each mock
                inc hl

                ; Clear times called
                ld (hl), 0

                ; Reset mock handler to the default
                inc hl
                ld (hl), < smsspec.mock.default_handler
                inc hl
                ld (hl), > smsspec.mock.default_handler
            djnz -

        ; Clear registers
        xor a
        ld b, a
        ld c, a
        ld d, a
        ld e, a
        ld h, a
        ld l, a
        ld ix, 0
        ld iy, 0

        ; do same for shadow flags

        ; reset fps counter
        ret
.ends

;========================================
; testing/current-test-info.asm
;========================================
.ramsection "smsspec.current_test_info" slot 2
    smsspec.current_describe_message_addr: dw
    smsspec.current_test_message_addr: dw
.ends

;========================================
; testing/describe.asm
;========================================
/**
 * Can be used to describe the unit being tested
 * Stores a pointer to the description test which is used to
 * identify the test to the user if it fails
 */
.macro "describe" args unit_name
    smsspec.storeText unit_name, smsspec.current_describe_message_addr
.endm

;========================================
; testing/it.asm
;========================================
/**
 * Specified a new test with a description.
 * Resets the Z80 registers ready for the new test
 */
.macro "it" args message
    smsspec.storeText message, smsspec.current_test_message_addr

    ; Clear system state
    call smsspec.clearSystemState
.endm

;========================================
; testing/store-text.asm
;========================================
/**
 * Stores text in the ROM and adds a pointer to it at the given
 * RAM location
 */
.macro "smsspec.storeText" args text, ram_pointer
    jr +
    _text\@:
        .asc text
        .db $ff    ; terminator byte
    +:

    ld hl, ram_pointer
    ld (hl), <_text\@
    inc hl
    ld (hl), >_text\@
.endm

;========================================
; console/vdp/vdp.asm
;========================================
.section "smsspec.vdp" free
    smsspec.clearVram:
        ; Set VRAM write address to $0000
        ld hl, $0000 | smsspec.vdp.VRAMWrite
        call smsspec.setVDPAddress

        ; Output 16KB of zeroes
        ld bc, $4000     ; Counter for 16KB of VRAM
        -:
            xor a
            out (smsspec.ports.vdp.data),a ; Output to VRAM address, which is auto-incremented after each write
            dec bc
            ld a, b
            or c
        jr nz,-
        ret

    smsspec.setVDPAddress:
    ; Sets the VDP address
    ; Parameters: hl = address
        push af
            ld a, l
            out (smsspec.ports.vdp.control), a
            ld a, h
            out (smsspec.ports.vdp.control), a
        pop af
        ret

    smsspec.copyToVDP:
        ; Copies data to the VDP
        ; Parameters: hl = data address, bc = data length
        ; Affects: a, hl, bc
        -:
            ld a, (hl)    ; Get data byte
            out (smsspec.ports.vdp.data), a
            inc hl       ; Point to next letter
            dec bc
            ld a, b
            or c
        jr nz,-

        ret
.ends
