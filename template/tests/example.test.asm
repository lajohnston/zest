describe "inc a"
    test "increments the value in register A"
        ld a, 1
        inc a
        expect.a.toBe 2
