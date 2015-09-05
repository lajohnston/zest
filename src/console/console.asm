;===================================================================
; Console
;===================================================================

.define smsspec.console.COLUMNS 31

.ramsection "smsspec.console.variables" slot 2
    smsspec.console.cursor_pos:  dw ; x (1-byte), y (1-byte)
.ends

.section "smsspec.console" free
    /**
     * Write text to the console
     * @param hl    the address of the text to write. The text should be
     *              terminated by an $FF byte
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
                jr z, -

                ; Wrap x tile, calculate next y tile
                ld e, 0     ; wrap x tile
                inc d
                ld a, d
                cp 31
                jr z, -
                ld d, 0     ; wrap y tile

            jr -

    _stopWrite:
        pop bc
        pop de
        ret

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

        +:
            ret
.ends
