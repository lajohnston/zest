describe "Zest hooks"

test "first test"
    ; The preTestCounter should be the value initialised by the preSuite hook
    ; and incremented by 1 by the preTest hook
    ld a, (preTestCounter)
    expect.a.toBe startingValue + 1

    ; The postTestCounter should still be the value initialised by the
    ; preSuite hook
    ld a, (postTestCounter)
    expect.a.toBe startingValue

test "second test"
    ld a, (preTestCounter)
    expect.a.toBe startingValue + 2

    ; The postTestCounter should have run once and incremented the postTestCounter
    ld a, (postTestCounter)
    expect.a.toBe startingValue + 1

test "third test"
    ld a, (preTestCounter)
    expect.a.toBe startingValue + 3

    ld a, (postTestCounter)
    expect.a.toBe startingValue + 2
