;====
; Writes text to the screen
;====

.ramsection "zest.console.variables" slot zest.mapper.RAM_SLOT
    zest.console.cursor_vram_address:    dw
.ends

;====
; Initialises the console ready for use
;
; @in   a   the text color (--bbggrr)
;====
.section "zest.console.init" free
    zest.console.init:
        push hl
        push bc
            ; Ensure the display is off
            push af
                zest.vdp.setRegister1 %10000000
            pop af

            ; Set palette index 0 write address
            ld hl, zest.vdp.CRAMWrite   ; palette index 0
            call zest.vdp.setAddress

            ; Set background color
            ld b, a                     ; preserve font color in B
            xor a   ; 0 = black
            out (zest.vdp.DATA_PORT), a

            ; Set font color
            ld a, b                     ; restore font color
            out (zest.vdp.DATA_PORT), a

            ; Set pattern address in VRAM
            ld hl, $0000 | zest.vdp.VRAMWrite
            call zest.vdp.setAddress          ; set VRAM write address to tile index 0

            ; Load pattern data (font) into VRAM
            ld hl, zest.console.data.font
            ld bc, zest.console.data.font_end - zest.console.data.font
            call zest.vdp.copyToVram

            ; Initial cursor position in tilemap
            ld hl, zest.vdp.TILEMAP_BASE | zest.vdp.VRAMWrite
            ld (zest.console.cursor_vram_address), hl
            call zest.vdp.setAddress
        pop bc
        pop hl

        ret
.ends

;====
; Initialises the console with green/success font color
;====
.macro "zest.console.initSuccess"
    push af
        ld a, %00001100 ; green
        call zest.console.init
    pop af
.endm

;====
; Initialises the console with a red/failure font color
;====
.macro "zest.console.initFailure"
    push af
        ld a, %00000011 ; red
        call zest.console.init
    pop af
.endm

;====
; (Private) Outputs a character to the console
;
; @in   a       the character to output
; @in   de      VRAM address
; @in   vdp     pointing to current vram address with write command
;
; @out  de      new vram address
; @out  vdp     VRAM pointing to next character
;
; @clobs a
;====
.macro "zest.console._outputCharacter"
    out (zest.vdp.DATA_PORT), a         ; output character
    xor a                               ; set attributes to none
    out (zest.vdp.DATA_PORT), a         ; output attributes

    ; Increment VRAM address in DE by 1 tile (VRAM auto-increments)
    inc de  ; pattern ref
    inc de  ; attributes
.endm

;====
; Write text to the screen
;
; @in   hl      the address of the text to write. The text should be
;               terminated by an $FF byte
; @in   vram    the vram address + write command
;====
.section "zest.console.out" free
    zest.console.out:
        ; Preserve registers
        push af
        push de

        ; Load VRAM address + write command into DE
        ld de, (zest.console.cursor_vram_address)

        _outputNextCharacter:
            ld a, (hl)
            cp $ff
            jr z, _finish

            ; Check if we're on the last column
            ld a, e
            and %00111110   ; mask X bits
            cp %00111110    ; if X bits are all 1, we're on the last column (31)
            jp nz, +
                ; We're on the last column
                ; Output dash character. VRAM auto-increments to next line
                ld a, 13                        ; dash pattern
                zest.console._outputCharacter
                jp _outputNextCharacter
            +:

            ; Output character to VRAM (auto-increments VRAM position)
            ld a, (hl)  ; re-load character
            zest.console._outputCharacter

            ; Point to next character
            inc hl

            jp _outputNextCharacter

        _finish:
            ; Store position
            ld (zest.console.cursor_vram_address), de

            ; Restore registers
            pop de
            pop af
            ret
.ends

;====
; Enables the display to show the message and stops the runner
;====
.section "zest.console.displayMessage" free
    zest.console.displayMessage:
        zest.vdp.setRegister1 %11000000

        ; Stop program
        -:
            halt
        jp -
.ends

;====
; Move the console cursor onto the next line
;====
.section "zest.console.newline" free
    zest.console.newline:
        push de
            ld de, (zest.console.cursor_vram_address)
            push af
                ;===
                ; VRAM address format
                ; ccbbbyyy yyxxxxx-
                ;
                ; c = command
                ; b = base address
                ; y = row
                ; x = col
                ;===

                ; Set column to zero
                ld a, e         ; set A to low byte of address
                and %11000000   ; mask out x bits
                ld e, a         ; set low byte of address

                ; Add 1 row
                ld a, 32 * 2
                add a, e  ; A = A+E
                ld e, a   ; E = A+E
                adc a, d  ; A = A+E+D+carry
                sub e     ; A = D+carry
                ld d, a   ; D = D+carry
            pop af

            ; Set and store cursor VRAM position
            ld (zest.console.cursor_vram_address), de
            call zest.vdp.setAddressDE
        pop de
        ret
.ends

;====
; Outputs the value of register sas a hex value onto the screen, e.g $F2 of $F12A
;====
.section "zest.console.outputHexA" free
    ;====
    ; Outputs the value of register A as a hex value onto the screen, e.g $F2
    ; @in   af
    ;====
    zest.console.outputHexA:
        push de ; preserve DE
        ld de, (zest.console.cursor_vram_address)

        push af ; preserve value
            ld a, asc('$')
            zest.console._outputCharacter
        pop af

        call _outputAHex

        ; Store cursor position
        ld (zest.console.cursor_vram_address), de
        pop de  ; restore de
        ret

    ;===
    ; Outputs the value in BC as a hex number ($ followed by 4 hex digits)
    ; @in   bc  the value to output
    ;===
    zest.console.outputHexBC:
        push de
            ld de, (zest.console.cursor_vram_address)

            push af
                ld a, asc('$')
                zest.console._outputCharacter

                ld a, b
                call _outputAHex
                ld a, c
                call _outputAHex
            pop af

            ; Store cursor position
            ld (zest.console.cursor_vram_address), de
        pop de
        ret

    ;===
    ; Outputs the value in DE as a hex number ($ followed by 4 hex digits)
    ; @in   de  the value to output
    ;===
    zest.console.outputHexDE:
        ex de, hl   ; swap HL and DE
            call zest.console.outputHexHL
        ex de, hl   ; swap HL and DE back

        ret

    ;===
    ; Outputs the value in HL as a hex number ($ followed by 4 hex digits)
    ; @in   hl  the value to output
    ;===
    zest.console.outputHexHL:
        push de
            ld de, (zest.console.cursor_vram_address)

            push af
                ld a, asc('$')
                zest.console._outputCharacter

                ld a, h
                call _outputAHex
                ld a, l
                call _outputAHex
            pop af
        pop de

        ret

    ;===
    ; Output the value in A as 2 hex characters
    ;
    ; @in   a   the value to output
    ; @in   de  the cursor VRAM address
    ;===
    _outputAHex:
        push af
            rra
            rra
            rra
            rra
            call _printNibble
        pop af  ; restore value

        push af
            call _printNibble
        pop af

        ret


    ;===
    ; Prints the lowest nibble of A as a hex character (0-F)
    ;
    ; @in   a   the value to output (----xxxx)
    ; @in   de  the cursor VRAM address
    ;===
    _printNibble:
        and %00001111
        cp 10       ; set C if value is less than 10 (0-9)
        jp nc, +
            ; Digit is below 10
            add asc('0')  ; point to ASCII characters 0-9
            zest.console._outputCharacter
            ret
        +:

        ; Value is above 10 (A-F)
        sub 10          ; A = 0; B = 1; 15 = F
        add asc('A')    ; point to ASCII characters A-F
        zest.console._outputCharacter
        ret
.ends

;====
; Prints the boolean value of bit 0 of a (an ascii 1 or a 0)
;
; @in   a   the value (bit 0)
;====
.section "zest.console.outputBoolean" free
    zest.console.outputBoolean:
        push af
            add asc('0')
            zest.console._outputCharacter
        pop af

        ret
.ends
