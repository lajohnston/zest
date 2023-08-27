.ramsection "zest.runner" slot zest.mapper.RAM_SLOT
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
        call zest.test.printTestDescription

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
; Recovers from a memory corruption and displays a test failure message
;====
.section "zest.runner.memoryOverwriteDetected" free
    zest.runner.memoryOverwriteDetected:
        ; Reset stack pointer, in case it's invalid
        ld sp, $dff0

        ; Ensure the test description data hasn't been overwritten
        call zest.test.ensureDescriptionIsValid
        jp z, _printTestDescription     ; print if valid

        ; Description has been overwritten - display generic message
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
        call zest.test.printTestDescription

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
; Prepares the start of a new test
;====
.section "zest.runner.preTest" free
    zest.runner.preTest:
        ; Ensure interrupts are disabled
        di

        ; Update checksum + VRAM backup
        zest.test.preTest

        ; Reset mocks
        call zest.mock.initAll

        ; Reset timeout counter
        zest.timeout.reset

        ; Disable display and enable VBlank interrupts
        in a, (zest.vdp.STATUS_PORT)    ; clear pending interrupts
        zest.vdp.setRegister1 %10100000 ; enable VBlank interrupts
        ei                              ; enable CPU interrupts

        ret
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
        zest.test.validateChecksum
        ret z   ; return if the checksum is valid

        ; Checksum is invalid
        jp zest.runner.memoryOverwriteDetected
.ends

;====
; Initialises a new test.
; Resets the Z80 registers and stores the test description in case the test fails
;====
.macro "zest.runner.startTest" args message
    call zest.runner.postTest
    zest.test.setTestDescription message
    call zest.runner.preTest

    ; Reset stack (base address minus return address from zest.suite)
    ld sp, $dfee
.endm
