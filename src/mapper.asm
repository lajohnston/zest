;====
; Slots
; These contain fixed address ranges that ROM banks can be mapped into
;====
.define zest.mapper.ZEST_SLOT 0     ; fixed Zest code + assets
.define zest.mapper.SUITE_SLOT 1    ; where user's code is paged
.define zest.mapper.RAM_SLOT 3

; Sega mapper (4x16KB slots)
.memorymap
    defaultslot 0

    ; 16KB - Zest code
    slotsize $4000
    slot zest.mapper.ZEST_SLOT $0000

    ; 16KB - Pageable user suite
    slotsize $4000
    slot zest.mapper.SUITE_SLOT $4000

    ; 16KB - Pageable (not used)
    slotsize $4000
    slot 2 $8000

    ; 16KB RAM (8KB + 8KB mirror)
    slotsize $4000
    slot zest.mapper.RAM_SLOT $c000
.endme

;====
; ROM Banks
; These can be mapped into the slots above
;====
.define zest.mapper.ZEST_BANK 0
.define zest.mapper.SUITE_BANK_1 1

.rombankmap
    bankstotal 2

    ; 16KB Zest bank
    banksize $4000
    banks 1

    ; 16KB suite bank
    banksize $4000
    banks 1
.endro
