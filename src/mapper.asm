;====
; Slots
; These contain fixed address ranges that ROM banks can be mapped into
;====
.define zest.mapper.ZEST_SLOT 0     ; fixed Zest code + assets
.define zest.mapper.SUITE_SLOT 2    ; where user's code is paged
.define zest.mapper.RAM_SLOT 3

.define zest.mapper.SEGA_HEADER_SIZE 16
.define zest.mapper.ZEST_SLOT_SIZE $3ff0 - zest.mapper.SEGA_HEADER_SIZE
.define zest.mapper.SUITE_SLOT_ADDRESS zest.mapper.ZEST_SLOT_SIZE + zest.mapper.SEGA_HEADER_SIZE

.memorymap
    defaultslot zest.mapper.SUITE_SLOT

    ; ~16KB - Zest code
    slotsize zest.mapper.ZEST_SLOT_SIZE
    slot zest.mapper.ZEST_SLOT $0000

    ; 16B - Sega header
    slotsize zest.mapper.SEGA_HEADER_SIZE
    slot 1 zest.mapper.ZEST_SLOT_SIZE

    ; 32KB - Pageable user code/tests
    slotsize $8000  ; 32KB
    slot zest.mapper.SUITE_SLOT zest.mapper.SUITE_SLOT_ADDRESS

    ; 8KB - RAM
    slotsize $2000  ; 8KB
    slot zest.mapper.RAM_SLOT $c000
.endme

;====
; ROM Banks
; These can be mapped into the slots above
;====
.define zest.mapper.ZEST_BANK 0
.define zest.mapper.SUITE_BANK_1 2
.define zest.mapper.SUITE_BANKS 1

.rombankmap
    bankstotal 2 + zest.mapper.SUITE_BANKS

    ; Zest bank
    banksize zest.mapper.ZEST_SLOT_SIZE
    banks 1

    ; Sega header bank
    banksize zest.mapper.SEGA_HEADER_SIZE
    banks 1

    ; Suite banks
    banksize $8000
    banks zest.mapper.SUITE_BANKS
.endro
