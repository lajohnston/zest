describe "When a routine corrupts Zest's internal state"

test "Zest detects this and displays an error message"
    call corruptRoutine
