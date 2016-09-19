.macro "assertAccEquals" args expected
    cp expected

    jr z, +
        smsspec.runner.assertionFailed "Failed"
    +:
.endm
