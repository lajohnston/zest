.section "smsspec.testing.assertionFailedSection" free
    smsspec.testing.assertionFailedLabel:

        ;ld hl, (smsspec.current_describe_message_addr)
        call smsspec.console.out

        ;smsspec.current_test_message_addr: dw

        ; Stop program
        -: jp -
.ends

.macro "smsspec.testing.assertionFailed" args message, actual
    jp smsspec.testing.assertionFailedLabel
.endm
