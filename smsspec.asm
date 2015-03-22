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
        ; Clear mocks to defaults
        ld b, (smsspec.mocks.end - smsspec.mocks.start - 1) / 3 ; number of mocks

        _clearMocks:
            ld hl, smsspec.mocks.start

            -:  ; Each mock
                inc hl

                ; Clear times called
                ld (hl), 0

                ; Reset mock handler to the default
                inc hl
                ld (hl), < smsspec.mock.default_handler
                inc hl
                ld (hl), > smsspec.mock.default_handler
            djnz -

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


.ramsection "smsspec.console.variables" slot 2
    smsspec.console.hpos:  db
    smsspec.console.ypos:  db
.ends


.section "smsspec.console" free
    smsspec.console.out:
        ;ld hl, (smsspec.console.hpos)
        ;ld (hl), $AB
        ;inc hl
        ;ld (hl), $CD
        ;inc hl
        ;ld (hl), $DE

        ; 1. Set VRAM write address to tilemap index 0
        ld hl, $3804 | smsspec.vdp.VRAMWrite
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

.macro "smsspec.console.out"

.endm



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
; Mocks
;===================================================================

.struct smsspec.mock
    times_called    db
    address         dw
.endst

.macro "smsspec.mock.call" args mock
    push hl
        ld hl, mock
        jp smsspec.mock.mediator
    ; pop hl handled by mediator
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
    smsspec.mock.default_handler:
        inc a
        inc a
        ret ; by default, mocks just return to caller

    /**
     * Jumps to an address defined in RAM at runtime without clobbing hl.
     * It does this by writing 'pop hl' and 'jp, n' opcodes to RAM and executing 
     * them from there so that control is passed to the destination code as if
     * this mediator didn't exist, and so there's no need to have a pop hl instruction
     * in the destination code
     *
     * @param hl    the start address of the smsspec mock in RAM
     */
    smsspec.mock.mediator:
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
            ld hl, smsspec.mock.jump.pop
            ld (hl), $E1    ; $E1 = pop hl

            ; Write jp opcode to RAM
            inc hl
            ld (hl), $C3    ; $C3 = jp, n

            ; Write jump address to RAM
            inc hl
            ld (hl), e
            inc hl
            ld (hl), d
        pop de

        ; Jump to opcodes in RAM
        jp smsspec.mock.jump.pop
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