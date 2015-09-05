/**
 * Can be used to describe the unit being tested
 * Stores a pointer to the description test which is used to
 * identify the test to the user if it fails
 */
.macro "describe" args unit_name
    smsspec.storeText unit_name, smsspec.current_describe_message_addr
.endm
