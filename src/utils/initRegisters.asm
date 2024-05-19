;====
; Initialises the registers with unique values based on the current test's
; checksum, for detecting which registers have been clobbered
;====

;====
; Constants
;====
.define zest.utils.initRegisters.A_OFFSET 0
.define zest.utils.initRegisters.F_OFFSET 1
.define zest.utils.initRegisters.B_OFFSET 2
.define zest.utils.initRegisters.C_OFFSET 3
.define zest.utils.initRegisters.D_OFFSET 4
.define zest.utils.initRegisters.E_OFFSET 5
.define zest.utils.initRegisters.H_OFFSET 6
.define zest.utils.initRegisters.L_OFFSET 7
.define zest.utils.initRegisters.IXH_OFFSET 8
.define zest.utils.initRegisters.IXL_OFFSET 9
.define zest.utils.initRegisters.IYH_OFFSET 10
.define zest.utils.initRegisters.IYL_OFFSET 11
.define zest.utils.initRegisters.I_OFFSET 12
.define zest.utils.initRegisters.SHADOW_A_OFFSET 13
.define zest.utils.initRegisters.SHADOW_F_OFFSET 14
.define zest.utils.initRegisters.SHADOW_B_OFFSET 15
.define zest.utils.initRegisters.SHADOW_C_OFFSET 16
.define zest.utils.initRegisters.SHADOW_D_OFFSET 17
.define zest.utils.initRegisters.SHADOW_E_OFFSET 18
.define zest.utils.initRegisters.SHADOW_H_OFFSET 19
.define zest.utils.initRegisters.SHADOW_L_OFFSET 20

;====
; Initialises registers B, C, D, E, H and L
;
; @in   a                   the starting value (for B)
; @out  b, c, d, e, h, l
;====
.macro "zest.utils._initMainRegisters"
    ld b, a
    inc a
    ld c, a
    inc a
    ld d, a
    inc a
    ld e, a
    inc a
    ld h, a
    inc a
    ld l, a
.endm

;====
; Initialises all registers with values derived from the current test's
; checksum
;
; @out  af, bc, de, hl, ix, iy, i, af', bc', de', hl'
;====
.macro "zest.utils.initRegisters"
    call zest.utils._initRegisters
.endm

;====
; See zest.utils.initRegisters macro
;====
.section "zest.utils._initRegisters" free
    zest.utils._initRegisters:
        ; Init what will become the shadow registers
        zest.test.loadAChecksum
        add zest.utils.initRegisters.SHADOW_A_OFFSET

        ; Set HL to what will become AF'
        ld h, a
        inc a
        ld l, a
        push hl ; push what will be AF'
            ; Initialise BC, DE, HL
            inc a
            zest.utils._initMainRegisters
        pop af  ; set AF to initial values

        ; Switch these to the shadow registers
        ex af, af'
        exx

        ; Init non-shadow registers
        zest.test.loadAChecksum
        ld h, a
        inc a
        ld l, a
        push hl ; push what will be AF
            inc a
            zest.utils._initMainRegisters

            ; Init index registers
            inc a
            ld ixh, a
            inc a
            ld ixl, a
            inc a
            ld iyh, a
            inc a
            ld iyl, a
            inc a
            ld i, a
        pop af

        ret
.ends
