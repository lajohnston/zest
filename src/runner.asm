.ramsection "smsspec.runner.current_test_info" slot 2
    smsspec.runner.current_describe_message_addr: dw
    smsspec.runner.current_test_message_addr: dw
.ends

.section "smsspec.runner.expectationFailed" free
    smsspec.runner.expectationFailed:
        ; Set console text color to red
        ld a, %00000011
        call smsspec.console.setTextColor   ; set to a

        ; Write test failed message
        ld hl, smsspec.console.data.testFailed
        call smsspec.console.out

        ; Write describe block description
        call smsspec.console.newline
        call smsspec.console.newline
        ld hl, (smsspec.runner.current_describe_message_addr)
        call smsspec.console.out

        ; Write failing test
        call smsspec.console.newline
        call smsspec.console.newline
        ld hl, (smsspec.runner.current_test_message_addr)
        call smsspec.console.out

        ; Stop program
        -:
            halt
        jp -
.ends

.macro "smsspec.runner.expectationFailed" args message, actual
    jp smsspec.runner.expectationFailed
.endm

.macro "smsspec.runner.clearMainRegisters"
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

.section "smsspec.runner.clearRegisters" free
    smsspec.runner.clearRegisters:
        ; Clear main registers
        smsspec.runner.clearMainRegisters

        ; Clear shadow registers
        ex af, af'
        exx
        smsspec.runner.clearMainRegisters

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
.macro "describe" args unitName
    smsspec.runner.storeText unitName, smsspec.runner.current_describe_message_addr
.endm

;====
; Initialises a new test.
; Resets the Z80 registers and stores the test description in case the test fails
;====
.macro "it" args message
    smsspec.runner.storeText message, smsspec.runner.current_test_message_addr

    ; Clear system state
    call smsspec.mock.initAll
    call smsspec.runner.clearRegisters

    ; Reset stack (base address minus return address from smsspec.suite)
    ld sp, $dfee
.endm

;====
; Stores text in the ROM and adds a pointer to it at the given
; RAM location
;====
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
