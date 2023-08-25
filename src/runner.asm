.define zest.runner.CHECKSUM_BASE %01001101

;===
; Test description backup location in VRAM, to recover from RAM overwrites
; This location resides in the gap in the sprite attribute table after the
; 64 bytes of Y coordinates
;===
.define zest.runner.VRAM_BACKUP_READ_ADDRESS $3f00 + 64
.define zest.runner.VRAM_BACKUP_WRITE_ADDRESS zest.runner.VRAM_BACKUP_READ_ADDRESS | zest.vdp.VRAMWrite

.ramsection "zest.runner.current_test_info" slot zest.mapper.RAM_SLOT
    ; A checksum of the describe and test message pointers, to detect tampering
    zest.runner.description_checksum: db

    ; The current test description message pointers
    zest.runner.current_describe_message_addr: dw
    zest.runner.current_test_message_addr: dw

    ; The number of tests that have passed
    zest.runner.tests_passed: dw
.ends

;====
; Initialise the system and run the test suite
;====
.section "zest.runner.init" free
    zest.runner.init:
        ; Initialise VDP
        call zest.vdp.init
        call zest.vdp.clearVram

        ; Start tests passed counter to $ffff. This will be incremented to 0
        ; when the first test runs
        ld hl, $ffff
        ld (zest.runner.tests_passed), hl

        ; Run the test suite (label defined by user)
        call zest.suite

        ; All tests passed. Display message
        zest.console.initSuccess
        ld hl, zest.console.data.heading
        call zest.console.out
        call zest.console.newline
        call zest.console.newline

        ld hl, zest.console.data.allTestsPassed
        call zest.console.out
        call zest.console.displayMessage

        ; End
        -:
            halt
        jr -
.ends

;====
; Displays details about a byte/single register assertion that doesn't match
; the expectation, then stops the program
;
; @in   a   the actual value
; @in   b   the expected value
; @in   hl  pointer to the assertion message
;====
.section "zest.runner.byteExpectationFailed" free
    zest.runner.byteExpectationFailed:
        call zest.runner._printTestFailure

        ; Print 'Expected:' label
        call zest.runner._printExpectedLabel

        ; Print expected value
        push af
            ld a, b ; set A to expected value
            call zest.console.outputHexA
        pop af

        ; Print 'Actual:' label
        call zest.runner._printActualLabel

        ; Print actual value
        call zest.console.outputHexA
        jp zest.console.displayMessage  ; jp (then ret)
.ends

;====
; Displays details about a 16-bit value assertion that doesn't match
; the expectation, then stops the program
;
; @in   bc  the expected value
; @in   de  the actual value
; @in   hl  pointer to the assertion message
;====
.section "zest.runner.wordExpectationFailed" free
    zest.runner.wordExpectationFailed:
        ; Print the test describe/it descriptions
        call zest.runner._printTestFailure

        ; Print expected label
        call zest.runner._printExpectedLabel

        ; Print expected value
        call zest.console.outputHexBC

        ; Print actual label
        call zest.runner._printActualLabel

        ; Print actual value
        call zest.console.outputHexDE
        jp zest.console.displayMessage  ; jp (then ret)
.ends

;====
; Displays details about a boolean/flag  assertion that doesn't match
; the expectation, then stops the program
;
; @in   a   the expected value (a 1 or a 0)
; @in   hl  pointer to the assertion message
;====
.section "zest.runner.booleanExpectationFailed" free
    zest.runner.booleanExpectationFailed:
        call zest.runner._printTestFailure

        ; Print 'Expected:' label
        call zest.runner._printExpectedLabel

        ; Print expected value
        call zest.console.outputBoolean

        ; Print 'Actual:' label
        call zest.runner._printActualLabel

        ; Print actual value
        push af
            inc a           ; invert bit 0
            and %00000001   ; mask out other bits
            call zest.console.outputBoolean
        pop af

        jp zest.console.displayMessage  ; jp (then ret)
.ends

;====
; (Private) Prints the test failed heading, test description, and assertion
; message
;
; @in   hl  pointer to the assertion message
;====
.section "zest.runner._printTestFailure" free
    zest.runner._printTestFailure:
        ; Initialise the console
        zest.console.initFailure

        ; Print test details
        call zest.runner._printTestFailedHeading
        call zest.runner._printTestDescription

        ; Print the failed assertion message
        jp zest.runner._printAssertionMessage   ; jp (then ret)
.ends

;====
; (Private) Prints the Test Failed heading
;====
.section "zest.runner._printTestFailedHeading" free
    zest.runner._printTestFailedHeading:
        push hl
            ; Write test failed message
            ld hl, zest.console.data.testFailedHeading
            call zest.console.out

            ; Separator
            call zest.console.newline
            call zest.console.newline
            ld hl, zest.console.data.separatorText
            call zest.console.out
        pop hl

        call zest.console.newline
        jp zest.console.newline ; jp then ret
.ends

;====
; (Private) Prints the current test's 'describe' and 'it' text
;====
.section "zest.runner._printTestDescription" free
    zest.runner._printTestDescription:
        push hl
            ; Write describe block description
            ld hl, (zest.runner.current_describe_message_addr)
            call zest.console.out

            ; Write failing test
            call zest.console.newline
            call zest.console.newline
            ld hl, (zest.runner.current_test_message_addr)
            call zest.console.out
        pop hl

        ret
.ends

;====
; (Private) Prints the message of the assertion that failed
;
; @in   hl  pointer to the message
;====
.section "zest.runner._printAssertionMessage" free
    zest.runner._printAssertionMessage:
        ; Write assertion message
        call zest.console.newline
        call zest.console.newline
        call zest.console.newline

        push hl
            ld hl, zest.console.data.separatorText
            call zest.console.out

            call zest.console.newline
            call zest.console.newline
        pop hl

        jp zest.console.out ; jp then ret
.ends

;====
; (Private) Prints the 'Expected:' label
;====
.section "zest.runner._printExpectedLabel" free
    zest.runner._printExpectedLabel:
        call zest.console.newline
        call zest.console.newline

        push hl
            ld hl, zest.console.data.expectedValueLabel
            call zest.console.out
        pop hl

        ret
.ends

;====
; (Private) Prints the 'Actual:' label
;====
.section "zest.runner._printActualLabel" free
    zest.runner._printActualLabel:
        call zest.console.newline

        push hl
            ld hl, zest.console.data.actualValueLabel
            call zest.console.out
        pop hl

        ret
.ends

;====
; (Private) Sets all the registers to zero
;====
.macro "zest.runner.clearMainRegisters"
    xor a       ; set A to zero
    or 1        ; clear all flags (but sets A to 1)
    ld a, 0     ; set A to zero again (without affecting flags)

    ; Set remaining register to A (zero)
    ld b, a
    ld c, a
    ld d, a
    ld e, a
    ld h, a
    ld l, a
.endm

;====
; Sets all the current registers and shadow registers to 0
;====
.section "zest.runner.clearRegisters" free
    zest.runner.clearRegisters:
        ; Clear main registers
        zest.runner.clearMainRegisters

        ; Clear shadow registers
        ex af, af'
        exx
        zest.runner.clearMainRegisters

        ; Clear additional registers
        ld ix, 0
        ld iy, 0
        ld i, a

        ret
.ends

;====
; Can be used to describe the unit being tested
; Stores a pointer to the description test which is used to
; identify the test to the user if it fails
;====
.macro "zest.runner.describe" args unitName
    zest.runner.storeText unitName, zest.runner.current_describe_message_addr
.endm

;====
; Calculates a 1-byte checksum value from the current describe and test text
; pointers in RAM
;
; @out  a   the checksum
; @clobs    f, hl
;====
.section "zest.runner.calculateChecksum" free
    zest.runner.calculateChecksum:
        ld a, zest.runner.CHECKSUM_BASE

        ; Include describe text pointer in checksum
        ld hl, (zest.runner.current_describe_message_addr)
        add l
        rrca
        add h

        ; Include test text pointer in checksum
        ld hl, (zest.runner.current_test_message_addr)
        xor l
        rrca
        add h

        ret
.ends

;====
; Checks if the memory checksum is valid
;
; @out  z   1 if checksum is valid, otherwise 0
;====
.macro "zest.runner._validateChecksum"
    ; Calculate checksum from the values in RAM
    call zest.runner.calculateChecksum

    ; Compare the checksum with the one stored in RAM
    ld hl, zest.runner.description_checksum
    cp (hl)
.endm

;====
; Recovers from a memory corruption and displays a test failure message
;====
.section "zest.runner.memoryOverwriteDetected" free
    zest.runner.memoryOverwriteDetected:
        ; Reset stack pointer, in case it's invalid
        ld sp, $dff0

        ; Check if the test description is valid
        zest.runner._validateChecksum
        jp z, _printTestDescription     ; print if valid

        ; Checksum invalid - restore test description from VRAM backup
        call zest.runner.restoreStateFromVram

        ; Validate backup data
        zest.runner._validateChecksum
        jp z, _printTestDescription     ; print if valid

        ; Backup data also invalid - display generic message
        zest.console.initFailure
        call zest.runner._printTestFailedHeading

        ; Display RAM overwritten error
        ld hl, _memoryCorruptionMessage
        call zest.console.out
        call zest.console.displayMessage
        jp _stopProgram

    _printTestDescription:
        ; Initialise failure heading
        zest.console.initFailure
        call zest.runner._printTestFailedHeading

        ; Print the test description
        call zest.runner._printTestDescription

        ; Print the RAM overwritten message
        ld hl, _memoryCorruptionMessage
        call zest.runner._printAssertionMessage
        call zest.console.displayMessage

    _stopProgram:
        ; Stop the program
        -:
            halt
        jp -

    _memoryCorruptionMessage:
        .asc "   Zest RAM state overwritten"
        .db $ff
.ends

;====
; Backs up the test text description pointers to VRAM, incase of RAM overwrite
; @clobs hl, bc
;====
.section "zest.runner.backupStateToVram" free
    zest.runner.backupStateToVram:
        ; Set VRAM write address
        ld hl, zest.runner.VRAM_BACKUP_WRITE_ADDRESS
        call zest.vdp.setAddress

        ; Set pointer to start of test description block
        ld hl, zest.runner.description_checksum
        ld c, (zest.vdp.DATA_PORT)

        ; Copy data from RAM to VRAM
        outi    ; write checksum
        outi    ; describe text low
        outi    ; describe text high
        outi    ; test text low
        outi    ; test text high

        ret
.ends

;====
; Restores the test data from the VRAM backup
;
; @clobs af, bc, hl
;====
.section "zest.runner.restoreStateFromVram" free
    zest.runner.restoreStateFromVram:
        ; Set VRAM read address
        ld hl, zest.runner.VRAM_BACKUP_READ_ADDRESS
        call zest.vdp.setAddress

        ; Set pointer to start of test description block
        ld hl, zest.runner.description_checksum
        ld c, (zest.vdp.DATA_PORT)

        ; Copy data from VRAM to RAM
        ini     ; checksum
        ini     ; describe text low
        ini     ; describe text high
        ini     ; test text low
        ini     ; test text high

        ret
.ends

;====
; Prepares the start of a new test
;====
.section "zest.runner.preTest" free
    zest.runner.preTest:
        ; Set checksum of current test description
        call zest.runner.calculateChecksum
        ld (zest.runner.description_checksum), a

        ; Backup test descriptions to VRAM
        call zest.runner.backupStateToVram

        ; Reset mocks
        call zest.mock.initAll

        ; Reset timeout counter
        zest.timeout.reset

        ; Disable display and enable VBlank interrupts
        in a, (zest.vdp.STATUS_PORT)    ; clear pending interrupts
        zest.vdp.setRegister1 %10100000 ; enable VBlank interrupts
        ei                              ; enable CPU interrupts

        ; Clear registers
        jp zest.runner.clearRegisters   ; jp/ret
.ends

;====
; Performs check and cleanup operations to be run after each test
;====
.section "zest.runner.postTest" free
    zest.runner.postTest:
        ; Increment tests passed. Counter starts at $FFFF, so this will
        ; initialise it to $0 on the first run
        ld hl, (zest.runner.tests_passed)
        inc hl
        ld (zest.runner.tests_passed), hl

        ; Return if no tests have run yet
        ld a, h
        or l
        ret z

        ; Set Z if checksum is valid
        zest.runner._validateChecksum

        ; Jump if the checksums don't match
        jr nz, _checksumInvalid

        ret

    _checksumInvalid:
        jp zest.runner.memoryOverwriteDetected
.ends

;====
; Initialises a new test.
; Resets the Z80 registers and stores the test description in case the test fails
;====
.macro "zest.runner.startTest" args message
    call zest.runner.postTest
    zest.runner.storeText message, zest.runner.current_test_message_addr
    call zest.runner.preTest

    ; Reset stack (base address minus return address from zest.suite)
    ld sp, $dfee
.endm

;====
; Stores text in the ROM and adds a pointer to it at the given
; RAM location
;
; @in   text        the string to store
; @in   ramPointer  the pointer in RAM to store the text in
;====
.macro "zest.runner.storeText" args text, ramPointer
    jr +
    _text\@:
        .asc text
        .db $ff    ; terminator byte
    +:

    ld hl, _text\@
    ld (ramPointer), hl
.endm
