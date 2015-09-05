.macro "assertAccEquals" args expected
    cp expected

    jr z, +
        assertionFailed "Failed"
    +:
.endm
