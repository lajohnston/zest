describe "waitForActiveDisplay"
    jp +
        _byteSequence:
            .db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09
    +:

    test "(this failure is expected) depending on emulator/system, we should expect errors if we write to VRAM too fast in active display"
        zest.waitForActiveDisplay

        ; Set VRAM address to 0 with write command
        xor a
        out ($bf), a
        ld a, %01000000
        out ($bf), a

        ld hl, _byteSequence
        ld b, 10
        ld c, $be   ; data port
        otir        ; write data to VRAM too quickly
