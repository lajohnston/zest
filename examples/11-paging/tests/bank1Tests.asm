describe "tests in suite 1"
    test "someCode has been allocated within bank 0 (the default)"
        ld a, :someCode
        expect.a.toBe 0

    it "should load A with 1"
        call someCode
        expect.a.toBe 1