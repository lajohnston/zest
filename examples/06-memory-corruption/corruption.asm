;====
; Overwrites everything in RAM (including Zest's state)
;====
.section "corruptRoutine" free
    corruptRoutine:
        ld hl, $c000
        ld de, $c000 + 1
        ld bc, $1FFF
        ldir
        ret
.ends