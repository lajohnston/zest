.ramsection "smsspec.runner.current_test_info" slot 2
    smsspec.runner.current_describe_message_addr: dw
    smsspec.runner.current_test_message_addr: dw
.ends

;====
; Initialise the system and run the test suite
;====
.section "smsspec.runner.init" free
    smsspec.runner.init:
        ; Initialise VDP
        call smsspec.vdp.init
        call smsspec.vdp.clearVram

        ; Initialise console
        call smsspec.console.init
        call smsspec.vdp.enableDisplay

        ; Run the test suite (label defined by user)
        call smsspec.suite

        ; All tests passed. Display message
        call smsspec.console.prepWrite
            ld hl, smsspec.console.data.heading
            call smsspec.console.out
            call smsspec.console.newline
            call smsspec.console.newline

            ld hl, smsspec.console.data.allTestsPassed
            call smsspec.console.out
        call smsspec.console.finalise

        ; End
        -:
            halt
        jr -
.ends

;====
; Prints the Test Failed heading
;====
.macro "smsspec.runner.printTestFailedHeading"
    ; Write test failed message
    ld hl, smsspec.console.data.testFailedHeading
    call smsspec.console.out

    ; Separator
    call smsspec.console.newline
    call smsspec.console.newline
    ld hl, smsspec.console.data.separatorText
    call smsspec.console.out
    call smsspec.console.newline
.endm

;====
; Prints the current test's 'describe' and 'it' text
;====
.macro "smsspec.runner.printTestDescription"
    ; Write describe block description
    call smsspec.console.newline
    ld hl, (smsspec.runner.current_describe_message_addr)
    call smsspec.console.out

    ; Write failing test
    call smsspec.console.newline
    call smsspec.console.newline
    ld hl, (smsspec.runner.current_test_message_addr)
    call smsspec.console.out
.endm

;====
; Prints the message of the assertion that failed
; @in   stack{0}    the message
;====
.macro "smsspec.runner.printAssertionMessage"
    ; Write assertion message
    call smsspec.console.newline
    call smsspec.console.newline
    call smsspec.console.newline
    ld hl, smsspec.console.data.separatorText
    call smsspec.console.out

    call smsspec.console.newline
    call smsspec.console.newline

    pop hl  ; restore assertion message
    call smsspec.console.out
.endm

;====
; Prints 'Expected:' and the hex value of the expected value
; @in   b   the expected value
;====
.macro "smsspec.runner.printExpectedValue"
    ; Print 'Expected:'
    call smsspec.console.newline
    call smsspec.console.newline
    ld hl, smsspec.console.data.expectedValueLabel
    call smsspec.console.out

    ; Print the expected value
    ld a, b ; set A to expected value
    call smsspec.console.outputHexA
.endm

;====
; Prints 'Actual:' and the hex value of the actual value
; @in   a   the expected value
;====
.macro "smsspec.runner.printActualValue"
    push af
        call smsspec.console.newline
        ld hl, smsspec.console.data.actualValueLabel
        call smsspec.console.out
    pop af

    ; Print actual value in A
    call smsspec.console.outputHexA
.endm

;====
; Prints details about the failing test and stops the program
;
; @in   a   the actual value
; @in   b   the expected value
; @in   hl  pointer to the assertion message
;====
.section "smsspec.runner.expectationFailed" free
    smsspec.runner.expectationFailed:
        push af ; preserve actual value
        push hl ; preserve assertion message

        ; Set console text color to red
        ld a, %00000011
        call smsspec.console.setTextColor   ; set to a

        call smsspec.console.prepWrite
            smsspec.runner.printTestFailedHeading
            smsspec.runner.printTestDescription

            smsspec.runner.printAssertionMessage
            smsspec.runner.printExpectedValue

            pop af  ; restore actual value
            smsspec.runner.printActualValue
        call smsspec.console.finalise

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
