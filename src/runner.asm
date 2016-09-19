.ramsection "smsspec.runner.current_test_info" slot 2
    smsspec.runner.current_describe_message_addr: dw
    smsspec.runner.current_test_message_addr: dw
.ends

.section "smsspec.runner.expectationFailed" free
    smsspec.runner.expectationFailed:
        ; Set console text color to red
        ld a, %00000011
        call smsspec.console.setTextColor   ; set to a

        ld hl, (smsspec.runner.current_describe_message_addr)
        call smsspec.console.out

        call smsspec.console.newline
        call smsspec.console.newline

        ld hl, (smsspec.runner.current_test_message_addr)
        call smsspec.console.out

        ; Stop program
        -: jp -
.ends

.macro "smsspec.runner.expectationFailed" args message, actual
    jp smsspec.runner.expectationFailed
.endm

.section "smsspec.runner.clearSystemState" free
    smsspec.runner.clearSystemState:
        ; Clear mocks to defaults
        ld hl, smsspec.mocks.start + 1
        ld b, (smsspec.mocks.end - smsspec.mocks.start - 1) / _sizeof_smsspec.mock ; number of mocks
        call smsspec.mock.initAll

        ; Clear registers
        xor a
        ld b, a
        ld c, a
        ld d, a
        ld e, a
        ld h, a
        ld l, a
        ld ix, 0
        ld iy, 0

        ; do same for shadow flags

        ; reset fps counter
        ret
.ends

/**
 * Can be used to describe the unit being tested
 * Stores a pointer to the description test which is used to
 * identify the test to the user if it fails
 */
.macro "describe" args unitName
    smsspec.runner.storeText unitName, smsspec.runner.current_describe_message_addr
.endm

/**
 * Initialises a new test.
 * Resets the Z80 registers and stores the test description in case the test fails
 */
.macro "it" args message
    smsspec.runner.storeText message, smsspec.runner.current_test_message_addr

    ; Clear system state
    call smsspec.runner.clearSystemState
.endm

/**
 * Stores text in the ROM and adds a pointer to it at the given
 * RAM location
 */
.macro "smsspec.runner.storeText" args text, ram_pointer
    jr +
    _text\@:
        .asc text
        .db $ff    ; terminator byte
    +:

    ld hl, ram_pointer
    ld (hl), <_text\@
    inc hl
    ld (hl), >_text\@
.endm
