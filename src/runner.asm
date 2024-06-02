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
        call zest.assertion.printTestFailedHeading

        ; Display RAM overwritten error
        ld hl, _memoryCorruptionMessage
        call zest.console.out
        jp zest.console.displayAndStop

    _printTestDescription:
        ; Initialise failure heading
        zest.console.initFailure
        call zest.assertion.printTestFailedHeading

        ; Print the test description
        call zest.test.printTestDescription

        ; Print the RAM overwritten message
        ld hl, _memoryCorruptionMessage
        call zest.assertion.printMessage
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
    call zest.preTest
    .db message.length + 2 ; message length + size byte + null terminator byte
    zest.console.defineString message

    test_\@:
.endm

;====
; Fails the current test with the given message
;
; @in   [message]   optional message
;====
.macro "zest.runner.fail" isolated args message
    .if \?1 == ARG_STRING
        jr +
            \.\@:
                zest.console.defineString message
        +:

        ld hl, \.\@
    .else
        ld hl, zest.console.data.zestFailDefaultMessage
    .endif

    call zest.assertion.failed
.endm
