;====
; Increments the value in A up to 255
;
; @in   a   the value to increment
; @out  a   the incremented value, capped to 255
;====
.section "increment" free
    increment:
        inc a
        ret nz  ; return if it hasn't overflowed to 0
        dec a   ; otherwise, set back to 255
        ret
.ends