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

    /**
     * Enables the display
     *
     * @clobbers a
     */
    smsspec.console.vdp.enableDisplay:
        ; turn screen on
        ld a, %01000000
               ;||||||`- Zoomed sprites -> 16x16 pixels
               ;|||||`-- Doubled sprites -> 2 tiles per sprite, 8x16
               ;||||`--- Mega Drive mode 5 enable
               ;|||`---- 30 row/240 line mode
               ;||`----- 28 row/224 line mode
               ;|`------ VBlank interrupts
               ;`------- Enable display

        out (smsspec.ports.vdp.control), a
        ld a, $81
        out (smsspec.ports.vdp.control), a
        ret

    /**
     * Disables the display
     *
     * @clobbers a
     */
    smsspec.console.vdp.disableDisplay:
        ; turn screen off
        ld a, %00000000
               ;||||||`- Zoomed sprites -> 16x16 pixels
               ;|||||`-- Doubled sprites -> 2 tiles per sprite, 8x16
               ;||||`--- Mega Drive mode 5 enable
               ;|||`---- 30 row/240 line mode
               ;||`----- 28 row/224 line mode
               ;|`------ VBlank interrupts
               ;`------- Enable display

        out (smsspec.ports.vdp.control), a
        ld a, $81
        out (smsspec.ports.vdp.control), a
        ret
.ends
