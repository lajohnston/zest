;====
; Some code that polls the VBlank flags until there is a VBlank
; We'll need to mock this port so we can return a value with the flag set,
; otherwise it will loop indefinitely
;
; Like in the input example, rather than using 'in a' directly we'll create a
; 'readPort' macro to do this and put it in a separate file. In the test suite
; we'll import a fake version with the same name, and when this code runs it
; won't know the difference
;====

;====
; Polls until the VBlank flag is set, then returns.
; otherwise it will loop indefinitely
.section "vdp" free
    waitForVBlank:
        readPort $bf        ; read the VDP status flags
        bit 7, a            ; check if the VBlank flag is set
        ret nz              ; return if set
        jr waitForVBlank    ; otherwise, keep polling
.ends

;====
; Jumps to the given label if the sprite overflow flag isn't set,
; otherwise continues
;====
.macro "ifOverflow" args else
    readPort $bf    ; read the VDP status flags
    bit 6, a        ; check if the sprite overflow flag is set
    jp z, else      ; if not set, jump to else
.endm

;====
; Jumps to the given label if the sprite collision flag isn't set,
; otherwise continues
;====
.macro "ifCollision" args else
    readPort $bf    ; read the VDP status flags
    bit 5, a        ; check sprite collision flag
    jp z, else      ; if not set, jump to else
.endm

