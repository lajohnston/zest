describe "pointerAssertions"
    test "expect.hl.toPointTo"
        jr +
            -:
            .db 100
        +:

        zest.initRegisters

        ld hl, -
        expect.hl.toPointTo 100

        expect.all.toBeUnclobberedExcept "hl"

