.ramsection "zest.runner.current_test_info" slot 2
    zest.runner.current_describe_message_addr: dw
    zest.runner.current_test_message_addr: dw
.ends

;====
; Initialise the system and run the test suite
;====
.section "zest.runner.init" free
    zest.runner.init:
        ; Initialise VDP
        call zest.vdp.init
        call zest.vdp.clearVram

        ; Initialise console
        call zest.console.init
        call zest.vdp.enableDisplay

        ; Run the test suite (label defined by user)
        call zest.suite

        ; All tests passed. Display message
        call zest.console.prepWrite
            ld hl, zest.console.data.heading
            call zest.console.out
            call zest.console.newline
            call zest.console.newline

            ld hl, zest.console.data.allTestsPassed
            call zest.console.out
        call zest.console.finalise

        ; End
        -:
            halt
        jr -
.ends

;====
; Prints the Test Failed heading
;====
.section "zest.runner.printTestFailedHeading" free
    zest.runner.printTestFailedHeading:
        ; Write test failed message
        ld hl, zest.console.data.testFailedHeading
        call zest.console.out

        ; Separator
        call zest.console.newline
        call zest.console.newline
        ld hl, zest.console.data.separatorText
        call zest.console.out
        jp zest.console.newline ; jp then ret
.ends

;====
; Prints the current test's 'describe' and 'it' text
;====
.section "zest.runner.printTestDescription" free
    zest.runner.printTestDescription:
        ; Write describe block description
        call zest.console.newline
        ld hl, (zest.runner.current_describe_message_addr)
        call zest.console.out

        ; Write failing test
        call zest.console.newline
        call zest.console.newline
        ld hl, (zest.runner.current_test_message_addr)
        jp zest.console.out ; jp then ret
.ends

;====
; Prints the message of the assertion that failed
; @in   hl  pointer to the message
;====
.section "zest.runner.printAssertionMessage" free
    zest.runner.printAssertionMessage:
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
; Prints 'Expected:' and the hex value of the expected value
; @in   b   the expected value
;====
.section "zest.runner.printExpectedValue" free
    zest.runner.printExpectedValue:
        ; Print 'Expected:'
        call zest.console.newline
        call zest.console.newline
        ld hl, zest.console.data.expectedValueLabel
        call zest.console.out

        ; Print the expected value
        ld a, b ; set A to expected value
        jp zest.console.outputHexA  ; jp then ret
.ends

;====
; Prints 'Actual:' and the hex value of the actual value
; @in   a   the expected value
;====
.section "zest.runner.printActualValue" free
    zest.runner.printActualValue:
        push af
            call zest.console.newline
            ld hl, zest.console.data.actualValueLabel
            call zest.console.out
        pop af

        ; Print actual value in A
        jp zest.console.outputHexA  ; jp then ret
.ends

;====
; Prints details about the failing test and stops the program
;
; @in   a   the actual value
; @in   b   the expected value
; @in   hl  pointer to the assertion message
;====
.section "zest.runner.expectationFailed" free
    zest.runner.expectationFailed:
        push af ; preserve actual value
        push hl ; preserve assertion message

        ; Set console text color to red
        ld a, %00000011
        call zest.console.setTextColor   ; set to a

        call zest.console.prepWrite
            call zest.runner.printTestFailedHeading
            call zest.runner.printTestDescription

            pop hl  ; restore assertion message
            call zest.runner.printAssertionMessage

            ; Print expected value
            call zest.runner.printExpectedValue

            ; Print actual value
            pop af  ; restore actual value
            call zest.runner.printActualValue
        call zest.console.finalise

        ; Stop program
        -:
            halt
        jp -
.ends

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
; Initialises a new test.
; Resets the Z80 registers and stores the test description in case the test fails
;====
.macro "zest.runner.startTest" args message
    zest.runner.storeText message, zest.runner.current_test_message_addr

    ; Clear system state
    call zest.mock.initAll
    call zest.runner.clearRegisters

    ; Reset stack (base address minus return address from zest.suite)
    ld sp, $dfee
.endm

;====
; Stores text in the ROM and adds a pointer to it at the given
; RAM location
;====
.macro "zest.runner.storeText" args text, ram_pointer
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
