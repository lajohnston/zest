describe "address assertions"
    test "expect.address.toContain"
        jr +
            ; Test data
            -:
            .db $01
            .db $02
            .db $03
        +:

        zest.initRegisters
        expect.address.toContain -, $01, $02, $03
        expect.all.toBeUnclobbered
