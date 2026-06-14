;====
; Mocks the VDP status flag values
;====

.define zest.plugin.mockVdpStatusFlags 1

;====
; Constants
;====
.define zest.VDP_NO_STATUS_FLAGS            %00000000
.define zest.VDP_VBLANK_STATUS              %10000000
.define zest.VDP_SPRITE_OVERFLOW_STATUS     %01000000
.define zest.VDP_SPRITE_COLLISION_STATUS    %00100000

;====
; Sets the fake VDP status flags
;
; @in   (sp)    the byte value to mock
;====
.section "zest.mockVdpStatusFlags.set" free
    zest.mockVdpStatusFlags.set:
        ex (sp), hl     ; set HL to data pointer

        push af
            ld a, (hl)  ; load the mock value
            zest.ports.set $bf
        pop af

        inc hl          ; skip over mock byte
        ex (sp), hl     ; restore stack pointer

        ret
.ends

;====
; Mock the VDP status flags in port $bf to return a given value
;
; @in   value   the VDP status flags to mock, i.e.
;               zest.VDP_VBLANK_STATUS, zest.VDP_SPRITE_OVERFLOW_STATUS, zest.VDP_SPRITE_COLLISION_STATUS
;               Combine multiple with '|', i.e zest.VDP_VBLANK_STATUS | zest.VDP_SPRITE_COLLISION_STATUS
;====
.macro "zest.mockVdpStatusFlags" args value
    zest.utils.validate.equals NARGS, 1, "\. expects 1 argument (i.e. zest.VDP_VBLANK_STATUS, zest.VDP_SPRITE_OVERFLOW_STATUS, zest.VDP_SPRITE_COLLISION_STATUS). Combine multiple with '|', i.e zest.VDP_VBLANK_STATUS | zest.VDP_SPRITE_COLLISION_STATUS"
    zest.utils.validate.byte value, "\. expects a numeric byte value"

    \@_\.:
    call zest.mockVdpStatusFlags.set
    .db value
.endm
