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

    test "expect.hl.toPointToWord"
        jr +
            -:
            .dw $1234
        +:

        zest.initRegisters

        ld hl, -
        expect.hl.toPointToWord $1234
