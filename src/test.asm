;====
; Maintains details about the current test being run. Tests consist of a
; describe block that describes the unit being tests, and individual
; tests that test specific aspects of that unit's intended behaviour
;====

;====
; Constants
;====
.define zest.test.CHECKSUM_BASE %01001101   ; used for RAM overwrite detection

;===
; Test description backup location in VRAM, to recover from RAM overwrites
; This location resides in the gap in the sprite attribute table after the
; 64 bytes of Y coordinates
;===
.define zest.test.VRAM_BACKUP_READ_ADDRESS $3f00 + 64   ; sprite table + skip 64 bytes of Y coordinates
.define zest.test.VRAM_BACKUP_WRITE_ADDRESS zest.test.VRAM_BACKUP_READ_ADDRESS | zest.vdp.VRAMWrite

;====
; RAM
;====
.ramsection "zest.test.current" slot zest.mapper.RAM_SLOT
    ; A checksum of the describe and test message pointers, to detect tampering
    zest.test.checksum: db

    ; The current test description message pointers
    zest.test.unit_text_addr: dw
    zest.test.test_text_addr: dw
.ends

;====
; Describe a block of tests. Stores a pointer to the description test
; which is used to identify the test to the user if it fails
;====
.macro "zest.test.setBlockDescription" isolated args blockDescription
    jr +
        describe_\@:
            zest.console.defineString blockDescription
    +:

    ld hl, describe_\@
    ld (zest.test.unit_text_addr), hl
.endm

;====
; Defines the test description in ROM
;
; @in  description  description the text string
; @out hl           pointer to the description in ROM
;====
.macro "zest.test.defineTestDescription" isolated args description
    jr +
        test_\@:
            zest.console.defineString description
    +:

    ld hl, test_\@              ; load HL with pointer to text
.endm

;====
; Defines the given piece of text and loads a pointer of it into HL
;
; @in   hl  pointer to the test description
;====
.macro "zest.test.setTestDescription"
    ld (zest.test.test_text_addr), hl
.endm

;====
; (Private) Calculates a 1-byte checksum value from the current describe and test text
; pointers in RAM
;
; @out      a   the checksum
; @clobbers f, hl
;====
.macro "zest.test._calculateChecksum"
    ld a, zest.test.CHECKSUM_BASE

    ; Include describe text pointer in checksum
    ld hl, (zest.test.unit_text_addr)
    add l
    rrca
    add h

    ; Include test text pointer in checksum
    ld hl, (zest.test.test_text_addr)
    xor l
    rrca
    add h
.endm

;====
; Checks if the RAM data is valid
;
; @out  z   1 if the checksum is valid, otherwise 0
;====
.macro "zest.test.validateChecksum"
    ; Calculate checksum from the values in RAM
    zest.test._calculateChecksum

    ; Compare the checksum with the one stored in RAM
    ld hl, zest.test.checksum
    cp (hl)
.endm

;====
; (Private) Backs up the test text description pointers to VRAM, incase of RAM overwrite
; @clobbers af, hl, bc
;====
.macro "zest.test._backupStateToVram"
    ; Set VRAM write address
    zest.vdp.setAddress zest.test.VRAM_BACKUP_WRITE_ADDRESS

    ; Set pointer to start of test description block
    ld hl, zest.test.checksum
    ld c, (zest.vdp.DATA_PORT)

    ; Copy data from RAM to VRAM
    outi    ; write checksum
    outi    ; describe text low
    outi    ; describe text high
    outi    ; test text low
    outi    ; test text high
.endm

;====
; Should be called when the test is about to run. This updates the checksum
; and backs up the state to VRAM in case the code overwrites it
;====
.macro "zest.test.preTest"
    ; Set checksum of current test description
    zest.test._calculateChecksum
    ld (zest.test.checksum), a  ; store checksum

    ; Backup test descriptions to VRAM
    zest.test._backupStateToVram
.endm

;====
; Ensures the test description data checksum is valid and hasn't been
; overwritten. If it's invalid, it attempts to restore the VRAM backup and
; validates that. If this is also valid then the Z flag will be reset
;
; @out  z   1 if the description in RAM is in a valid state, otherwise 0
;           if both the RAM and VRAM backup were invalid
;====
.section "zest.test.ensureDescriptionIsValid" free
    zest.test.ensureDescriptionIsValid:
        ; Check if the test description is valid
        zest.test.validateChecksum
        ret z   ; return if it's valid

        ; Checksum invalid - restore test description from VRAM backup
        call zest.test._restoreStateFromVram

        ; Validate backup data
        zest.test.validateChecksum
        ret
.ends

;====
; Prints the current test's 'describe' and 'it' text
;====
.section "zest.test.printTestDescription" free
    zest.test.printTestDescription:
        push hl
            ; Write describe block description
            ld hl, (zest.test.unit_text_addr)
            call zest.console.out

            ; Write failing test
            zest.console.newlines 2
            ld hl, (zest.test.test_text_addr)
            call zest.console.out
        pop hl

        ret
.ends

;====
; @out  a   the current test's checksum
;====
.macro "zest.test.loadAChecksum"
    ld a, (zest.test.checksum)
.endm

;====
; (Private) Restores the test data from the VRAM backup
;
; @clobbers af, bc, hl
;====
.section "zest.test._restoreStateFromVram" free
    zest.test._restoreStateFromVram:
        ; Set VRAM read address
        ld hl, zest.test.VRAM_BACKUP_READ_ADDRESS
        call zest.vdp.setAddress

        ; Set pointer to start of test description block
        ld hl, zest.test.checksum
        ld c, (zest.vdp.DATA_PORT)

        ; Copy data from VRAM to RAM
        ini     ; checksum
        ini     ; describe text low
        ini     ; describe text high
        ini     ; test text low
        ini     ; test text high

        ret
.ends
