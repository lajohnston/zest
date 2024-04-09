;====
; Runs a slow routine to demonstrate timeout detection
;====
.section "slowRoutine" free
    slowRoutine:
        ld bc, $C000

        -:
            dec bc
            ld a, b
            or c
        jp nz, -

        ret
.ends