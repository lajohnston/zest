;====
; Constants
;====
.define zest.runner.TEST_IN_PROGRESS_BIT 0
.define zest.runner.TEST_IN_PROGRESS_MASK %00000001

;====
; RAM
;====
.ramsection "zest.runner" slot zest.mapper.RAM_SLOT
    ; The number of tests that have passed
    zest.runner.tests_passed: dw

    ; Flags
    ; Bit 0 = set if a test is in progress
    zest.runner.flags:  db
.ends

;====
; Initialises the system and runs the test suite
;====
.section "zest.runner.init" free
    zest.runner.init:
        ; Initialise VDP
        call zest.vdp.init
        call zest.vdp.clearVram

        ; Reset test counter
        xor a
        ld (zest.runner.tests_passed), a
        ld (zest.runner.tests_passed + 1), a

        ; Reset flags
        ld (zest.runner.flags), a

        ; Run the test suite
        jp zest.suite
.ends

;====
; Finishes the test run. Displays either a success message, or a warning
; message if no tests were run
;====
.section "zest.runner.finish" free
    zest.runner.finish:
        ; Perform postTest checks for the last test
        call zest.runner.postTest

        ; Check how many tests ran
        ld hl, (zest.runner.tests_passed)
        ld a, h
        or l
        jr z, _noTestsFound ; jp if no tests were run

        ; Otherwise display success message
        zest.console.initSuccess
        ld hl, zest.console.data.heading
        call zest.console.out
        zest.console.newlines 2

        ld hl, zest.console.data.allTestsPassed
        call zest.console.out
        jp zest.console.displayAndStop

    _noTestsFound:
        zest.console.initWarning

        ld hl, zest.console.data.heading
        call zest.console.out
        zest.console.newlines 2

        ld hl, zest.console.data.noTestsFound
        call zest.console.out
        jp zest.console.displayAndStop
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
        jp zest.console.displayAndStop
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
        jp zest.console.displayAndStop
.ends

;====
; Displays details about a boolean/flag assertion that doesn't match
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

        jp zest.console.displayAndStop
.ends

;====
; Displays details about a general expectation that hasn't been met
;
; @in   hl  pointer to the assertion message
;====
.section "zest.runner.expectationFailed" free
    zest.runner.expectationFailed:
        call zest.runner._printTestFailure
        jp zest.console.displayAndStop
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
            zest.console.newlines 2
            ld hl, zest.console.data.separatorText
            call zest.console.out
            zest.console.newlines 2
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
        push hl
            zest.console.newlines 3

            ; Write assertion message
            ld hl, zest.console.data.separatorText
            call zest.console.out

            zest.console.newlines 2
        pop hl

        jp zest.console.out ; jp then ret
.ends

;====
; (Private) Prints the 'Expected:' label
;====
.section "zest.runner._printExpectedLabel" free
    zest.runner._printExpectedLabel:
        push hl
            zest.console.newlines 2
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
        push hl
            zest.console.newlines 1
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
        jp zest.console.displayAndStop

    _printTestDescription:
        ; Initialise failure heading
        zest.console.initFailure
        call zest.runner._printTestFailedHeading

        ; Print the test description
        call zest.test.printTestDescription

        ; Print the RAM overwritten message
        ld hl, _memoryCorruptionMessage
        call zest.runner._printAssertionMessage
        jp zest.console.displayAndStop

    _memoryCorruptionMessage:
        zest.console.defineString "   Zest RAM state overwritten"
.ends

;====
; Prepares the start of a new test
;
; @in   hl  pointer to the test description
;====
.section "zest.runner.preTest" free
    zest.runner.preTest:
        zest.test.setTestDescription

        ; Update checksum + VRAM backup
        zest.test.preTest

        ; Reset mocks
        zest.mock.initAll

        ; Reset timeout counter
        zest.timeout.reset

        ; Set test in progress flag
        ld a, (zest.runner.flags)
        or zest.runner.TEST_IN_PROGRESS_MASK
        ld (zest.runner.flags), a

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
        ; Ensure interrupts are disabled
        di

        ; If no test is in progress, return
        ld a, (zest.runner.flags)
        bit zest.runner.TEST_IN_PROGRESS_BIT, a
        ret z   ; return if a test isn't in progress

        ; Reset the test in progress flag
        and (zest.runner.TEST_IN_PROGRESS_MASK ~ $ff)   ; reset the bit
        ld (zest.runner.flags), a                       ; store

        ; Increment tests passed
        ld hl, (zest.runner.tests_passed)
        inc hl
        ld (zest.runner.tests_passed), hl

        ; Set Z if checksum is valid
        zest.test.validateChecksum
        ret z   ; return if the checksum is valid

        ; Checksum is invalid
        jp zest.runner.memoryOverwriteDetected
.ends

;====
; Starts a new block of tests
;
; @in   message     pointer to the message string
;====
.macro "zest.runner.startDescribeBlock" args message
    call zest.runner.postTest
    zest.test.setBlockDescription message
.endm

;====
; Initialises a new test
;
; @in   message     pointer to the message string
;====
.macro "zest.runner.startTest" args message
    ; Run postTest checks for previous test (if any)
    call zest.runner.postTest

    ; Define test description in ROM
    zest.test.defineTestDescription message
    call zest.preTest

    ; Reset stack
    ld sp, $dff0
.endm
