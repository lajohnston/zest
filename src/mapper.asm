;====
; Memory mapper
;====

;====
; Settings
;====
.ifdef zest.SUITE_BANKS
    zest.utils.validate.range zest.SUITE_BANKS, 1, 255, "Invalid zest.SUITE_BANKS defined"
    .define zest.mapper.SUITE_BANKS zest.SUITE_BANKS
.else
    ; Default to 1 suite bank
    .define zest.mapper.SUITE_BANKS 1
.endif

;====
; SMS header and checksum
;====
.smsheader
    romsize $a          ; 8KB checksum - fastest
    baseaddress $3ff0   ; move header outside of SUITE bank
.endsms

;====
; Slots
; These contain fixed address ranges that ROM banks can be mapped into
;====
.define zest.mapper.ZEST_SLOT 0     ; fixed Zest code + assets
.define zest.mapper.SUITE_SLOT 1    ; where user's code is paged
.define zest.mapper.RAM_SLOT 3

; The register used to page the bank into slot 1
.define zest.mapper.SLOT_1_REGISTER = $fffe

; Sega mapper (4x16KB slots)
.memorymap
    defaultslot 0
    slotsize $4000

    ; 16KB - Zest code
    slot zest.mapper.ZEST_SLOT $0000

    ; 16KB - Pageable user suite
    slot zest.mapper.SUITE_SLOT $4000

    ; 16KB - Pageable (not used)
    slot 2 $8000

    ; 16KB RAM (8KB + 8KB mirror)
    slot zest.mapper.RAM_SLOT $c000
.endme

;====
; ROM Banks
; These can be mapped into the slots above using zest.mapper.pageBank
;====
.define zest.mapper.ZEST_BANK 0
.define zest.mapper.PADDING_BANKS 0

.if zest.mapper.SUITE_BANKS == 2
    ; Pad ROM from 48KB to 64KB, to mitigate emulator mapper detection issue
    .redefine zest.mapper.PADDING_BANKS 1
.endif

.rombankmap
    bankstotal 1 + zest.mapper.SUITE_BANKS + zest.mapper.PADDING_BANKS
    banksize $4000  ; 16KB

    ; 16KB Zest bank
    banks 1

    ; 16KB suite banks
    banks zest.mapper.SUITE_BANKS

    ; 16KB padding bank(s)
    .if zest.mapper.PADDING_BANKS > 0
        banks zest.mapper.PADDING_BANKS
    .endif
.endro

;====
; Sets the current pageable bank. Free sections .included after this will be
; placed in this bank
;
; @in   bankNumber  the bank number
;====
.macro "zest.mapper.setBank" args bankNumber
    zest.utils.validate.range bankNumber 0, zest.mapper.SUITE_BANKS, "\.: Invalid bankNumber"

    .if bankNumber == zest.mapper.ZEST_BANK
        .bank zest.mapper.ZEST_BANK slot zest.mapper.ZEST_SLOT
    .else
        .bank bankNumber slot zest.mapper.SUITE_SLOT
    .endif
.endm

;====
; Page a bank into the given slot
;
; @in   bankNumber      the bank number to page in. Use the colon prefix in
;                       WLA-DX to retrieve the bank number of an address,
;                       i.e. mapper.pageBank :myAsset
;====
.macro "zest.mapper.pageBank" args bankNumber
    zest.utils.validate.range bankNumber 0, zest.mapper.SUITE_BANKS, "\.: Invalid bankNumber"

    ld a, bankNumber
    ld (zest.mapper.SLOT_1_REGISTER), a
.endm
