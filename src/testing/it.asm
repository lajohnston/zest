/**
 * Initialises a new test.
 * Resets the Z80 registers and stores the test description in case the test fails
 */
.macro "it" args message
    smsspec.storeText message, smsspec.current_test_message_addr

    ; Clear system state
    call smsspec.clearSystemState
.endm
