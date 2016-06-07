.section "smsspec.testing.assertionFailedSection" free
    smsspec.testing.assertionFailed:
        ld hl, (smsspec.current_describe_message_addr)
        call smsspec.console.out

        call smsspec.console.newline
        call smsspec.console.newline

        ld hl, (smsspec.current_test_message_addr)
        call smsspec.console.out

        ;smsspec.current_test_message_addr: dw

        ; Stop program
        -: jp -
.ends

.macro "assertionFailed" args message, actual
    jp smsspec.testing.assertionFailed
.endm
