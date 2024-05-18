;====
; (Private) Prints the Test Failed heading
;====
.section "zest.assertion.printTestFailedHeading" free
    zest.assertion.printTestFailedHeading:
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
; Prints the test description
;
; @in   hl  pointer to the assertion message
;====
.section "zest.assertion.printTestDescription" free
    zest.assertion.printTestDescription:
        ; Initialise the console
        zest.console.initFailure

        ; Print test details
        call zest.assertion.printTestFailedHeading
        jp zest.test.printTestDescription   ; jp (then ret)
.ends

;====
; Writes newlines to the on-screen console to separate the test description
; from the assertion message
;====
.section "zest.assertion.printSeparator" free
    zest.assertion.printSeparator:
        push hl
            zest.console.newlines 3

            ; Write separator line
            ld hl, zest.console.data.separatorText
            call zest.console.out

            zest.console.newlines 2
        pop hl
        ret
.ends

;====
; Prints the 'Expected:' label
;====
.section "zest.assertion.printExpectedLabel" free
    zest.assertion.printExpectedLabel:
        push hl
            zest.console.newlines 2
            ld hl, zest.console.data.expectedValueLabel
            call zest.console.out
        pop hl

        ret
.ends

;====
; Prints the 'Actual:' label
;====
.section "zest.assertion.printActualLabel" free
    zest.assertion.printActualLabel:
        push hl
            zest.console.newlines 1
            ld hl, zest.console.data.actualValueLabel
            call zest.console.out
        pop hl

        ret
.ends

;====
; Prints the message of the assertion that failed
;
; @in   hl  pointer to the message
;====
.section "zest.assertion.printMessage" free
    zest.assertion.printMessage:
        call zest.assertion.printSeparator

        ; Write message
        jp zest.console.out ; jp then ret
.ends

;====
; Displays details about a general expectation that hasn't been met
;
; @in   hl  pointer to the assertion message
;====
.section "zest.assertion.failed" free
    zest.assertion.failed:
        call zest.assertion.printTestDescription
        call zest.assertion.printMessage

        jp zest.console.displayAndStop
.ends
