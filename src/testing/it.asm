/**
 * Specified a new test with a description.
 * Resets the Z80 registers ready for the new test
 */
.macro "it" args message
    smsspec.storeText message, smsspec.current_test_message_addr

    ; Clear system state
    call smsspec.clearSystemState
.endm
