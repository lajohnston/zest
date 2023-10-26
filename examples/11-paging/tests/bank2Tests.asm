describe "tests in suite 2"
    test "someMoreCode has been allocated within bank 2"
        ld a, :someMoreCode ; get bank number
        expect.a.toBe 2

    test "someMoreCode load A with 2"
        call someMoreCode
        expect.a.toBe 2