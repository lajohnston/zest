;====
; Constants
;====
.define zest.runner.TEST_IN_PROGRESS_BIT 0
.define zest.runner.TEST_IN_PROGRESS_MASK %00000001

; Default pointer minus 2 for zest.suite call
.define zest.runner.DEFAULT_STACK_POINTER $dff0 - 2

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

        ; Run the test suites
        zest.suites.run

        ; Finish tests (all tests passed)
        jp zest.runner.finish
.ends

;====
; Finishes the test run. Displays either a success message, or a warning
; message if no tests were run
;====
.section "zest.runner.finish" free
    zest.runner.finish:
        ; Perform postTest checks for the last test
        call zest.postTest

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
        call zest.runner._printTestDescription
        call zest.runner._printAssertionMessage

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
; @in   de  the actual value
; @in   ix  pointer to the assertion.Word instance, containing the expected
;           value and assertion message
;====
.section "zest.runner.wordExpectationFailed" free
    zest.runner.wordExpectationFailed:
        call zest.runner._printTestDescription

        ; Print assertion message
        call zest.wordAssertion.printMessage

        ; Print expected label
        call zest.runner._printExpectedLabel

        ; Print expected value
        call zest.wordAssertion.printExpected

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
        call zest.runner._printTestDescription
        call zest.runner._printAssertionMessage

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
        call zest.runner._printTestDescription
        call zest.runner._printAssertionMessage

        jp zest.console.displayAndStop
.ends

;====
; (Private) Prints the test description
;
; @in   hl  pointer to the assertion message
;====
.section "zest.runner._printTestDescription" free
    zest.runner._printTestDescription:
        ; Initialise the console
        zest.console.initFailure

        ; Print test details
        call zest.runner._printTestFailedHeading
        jp zest.test.printTestDescription   ; jp (then ret)
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
        ld sp, zest.runner.DEFAULT_STACK_POINTER

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
; Starts a new block of tests
;
; @in   message     pointer to the message string
;====
.macro "zest.runner.startDescribeBlock" args message
    call zest.postTest
    zest.test.setBlockDescription message
.endm

;====
; Initialises a new test
;
; @in   message     pointer to the message string
;====
.macro "zest.runner.startTest" args message
    ; Run postTest checks for previous test (if any)
    call zest.postTest

    ; Define test description in ROM
    zest.test.defineTestDescription message
    call zest.preTest

    ; Reset stack
    ld sp, zest.runner.DEFAULT_STACK_POINTER
.endm

;====
; Fails the current test with the given message
;
; @in   [message]   optional message
;====
.macro "zest.runner.fail" args message
    .if \?1 == ARG_STRING
        jr +
            \.\@:
                zest.console.defineString message
        +:

        ld hl, \.\@
    .else
        ld hl, zest.console.data.zestFailDefaultMessage
    .endif

    call zest.runner.expectationFailed
.endm
