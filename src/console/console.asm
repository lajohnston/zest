;====
; Writes text to the screen
;====

.ramsection "smsspec.console.variables" slot 2
    smsspec.console.cursor_vram_address:    dw
.ends

;====
; Initialises the console ready for use
;====
.section "smsspec.console.init" free
    smsspec.console.init:
      ; Load palette
      ld hl, $0000 | smsspec.vdp.CRAMWrite
      call smsspec.vdp.setAddress
      ld hl, smsspec.console.data.palette
      ld bc, smsspec.console.data.paletteEnd - smsspec.console.data.palette
      call smsspec.vdp.copyToVram

      ; Load tiles
      ld hl, $0000 | smsspec.vdp.VRAMWrite
      call smsspec.vdp.setAddress       ; set VRAM write address to tile index 0

      ; Output tile data
      ld hl, smsspec.console.data.font  ; location of tile data

      ; Counter for number of bytes to write
      ld bc, smsspec.console.data.font_end - smsspec.console.data.font
      call smsspec.vdp.copyToVram

      ; Initial cursor position
      ld hl, smsspec.vdp.TILEMAP_BASE | smsspec.vdp.VRAMWrite
      ld (smsspec.console.cursor_vram_address), hl
      ret
.ends

;====
; Set the console text color
;
; @in   a   the color to set (%xxBBGGRR)
;====
.section "smsspec.console.setTextColor" free
    smsspec.console.setTextColor:
        push hl
            ld hl, (smsspec.vdp.CRAMWrite + 1) | smsspec.vdp.VRAMWrite
            call smsspec.vdp.setAddress
        pop hl

        out (smsspec.vdp.DATA_PORT), a
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
.macro "smsspec.console.outputCharacter"
    out (smsspec.vdp.DATA_PORT), a      ; output character
    xor a                               ; set attributes to none
    out (smsspec.vdp.DATA_PORT), a      ; output attributes

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
.section "smsspec.console.prepWrite" free
    smsspec.console.prepWrite:
        call smsspec.vdp.disableDisplay
        ld de, (smsspec.console.cursor_vram_address)
        jp smsspec.vdp.setAddressDE
.ends

;====
; Finalises the console and enables the display
;
; @in   de      current cursor vram position
;====
.section "smsspec.console.finalise" free
    smsspec.console.finalise:
        ld (smsspec.console.cursor_vram_address), de
        jp smsspec.vdp.enableDisplay
.ends

;====
; Write text to the screen
;
; @in   hl      the address of the text to write. The text should be
;               terminated by an $FF byte
; @in   de      the vram address + write command
; @in   vram    the vram address + write command
;====
.section "smsspec.console.out" free
    smsspec.console.out:
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
                smsspec.console.outputCharacter
                jp _outputNextCharacter
            +:

            ; Output character to VRAM (auto-increments VRAM position)
            ld a, (hl)  ; re-load character
            smsspec.console.outputCharacter

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
.section "smsspec.console.newline" free
    smsspec.console.newline:
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

        jp smsspec.vdp.setAddressDE
.ends
