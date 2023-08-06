;====
; Constants
;====
.define smsspec.vdp.VRAMWrite       $4000
.define smsspec.vdp.CRAMWrite       $c000

.define smsspec.vdp.TILEMAP_BASE    $3800

.define smsspec.vdp.CONTROL_PORT    $bf
.define smsspec.vdp.DATA_PORT       $be ; same as status port (write-only)
.define smsspec.vdp.STATUS_PORT     $be ; same as data port (read-only)

;====
; Initialises the VDP's registers to sensible defaults
;====
.section "smsspec.vdp.init" free
    smsspec.vdp.init:
        ; Set up VDP registers
        ld hl, _initData
        ld b, _initDataEnd - _initData
        ld c, smsspec.vdp.CONTROL_PORT
        otir
        ret

    ; VDP initialisation data
    _initData:
        .db $04, $80, $00, $81, $ff, $82, $ff, $85, $ff, $86, $ff, $87, $00 ,$88 ,$00 ,$89 ,$ff ,$8a
    _initDataEnd:
.ends

;====
; Fills the graphics RAM with zeroes
;====
.section "smsspec.vdp.clearVram" free
    smsspec.vdp.clearVram:
        ; Set VRAM write address to $0000
        ld hl, $0000 | smsspec.vdp.VRAMWrite
        call smsspec.vdp.setAddress

        ; Output 16KB of zeroes
        ld bc, $4000    ; counter for 16KB of VRAM
        -:
            xor a       ; set A to 0

            ; Output to VRAM address, which is auto-incremented after each write
            out (smsspec.vdp.DATA_PORT),a
            dec bc
            ld a, b
            or c
        jp nz,-
        ret
.ends

;====
; Sets the VDP address
;
; @in   hl  address
;====
.section "smsspec.vdp.setAddress" free
    smsspec.vdp.setAddress:
        push af
            ld a, l
            out (smsspec.vdp.CONTROL_PORT), a
            ld a, h
            out (smsspec.vdp.CONTROL_PORT), a
        pop af
        ret
.ends

;====
; Sets the VDP address
;
; @in   de  address
;====
.section "smsspec.vdp.setAddressDE" free
    smsspec.vdp.setAddressDE:
        push af
            ld a, e
            out (smsspec.vdp.CONTROL_PORT), a
            ld a, d
            out (smsspec.vdp.CONTROL_PORT), a
        pop af
        ret
.ends

;====
; Copies data to the VDP
;
; @in   hl  data address
; @in   bc  data length
; @clobs a, hl, bc
;====
.section "smsspec.vdp.copyToVram" free
    smsspec.vdp.copyToVram:
        -:
            ld a, (hl)  ; Get data byte
            out (smsspec.vdp.DATA_PORT), a
            inc hl      ; Point to next letter
            dec bc
            ld a, b
            or c
        jr nz,-

        ret
.ends

;====
; Enables the display
;
; @clobs a
;====
.section "smsspec.vdp.enableDisplay" free
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

        out (smsspec.vdp.CONTROL_PORT), a
        ld a, $81
        out (smsspec.vdp.CONTROL_PORT), a
        ret
.ends

;====
; Disables the display
;
; @clobs a
;====
.section "smsspec.vdp.disableDisplay" free
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

        out (smsspec.vdp.CONTROL_PORT), a
        ld a, $81
        out (smsspec.vdp.CONTROL_PORT), a
        ret
.ends
