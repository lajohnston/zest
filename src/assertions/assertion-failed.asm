.macro "assertionFailed" args message, actual
    jp assertionFailed
.endm

.section "smsspec.onFailure" free
    assertionFailed:
        ld hl, (smsspec.current_describe_message_addr)
        call smsspec.console.out

        ld hl, (smsspec.current_describe_message_addr)
        call smsspec.console.out

        ld hl, (smsspec.current_describe_message_addr)
        call smsspec.console.out

        ld hl, (smsspec.current_describe_message_addr)
        call smsspec.console.out

        ld hl, (smsspec.current_describe_message_addr)
        call smsspec.console.out

        ld hl, (smsspec.current_describe_message_addr)
        call smsspec.console.out

        ;smsspec.current_test_message_addr: dw

        ; Stop program
        -: jp -
.ends
