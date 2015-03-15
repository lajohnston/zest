;==============================================================
; SMS defines
;==============================================================
.define smsspec.ports.vdp.control $bf
.define smsspec.ports.vdp.data $be
.define smsspec.ports.vdp.status $be ; same as Vdp.data, as that is write only and this is read only
.define smsspec.vdp.VRAMWrite $4000
.define smsspec.vdp.CRAMWrite $c000

;==============================================================
; WLA-DX banking setup
; Allows 32KB ROM (starts at 0, ends at $8000 bytes)
;==============================================================
.memorymap
    defaultslot 0
    slotsize $8000
    slot 0 $0000
.endme

.rombankmap
    bankstotal 1
    banksize $8000
    banks 1
.endro


; SDSC tag and SMS rom header
.sdsctag 1.2,"SMSSpec", "Sega Master System Unit Test Runner", "eljay"


/**
 * Pause button handler
 */
.bank 0 slot 0
.orga $0066
retn


/**
 * VBlank handler
 */
.orga $0038
.section "Interrupt handler" force
    push af
        in a, (smsspec.ports.vdp.status) ; satisfy interrupt
        call smsspec.onVBlank
    pop af
    ei
    reti
.ends


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



;===================================================================
; Assertion and test macros
;===================================================================


/**
 * Can be used to describe the unit being tested
 */
.macro "describe" args unit_name

.endm

/**
 * Specified a new test with a description.
 * Resets the Z80 registers ready for the new test
 */
.macro "it" args message
    ; Write message to buffer

    ; Clear system state
    call smsspec.clearSystemState
.endm


.macro "assertAccEquals" args expected
    cp expected

    jr z, +
        assertionFailed "Failed"
    +:
.endm


/*
.macro "assertRegisterEquals" args expected, register
    push af
        ld a, register
        cp expected
        
        jr z, +
            pop af
            assertionFailed "Failed"
        +:
    pop af
.endm
 */


.macro "assertionFailed" args message, actual
    jp assertionFailed
.endm




;===================================================================
; SMSSpec internal procedures
;===================================================================

.section "smsspec.init" free
    smsspec.init:
        ; Set up VDP registers
        ld hl, smsspec.vdp_init_data
        ld b, smsspec.vdp_init_data_end - smsspec.vdp_init_data
        ld c, smsspec.ports.vdp.control
        otir

        call smsspec.clearVram

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
        ld hl, smsspec.font_data              ; Location of tile data
        ld bc, smsspec.font_data_size          ; Counter for number of bytes to write
        call smsspec.copyToVDP

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

.section "smsspec.clearSystemState" free
    smsspec.clearSystemState:
        xor a
        ld b, a
        ld c, a
        ld d, a
        ld e, a
        ld h, a
        ld l, a

        ; reset fps counter

        ; do same for shadow flags 
        
        ret       
.ends

.ramsection "smsspec.console.variables" bank 0 slot 0
    smsspec.console.hpos  db
    smsspec.console.ypos  db
.ends

.section "smsspec.console" free
    smsspec.console.out:
        ; 1. Set VRAM write address to tilemap index 0
        ld hl,$3800 | smsspec.vdp.VRAMWrite
        call smsspec.setVDPAddress

        ; 2. Output tilemap data
        ld hl, smsspec.heading
        -:
            ld a, (hl)
            cp $ff
            jr z,+
            out (smsspec.ports.vdp.data), a
            xor a
            out (smsspec.ports.vdp.data), a
            inc hl
        jr -
        
        +:
            ret
.ends

.section "smsspec.onVBlank" free
    smsspec.onVBlank:
        ret
.ends

.section "smsspec.onFailure" free
    assertionFailed:
        call smsspec.console.out
        -: jp -
.ends


;===================================================================
; Data
;===================================================================

.section "smsspec.data" free
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

    smsspec.font_data:
    .incbin "assets/font.bin" fsize smsspec.font_data_size
.ends