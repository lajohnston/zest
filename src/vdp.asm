;====
; Constants
;====
.define zest.vdp.VRAMWrite       $4000
.define zest.vdp.CRAMWrite       $c000

.define zest.vdp.TILEMAP_BASE    $3800

.define zest.vdp.CONTROL_PORT    $bf
.define zest.vdp.STATUS_PORT     $bf    ; same as control port (read-only)
.define zest.vdp.DATA_PORT       $be

;====
; Initialises the VDP's registers to sensible defaults
;====
.section "zest.vdp.init" free
    zest.vdp.init:
        ; Set up VDP registers
        ld hl, _initData
        ld b, _initDataEnd - _initData
        ld c, zest.vdp.CONTROL_PORT
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
.section "zest.vdp.clearVram" free
    zest.vdp.clearVram:
        ; Set VRAM write address to $0000
        ld hl, $0000 | zest.vdp.VRAMWrite
        call zest.vdp.setAddress

        ; Output 16KB of zeroes
        ld bc, $4000    ; counter for 16KB of VRAM
        -:
            xor a       ; set A to 0

            ; Output to VRAM address, which is auto-incremented after each write
            out (zest.vdp.DATA_PORT),a
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
.section "zest.vdp.setAddress" free
    zest.vdp.setAddress:
        push af
            ld a, l
            out (zest.vdp.CONTROL_PORT), a
            ld a, h
            out (zest.vdp.CONTROL_PORT), a
        pop af
        ret
.ends

;====
; Sets the VDP address
;
; @in   de  address
;====
.section "zest.vdp.setAddressDE" free
    zest.vdp.setAddressDE:
        push af
            ld a, e
            out (zest.vdp.CONTROL_PORT), a
            ld a, d
            out (zest.vdp.CONTROL_PORT), a
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
.section "zest.vdp.copyToVram" free
    zest.vdp.copyToVram:
        -:
            ld a, (hl)  ; Get data byte
            out (zest.vdp.DATA_PORT), a
            inc hl      ; Point to next letter
            dec bc
            ld a, b
            or c
        jr nz,-

        ret
.ends

;====
; Sets the value of register 1
;
; @in   value %00000000
;             ;|||||||`-  Zoomed sprites -> 16x16 pixels
;             ;||||||`--  Tall sprites -> 2 tiles per sprite, 8x16
;             ;|||||`---  Mega Drive mode 5 enable
;             ;||||`----  30 row/240 line mode (SMS2 only)
;             ;|||`-----  28 row/224 line mode (SMS2 only)
;             ;||`------  Enable VBlank interrupts
;             ;|`-------  Enable display
;             ;`--------  Unused; always 1
;====
.macro "zest.vdp.setRegister1" args value
    ld a, value
    out (zest.vdp.CONTROL_PORT), a
    ld a, $81   ; register 1
    out (zest.vdp.CONTROL_PORT), a
.endm
