;====
; Constants
;====
.define zest.runner._TEST_IN_PROGRESS_BIT 0
.define zest.runner._TEST_IN_PROGRESS_MASK %00000001
.define zest.runner._VBLANK_MASK %00000010

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
        zest.vblank.resetCallback

        ; Initialise VDP
        call zest.vdp.init

        ; Set background colour to black
        ld hl, zest.vdp.CRAM_WRITE  ; palette index 0
        call zest.vdp.setAddress
        xor a                       ; 0 = black
        out (zest.vdp.DATA_PORT), a

        ; Reset test counter
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
; Indicates if a test is currently in progress
;
; @out      z   1 (nz) if test is in progress, otherwise 0 (z)
; @clobbers a
;====
.macro "zest.runner.cpTestInProgress"
    ld a, (zest.runner.flags)
    and zest.runner._TEST_IN_PROGRESS_MASK
.endm

;====
; Sets or clears the test in progress flag
;
; @in       inProgress     1 to set the flag, 0 to clear it
;====
.macro "zest.runner.setTestInProgress" args inProgress
    ld a, (zest.runner.flags)

    .if inProgress == 1
        or zest.runner._TEST_IN_PROGRESS_MASK
    .else
        and ~zest.runner._TEST_IN_PROGRESS_MASK
    .endif

    ld (zest.runner.flags), a
.endm

;====
; Sets the VBlank flag
; @in       value 0 or 1
; @clobbers af
;====
.macro "zest.runner.setVBlankFlag" args value
    ld a, (zest.runner.flags)

    .if value == 1
        or zest.runner._VBLANK_MASK
    .else
        and ~zest.runner._VBLANK_MASK
    .endif

    ld (zest.runner.flags), a
.endm

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

;====
; Waits for the VBlank interrupt handler to next return
;====
.section "zest.runner.waitForVBlank" free
    zest.runner.waitForVBlank:
        push af
            in a, (zest.vdp.STATUS_PORT)    ; reset VDP flags
            zest.runner.setVBlankFlag 0     ; reset VBlank indicator
            ei

            -:
                halt
                ld a, (zest.runner.flags)
                and zest.runner._VBLANK_MASK
            jr z, - ; jump if not yet set
        pop af
        ret
.ends
