;====
; Displays details about a boolean/flag assertion that doesn't match
; the expectation, then stops the program
;
; @in   a   the expected value (a 1 or a 0)
; @in   hl  pointer to the assertion message
;====
.section "zest.assertion.boolean.failed" free
    zest.assertion.boolean.failed:
        call zest.assertion.printTestDescription
        call zest.assertion.printMessage

        ; Print 'Expected:' label
        call zest.assertion.printExpectedLabel

        ; Print expected value
        call zest.console.outputBoolean

        ; Print 'Actual:' label
        call zest.assertion.printActualLabel

        ; Print actual value
        push af
            inc a           ; invert bit 0
            and %00000001   ; mask out other bits
            call zest.console.outputBoolean
        pop af

        jp zest.console.displayAndStop
.ends
