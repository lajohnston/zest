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

.ends
