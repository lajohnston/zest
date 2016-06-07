/**
 * Can be used to describe the unit being tested
 * Stores a pointer to the description test which is used to
 * identify the test to the user if it fails
 */
.macro "describe" args unitName
    smsspec.storeText unitName, smsspec.current_describe_message_addr
.endm
