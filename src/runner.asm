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

        call zest.vdp.enableDisplay

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
        jp zest.runner._showMessage ; jp (then ret)
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

        jp zest.runner._showMessage ; jp (then ret)
.ends

;====
; (Private) Prints the test failed heading, test description, and assertion
; message
;
; @in   hl  pointer to the assertion message
;====
.section "zest.runner._printTestFailure" free
    zest.runner._printTestFailure:
        ; Set console text color to red
        push af
            ld a, %00000011 ; red
            call zest.console.setTextColor
        pop af

        ; Prep write to console
        call zest.console.prepWrite

        ; Print test details
        call zest.runner._printTestFailedHeading
        call zest.runner._printTestDescription

        ; Print the failed assertion message
        jp zest.runner._printAssertionMessage   ; jp (then ret)
.ends

;====
; (Private) Enables the display to show the message and stops the runner
;====
.section "zest.runner._showMessage" free
    zest.runner._showMessage:
        call zest.vdp.enableDisplay

        ; Stop program
        -:
            halt
        jp -
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

        jp zest.console.newline ; jp then ret
.ends

;====
; (Private) Prints the current test's 'describe' and 'it' text
;====
.section "zest.runner._printTestDescription" free
    zest.runner._printTestDescription:
        push hl
            ; Write describe block description
            call zest.console.newline
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
