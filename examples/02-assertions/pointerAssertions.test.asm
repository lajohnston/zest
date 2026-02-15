describe "pointerAssertions"
    test "expect.hl.toPointToByte"
        jr +
            -:
            .db 100
        +:

        zest.initRegisters

        ld hl, -
        expect.hl.toPointToByte 100

        expect.all.toBeUnclobberedExcept "hl"

