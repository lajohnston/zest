;====
; Writes text to the screen
;====

.ramsection "zest.console.variables" slot 2
    zest.console.cursor_vram_address:    dw
.ends

;====
; Initialises the console ready for use
;====
.section "zest.console.init" free
    zest.console.init:
      ; Load palette
      ld hl, $0000 | zest.vdp.CRAMWrite
      call zest.vdp.setAddress
      ld hl, zest.console.data.palette
      ld bc, zest.console.data.paletteEnd - zest.console.data.palette
      call zest.vdp.copyToVram

      ; Load tiles
      ld hl, $0000 | zest.vdp.VRAMWrite
      call zest.vdp.setAddress          ; set VRAM write address to tile index 0

      ; Output tile data
      ld hl, zest.console.data.font     ; location of tile data

      ; Counter for number of bytes to write
      ld bc, zest.console.data.font_end - zest.console.data.font
      call zest.vdp.copyToVram

      ; Initial cursor position
      ld hl, zest.vdp.TILEMAP_BASE | zest.vdp.VRAMWrite
      ld (zest.console.cursor_vram_address), hl
      ret
.ends

;====
; Set the console text color
;
; @in   a   the color to set (%xxBBGGRR)
;====
.section "zest.console.setTextColor" free
    zest.console.setTextColor:
        push hl
            ld hl, (zest.vdp.CRAMWrite + 1) | zest.vdp.VRAMWrite
            call zest.vdp.setAddress
        pop hl

        out (zest.vdp.DATA_PORT), a
        ret
.ends

;====
; Outputs a character to the console
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
.macro "zest.console.outputCharacter"
    out (zest.vdp.DATA_PORT), a         ; output character
    xor a                               ; set attributes to none
    out (zest.vdp.DATA_PORT), a         ; output attributes

    ; Increment VRAM address in DE by 1 tile (VRAM auto-increments)
    inc de  ; pattern ref
    inc de  ; attributes
.endm

;====
; Prepares the console for writing text to
;
; @out  de      current cursor vram position (with write command)
; @out  vram    current cursor vram position (with write command)
;====
.section "zest.console.prepWrite" free
    zest.console.prepWrite:
        call zest.vdp.disableDisplay
        ld de, (zest.console.cursor_vram_address)
        jp zest.vdp.setAddressDE
.ends

;====
; Finalises the console and enables the display
;
; @in   de      current cursor vram position
;====
.section "zest.console.finalise" free
    zest.console.finalise:
        ld (zest.console.cursor_vram_address), de
        jp zest.vdp.enableDisplay
.ends

;====
; Write text to the screen
;
; @in   hl      the address of the text to write. The text should be
;               terminated by an $FF byte
; @in   de      the vram address + write command
; @in   vram    the vram address + write command
;====
.section "zest.console.out" free
    zest.console.out:
        ; Preserve registers
        push af

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
                zest.console.outputCharacter
                jp _outputNextCharacter
            +:

            ; Output character to VRAM (auto-increments VRAM position)
            ld a, (hl)  ; re-load character
            zest.console.outputCharacter

            ; Point to next character
            inc hl

            jp _outputNextCharacter

        _finish:
            ; Restore registers
            pop af
            ret
.ends

;====
; Move the console cursor onto the next line
;
; @in   de  VRAM address
;====
.section "zest.console.newline" free
    zest.console.newline:
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

        jp zest.vdp.setAddressDE
.ends

;====
; Prints the value of register A as a hex value onto the screen, e.g $F2
;
; @in   af
;====
.section "zest.console.outputHexA" free
    zest.console.outputHexA:
        push af ; preserve value
            ld a, asc('$')
            zest.console.outputCharacter
        pop af

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

    ; Prints the lowest nibble of A as a hex character (0-F)
    _printNibble:
        and %00001111
        cp 10       ; set C if value is less than 10 (0-9)
        jp nc, +
            ; Digit is below 10
            add asc('0')  ; point to ASCII characters 0-9
            zest.console.outputCharacter
            ret
        +:

        ; Value is above 10 (A-F)
        add asc('A')    ; point to ASCII characters A-F
        zest.console.outputCharacter
        ret
.ends