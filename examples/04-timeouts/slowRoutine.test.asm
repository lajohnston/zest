describe "Some slow routine"

it "should not timeout"
    ; Uncomment this to increase the timeout for this test and make it pass
    ; zest.setTimeout 20

    ; Call the routine we're testing
    call slowRoutine
