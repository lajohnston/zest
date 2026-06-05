describe "Describe block for the test you terminated"

test "some test that hangs"
    ; This test will hang. Press pause to terminate it manually
    di
    halt

test "some other test"
    zest.fail "This test should not have run"
