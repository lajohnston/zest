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
