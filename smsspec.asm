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

        ; Init console
        ld hl, smsspec.console.cursor_pos
        ld (hl), $40
        inc hl
        ld (hl), $38

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

.section "smsspec.onVBlank" free
    smsspec.onVBlank:
        ret
.ends

.section "smsspec.onFailure" free
    assertionFailed:
        ld hl, (smsspec.current_describe_message_addr)
        call smsspec.console.out
 
        ;smsspec.current_test_message_addr: dw

        ; Stop program
        -: jp -
.ends


/**
 * Stores text in the ROM and adds a pointer to it at the given
 * RAM location
 */
.macro "smsspec.storeText" args text, ram_pointer
    jr +
    _text\@:
        .asc text
        .db $ff    ; terminator byte
    +:

    ld hl, ram_pointer
    ld (hl), <_text\@
    inc hl
    ld (hl), >_text\@
.endm



;===================================================================
; Console
;===================================================================

.define smsspec.console.COLUMNS 31

.ramsection "smsspec.console.variables" slot 2
    smsspec.console.cursor_pos:  dw
.ends


.section "smsspec.console" free
    /**
     * Write text to the console
     * @param hl    the address of the text to write. The text should be
     *              terminated by an $FF byte
     */
    smsspec.console.out:
        ;push af
        ;push bc
            ; 1. Set VRAM write address to tilemap index 0
            push hl
                ; Get remaining characters left in the current line
                ld hl, (smsspec.console.cursor_pos)
                ld a, h
                or $40
                ld h, a


                ;ld hl, $3800 | smsspec.vdp.VRAMWrite
                call smsspec.setVDPAddress

                ld d, h
                ld e, l
            pop hl



            ; 2. Output tilemap data
            -:
                ld a, (hl)
                
                ; If $FF terminator, stop
                cp $FF
                jr z, +

                out (smsspec.ports.vdp.data), a
                xor a   ; set a to 0
                out (smsspec.ports.vdp.data), a
                inc hl

                inc de
                inc de
            jr -

        ;pop bc
        ;pop af

        +:
            ld hl, smsspec.console.cursor_pos
            ld (hl), e
            inc hl
            ld (hl), d
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


;===================================================================
; Label mocks
;===================================================================

/**
 * Structure for mock instances in RAM, which hold a counter for the times
 * the mock has been called and the address to jump to to handle the 
 * mock logic
 */
.struct smsspec.mock
    times_called    db
    address         dw
.endst


/**
 * Calls a handler for a mock, which is stored within the mock instance
 * in RAM.
 */
.macro "smsspec.mock.call" args mock
    push hl
        ld hl, mock
        jp smsspec.mock.mediator
    ; pop hl handled by mediator
.endm


/**
 * Set the destination address for a label mock
 */
.macro "smsspec.mock.set" args mock, address
    push hl
    push de
        ld de, address
        ld hl, mock
        inc hl
        ld (hl), e
        inc hl
        ld (hl), d
    pop de
    pop hl
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
    /**
     * Defines a procedure that mocks run by default
     */
    smsspec.mock.default_handler:
        ; by default, mocks just return to caller
        ret


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
; Standard macros
;===================================================================

.ramsection "smsspec.current_test_info" slot 2
    smsspec.current_describe_message_addr: dw
    smsspec.current_test_message_addr: dw
.ends

/**
 * Can be used to describe the unit being tested
 * Stores a pointer to the description test which is used to
 * identify the test to the user if it fails
 */
.macro "describe" args unit_name
    smsspec.storeText unit_name, smsspec.current_describe_message_addr
.endm


/**
 * Specified a new test with a description.
 * Resets the Z80 registers ready for the new test
 */
.macro "it" args message
    smsspec.storeText message, smsspec.current_test_message_addr

    ; Clear system state
    call smsspec.clearSystemState
.endm


;===================================================================
; Assertions
;===================================================================



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
