describe "Some slow routine"

it "should not timeout if we've increased the default timeout"
    ; Increase the default timeout (to 20 frames) for this test only
    zest.setTimeout 20

    ; Call the routine we're testing
    call slowRoutine

it "will timeout if we haven't set a custom timeout"
    ; This test will have the default timeout of 10 frames
    call slowRoutine
