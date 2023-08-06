;====
; Initialises the VDP's registers to sensible defaults
;====
.section "smsspec.vdp.init" free
    smsspec.vdp.init:
        ; Set up VDP registers
        ld hl, _initData
        ld b, _initDataEnd - _initData
        ld c, smsspec.ports.vdp.control
        otir
        ret

    ; VDP initialisation data
    _initData:
        .db $04, $80, $00, $81, $ff, $82, $ff, $85, $ff, $86, $ff, $87, $00 ,$88 ,$00 ,$89 ,$ff ,$8a
    _initDataEnd:
.ends

.section "smsspec.vdp" free
    smsspec.vdp.clearVram:
        ; Set VRAM write address to $0000
        ld hl, $0000 | smsspec.vdp.VRAMWrite
        call smsspec.vdp.setAddress

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

    ;====
    ; Sets the VDP address
    ;
    ; @in   hl  address
    ;====
    smsspec.vdp.setAddress:
        push af
            ld a, l
            out (smsspec.ports.vdp.control), a
            ld a, h
            out (smsspec.ports.vdp.control), a
        pop af
        ret

    ;====
    ; Copies data to the VDP
    ;
    ; @in   hl  data address
    ; @in   bc  data length
    ; @clobs a, hl, bc
    ;====
    smsspec.vdp.copyToVram:
        -:
            ld a, (hl)  ; Get data byte
            out (smsspec.ports.vdp.data), a
            inc hl      ; Point to next letter
            dec bc
            ld a, b
            or c
        jr nz,-

        ret

    ;====
    ; Enables the display
    ;
    ; @clobs a
    ;====
    smsspec.vdp.enableDisplay:
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

    ;====
    ; Disables the display
    ;
    ; @clobs a
    ;====
    smsspec.vdp.disableDisplay:
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
