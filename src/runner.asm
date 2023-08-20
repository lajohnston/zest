.ramsection "zest.runner.current_test_info" slot zest.mapper.RAM_SLOT
    zest.runner.current_describe_message_addr: dw
    zest.runner.current_test_message_addr: dw
    zest.runner.timeout_frames: db
.ends

;====
; Initialise the system and run the test suite
;====
.section "zest.runner.init" free
    zest.runner.init:
        ; Initialise VDP
        call zest.vdp.init
        call zest.vdp.clearVram

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
; Prepares the start of a new test
;====
.section "zest.runner.preTest" free
    zest.runner.preTest:
        ; Reset mocks
        call zest.mock.initAll

        ; Set timeout (default + 1 frame for the frame we're on)
        ld a, <(zest.defaultTimeout + 1)    ; wrap to 0 for 256 frames
        ld (zest.runner.timeout_frames), a

        ; Disable display and enable VBlank interrupts
        in a, (zest.vdp.STATUS_PORT)    ; clear pending interrupts
        zest.vdp.setRegister1 %10100000 ; enable VBlank interrupts
        ei                              ; enable CPU interrupts

        ; Clear registers
        jp zest.runner.clearRegisters   ; jp/ret
.ends

;====
; Initialises a new test.
; Resets the Z80 registers and stores the test description in case the test fails
;====
.macro "zest.runner.startTest" args message
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

;====
; Set the timeout for the current test
;
; @in frames    the number of full frames to time out after
;====
.macro "zest.runner.setTestTimeout" args frames
    push af
        ld a, <(frames + 1) ; frames + current frame (wrap to 0 for 256)
        ld (zest.runner.timeout_frames), a
    pop af
.endm

;====
; Decrement the frame counter for the current test and timeout the test with a
; message if the counter reaches zero
;
; @clobs a
;====
.section "zest.runner.updateTimeoutCounter" free
    zest.runner.updateTimeoutCounter:
        ld a, (zest.runner.timeout_frames)
        dec a
        ld (zest.runner.timeout_frames), a
        ret nz  ; return if test hasn't timed out yet

        ; Timeout
        push hl
            ld hl, _timeoutMessage
            call zest.runner._printTestFailure
            call zest.console.displayMessage
        pop hl

        ret

    _timeoutMessage:
        .asc "Test timed out"
        .db $ff
.ends
