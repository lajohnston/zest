describe "increment.asm increment"
    it "should increment the value in register A"
        ; Set A to 1
        ld a, 1

        ; Call the routine we're testing
        call increment

        ; Expect A to now be 2
        expect.a.toBe 2
