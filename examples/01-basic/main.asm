.incdir "../../"

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

; Ensure SMS header and checksum is added
.smstag

; ASCII table
.asciitable
    map " " to "~" = 0
.enda

;====
; Boot sequence
;====
.orga $0000
.section "zest.main" force
    di              ; disable interrupts
    im 1            ; Interrupt mode 1
    ld sp, $dff0    ; set stack pointer
    jp zest.runner.init
.ends

;====
; VBlank handler
;
; Detects if the Zest state has been overwritten or if the current test has
; reached its timeout limit
;====
.orga $0038
.section "main.interruptHandler" force
    push af
    push hl
        ; Satisfy interrupt
        in a, (zest.vdp.STATUS_PORT)

        ; Ensure timeout limit hasn't been reached
        ; call zest.timeout.update
    pop hl
    pop af

    ei      ; re-enable interrupts
    reti    ; return
.ends

;====
; Pause handler
;====
.orga $0066
.section "main.pauseHandler" force
    retn
.ends


.include "./src/vdp.asm"

.include "./src/console/console.asm"

.include "./src/preSuite.asm"
.include "./src/preTest.asm"
