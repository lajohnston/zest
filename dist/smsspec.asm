
;==============================================================
; SMSSpec
;==============================================================

;==============================================================
; console/vdp/constants.asm
;==============================================================

.define smsspec.ports.vdp.control $bf
.define smsspec.ports.vdp.data $be
.define smsspec.ports.vdp.status $be ; same as Vdp.data, as that is write only and this is read only
.define smsspec.vdp.VRAMWrite $4000
.define smsspec.vdp.CRAMWrite $c000

;==============================================================
; main.asm
;==============================================================

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
.sdsctag 1.2,"SMSSpec", "Sega Master System Unit Test Runner", "lajohnston"

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

;==============================================================
; assertions/assert-acc-equals.asm
;==============================================================

.macro "assertAccEquals" args expected
    cp expected

    jr z, +
        smsspec.runner.assertionFailed "Failed"
    +:
.endm

;==============================================================
; console/console.asm
;==============================================================

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
      ld hl, $0000 | smsspec.vdp.VRAMWrite
      call smsspec.setVDPAddress         ; Set VRAM write address to tile index 0

      ; Output tile data
      ld hl, smsspec.console.data.font              ; Location of tile data
      ld bc, smsspec.console.data.font_end - smsspec.console.data.font          ; Counter for number of bytes to write
      call smsspec.copyToVDP

      ; Initial cursor position
      ld de, $0000
      jp _saveCaret

    /**
     * Write text to the console
     * @param hl    the address of the text to write. The text should be
     *              terminated by an $FF byte
     * @clobbers hl
     */
    smsspec.console.out:
        push af
        push de
        push hl
            ; Set VRAM write address based on console caret position
            ld de, (smsspec.console.cursor_pos)  ; d = y caret, e = x caret
            call _setVramToCaret

            ; Write each character
            _nextCharacter:
                ld a, (hl)  ; a = next character

                ; If character is an $ff terminator, stop
                cp $ff
                jr z, _stopWrite

                ; Output character to VRAM (auto-increments VRAM position)
                out (smsspec.ports.vdp.data), a
                xor a   ; a = 0
                out (smsspec.ports.vdp.data), a
                inc hl  ; next character

                ; Inc x caret
                inc e   ; inc x caret
                ld a, 31
                cp e
                jr nz, _nextCharacter    ; if x caret hasn't wrapped, continue to next character

                ; x caret has wrapped - calculate next y tile
                ld e, 0     ; wrap x tile
                inc d       ; inc y caret
                ld a, 28
                cp d
                jr nz, _nextCharacter   ; if y caret hasn't wrapped, continue to next character

                ; y caret has wrapped
                ld d, 0     ; wrap y caret
                ld hl, $3800 | smsspec.vdp.VRAMWrite    ; set vram write to first tile

            ; Keep looping until $ff terminator is reached
            jr _nextCharacter

    _saveCaret:
        ; Store new cursor positions
        ld hl, smsspec.console.cursor_pos
        ld (hl), e  ; store x caret
        inc hl
        ld (hl), d  ; store y caret
        ret

    _stopWrite:
        call _saveCaret
        pop hl
        pop de
        pop af
        ret

    /**
     * Set the VRAM write address to the console caret position
     * @param d y caret
     * @param e x caret
     */
    _setVramToCaret:
        push af
        push bc
        push hl
            ld hl, $3800 | smsspec.vdp.VRAMWrite ; hl = vram addr. of first tile

            ld a, e ; a = x caret
            ld b, d ; b = y caret

            ; Add xCaret*2 to vram address (2 bytes per tile in vram)
            sla a       ; a = a * 2

            _addHlA:
                add a, l    ; add l to a
                ld l, a     ; store result back to l
                adc a, h
                sub l
                ld h, a     ; store result in h

            ; Add 64 to vram address for every y caret position
            xor a   ; x = 0
            cp b    ; check if y caret = 0
            jp z, +
                ld a, 64
                dec b
                jp _addHlA  ; add 66 to hl
            +:

            call smsspec.setVDPAddress  ; set vdp write address to hl
        pop hl
        pop bc
        pop af
        ret

    smsspec.console.newline:
        ld de, (smsspec.console.cursor_pos)  ; d = y caret, e = x caret
        ld e, 0 ; x caret = 0
        inc d   ; inc y caret

        ; check if y caret at end
        ld a, 28
        cp d
        jp nz, +
            ld d, 0 ; wrap
        +:

        jp _saveCaret

    /**
     * Set the console text color.
     * @param a     the color to set (%xxBBGGRR)
     */
    smsspec.console.setTextColor:
        push hl
            ld hl, (smsspec.vdp.CRAMWrite + 1) | $4000
            call smsspec.setVDPAddress
        pop hl
        out (smsspec.ports.vdp.data), a
        ret
.ends

;==============================================================
; console/data.asm
;==============================================================

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

;==============================================================
; console/vdp/vdp.asm
;==============================================================

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

;==============================================================
; handlers/pause.asm
;==============================================================

.bank 0 slot 0
    .orga $0066
    retn

;==============================================================
; handlers/vblank.asm
;==============================================================

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

;==============================================================
; mock.asm
;==============================================================

/**
 * Structure for mock instances in RAM, which hold a counter for the times
 * the mock has been called and the address to jump to to handle the
 * mock logic
 */
.struct smsspec.mock
    push_hl             db
    call_instruction    db
    call_address        dw
    times_called        db
    address             dw
.endst

.section "smsspec.mock.initAll"
    /**
     * Initialises one or more mocks in RAM
     *
     * @param hl    the address of the first mock in RAM
     * @param b     the number of mocks to initialise
     */
    smsspec.mock.initAll:
        ; Add call mediator instructions to the mock instance
        ld (hl), $e5    ; write push hl to RAM
        inc hl
        ld (hl), $cd  ; write 'call' instruction to RAM
        inc hl
        ld (hl), < smsspec.mock.call
        inc hl
        ld (hl), > smsspec.mock.call

        ; Reset 'times called' counter
        inc hl
        ld (hl), 0

        ; Set default mock handler
        inc hl
        ld (hl), < smsspec.mock.defaultHandler
        inc hl
        ld (hl), > smsspec.mock.defaultHandler

        djnz smsspec.mock.initAll
        ret
.ends

/**
 * Define the start of a mock handler. smsspec.mock.end must be called at the
 * end of the handler
 *
 * @param   mockAddress the address of the mock instance to define the handler for
 */
.macro "smsspec.mock.start" args mockAddress
    push ix
        ld ix, mockAddress
        ld (ix + smsspec.mock.address), < _mockHandlerStart\@
        ld (ix + smsspec.mock.address + 1), > _mockHandlerStart\@
    pop ix

    jp _mockHandlerEnd\@    ; jump over mock code, end label defined by smsspec.mock.end
    _mockHandlerStart\@:    ; define start of the mock handler
.endm

/**
 * Define the end of a mock handler
 */
.macro "smsspec.mock.end"
    ret                 ; return from the handler
    _mockHandlerEnd\@:  ; define end of the mock handler
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
    smsspec.mock.defaultHandler:
        ; by default, mocks just return to caller
        ret

    /**
     * Jumps to an address defined in RAM at runtime without clobbing hl.
     * It does this by writing 'pop hl' and 'jp, n' opcodes to RAM and executing
     * them from there so that control is passed to the destination code as if
     * this mediator didn't exist, and so there's no need to have a pop hl instruction
     * in the destination code
     *
     * @param sp    the start address of the smsspec mock in RAM
     */
    smsspec.mock.call:
        ; pop caller (mock) address from stack
        pop hl

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
            ; this value was pushed by the mock, see smsspec.mock.initAll
            ld hl, smsspec.mock.jump.pop
            ld (hl), $e1    ; $e1 = pop hl

            ; Write jp opcode to RAM
            inc hl
            ld (hl), $c3    ; $c3 = jp, n

            ; Write jump address to RAM
            inc hl
            ld (hl), e
            inc hl
            ld (hl), d
        pop de

        ; Jump to opcodes in RAM
        jp smsspec.mock.jump.pop
.ends

;==============================================================
; runner.asm
;==============================================================

.ramsection "smsspec.runner.current_test_info" slot 2
    smsspec.runner.current_describe_message_addr: dw
    smsspec.runner.current_test_message_addr: dw
.ends

.section "smsspec.runner.assertionFailed" free
    smsspec.runner.assertionFailed:
        ; Set console text color to red
        ld a, %00000011
        call smsspec.console.setTextColor   ; set to a

        ld hl, (smsspec.runner.current_describe_message_addr)
        call smsspec.console.out

        call smsspec.console.newline
        call smsspec.console.newline

        ld hl, (smsspec.runner.current_test_message_addr)
        call smsspec.console.out

        ; Stop program
        -: jp -
.ends

.macro "smsspec.runner.assertionFailed" args message, actual
    jp smsspec.runner.assertionFailed
.endm

.section "smsspec.runner.clearSystemState" free
    smsspec.runner.clearSystemState:
        ; Clear mocks to defaults
        ld hl, smsspec.mocks.start + 1
        ld b, (smsspec.mocks.end - smsspec.mocks.start - 1) / _sizeof_smsspec.mock ; number of mocks
        call smsspec.mock.initAll

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

/**
 * Can be used to describe the unit being tested
 * Stores a pointer to the description test which is used to
 * identify the test to the user if it fails
 */
.macro "describe" args unitName
    smsspec.runner.storeText unitName, smsspec.runner.current_describe_message_addr
.endm

/**
 * Initialises a new test.
 * Resets the Z80 registers and stores the test description in case the test fails
 */
.macro "it" args message
    smsspec.runner.storeText message, smsspec.runner.current_test_message_addr

    ; Clear system state
    call smsspec.runner.clearSystemState
.endm

/**
 * Stores text in the ROM and adds a pointer to it at the given
 * RAM location
 */
.macro "smsspec.runner.storeText" args text, ram_pointer
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

