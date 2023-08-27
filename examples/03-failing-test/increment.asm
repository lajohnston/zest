;====
; Increments the value in A
;====
.section "increment" free
    increment:
        dec a   ; oops!
        ret
.ends