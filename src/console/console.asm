;====
; Writes text to the screen
;====

.ramsection "smsspec.console.variables" slot 2
    smsspec.console.cursor_vram_address:    dw
.ends

;====
; Initialises the console ready for use
;====
.section "smsspec.console.init" free
    smsspec.console.init:
      ; Load palette
      ld hl, $0000 | smsspec.vdp.CRAMWrite
      call smsspec.vdp.setAddress
      ld hl, smsspec.console.data.palette
      ld bc, smsspec.console.data.paletteEnd - smsspec.console.data.palette
      call smsspec.vdp.copyToVram

      ; Load tiles
      ld hl, $0000 | smsspec.vdp.VRAMWrite
      call smsspec.vdp.setAddress       ; set VRAM write address to tile index 0

      ; Output tile data
      ld hl, smsspec.console.data.font  ; location of tile data

      ; Counter for number of bytes to write
      ld bc, smsspec.console.data.font_end - smsspec.console.data.font
      call smsspec.vdp.copyToVram

      ; Initial cursor position
      ld hl, smsspec.vdp.TILEMAP_BASE | smsspec.vdp.VRAMWrite
      ld (smsspec.console.cursor_vram_address), hl
      ret
.ends

;====
; Set the console text color
;
; @in   a   the color to set (%xxBBGGRR)
;====
.section "smsspec.console.setTextColor" free
    smsspec.console.setTextColor:
        push hl
            ld hl, (smsspec.vdp.CRAMWrite + 1) | smsspec.vdp.VRAMWrite
            call smsspec.vdp.setAddress
        pop hl

        out (smsspec.vdp.DATA_PORT), a
        ret
.ends

;====
; Write text to the screen
;
; @in   hl  the address of the text to write. The text should be
;           terminated by an $FF byte
;====
.section "smsspec.console.out" free
    smsspec.console.out:
        ; Preserve registers
        push af
        push de
        push hl

        call smsspec.vdp.disableDisplay
        ld de, (smsspec.console.cursor_vram_address)
        call smsspec.vdp.setAddressDE

        _outputCharacter:
            ld a, (hl)
            cp $ff
            jr z, _finish

            ; Check if we're on the last column
            ld a, e
            and %00111110   ; mask X bits
            cp %00111110    ; if X bits are all 1, we're on the last column (31)
            jp nz, +
                ; We're on the last column
                ; Output dash character. VRAM auto-increments to next line
                ld a, 13                        ; dash pattern
                out (smsspec.vdp.DATA_PORT), a  ; output dash
                xor a                           ; set attributes to 0
                out (smsspec.vdp.DATA_PORT), a  ; output tile attributes

                ; Increment cursor position
                inc de  ; pattern
                inc de  ; tile attributes

                jp _outputCharacter
            +:

            ; Output character to VRAM (auto-increments VRAM position)
            ld a, (hl)  ; re-load character
            out (smsspec.vdp.DATA_PORT), a

            ; Output tile attributes (none)
            xor a   ; a = 0
            out (smsspec.vdp.DATA_PORT), a

            ; Point to next character
            inc hl

            ; Increment VRAM address in DE by one tile
            inc de  ; pattern ref
            inc de  ; attributes

            jp _outputCharacter

        _finish:
            ; Store VRAM address
            ld (smsspec.console.cursor_vram_address), de
            call smsspec.vdp.enableDisplay

            ; Restore registers
            pop hl
            pop de
            pop af

            ret
.ends

;====
; Move the console cursor onto the next line
;====
.section "smsspec.console.newline" free
    smsspec.console.newline:
        push af
        push hl
            ;===
            ; VRAM address format
            ; ccbbbyyy yyxxxxx-
            ;
            ; c = command
            ; b = base address
            ; y = row
            ; x = col
            ;===
            ld hl, (smsspec.console.cursor_vram_address)

            ; Set column to zero
            ld a, l         ; set A to low byte of address
            and %11000000   ; mask out x bits
            ld l, a         ; set low byte of address

            ; Add 1 row
            ld a, 32 * 2
            add a, l  ; A = A+L
            ld l, a   ; L = A+L
            adc a, h  ; A = A+L+H+carry
            sub l     ; A = H+carry
            ld h, a   ; H = H+carry

            ld (smsspec.console.cursor_vram_address), hl
        pop hl
        pop af

        ret
.ends
