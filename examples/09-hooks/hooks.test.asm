describe "Zest hooks"

test "by the first test, preSuite and preTest have both run once"
    ; The preTestCounter should be the value initialised by the preSuite hook
    ; and incremented by 1 by the preTest hook
    ld a, (preTestCounter)
    expect.a.toBe startingValue + 1

    ; The postTestCounter should still be the value initialised by the
    ; preSuite hook
    ld a, (postTestCounter)
    expect.a.toBe startingValue

test "by the second test, preTest has run twice and postTest has run once"
    ld a, (preTestCounter)
    expect.a.toBe startingValue + 2

    ; The postTestCounter should have run once and incremented the postTestCounter
    ld a, (postTestCounter)
    expect.a.toBe startingValue + 1

test "by the third test, preTest has run three times and postTest has run twice"
    ld a, (preTestCounter)
    expect.a.toBe startingValue + 3

    ld a, (postTestCounter)
    expect.a.toBe startingValue + 2
