describe "clobber detection"
    test "passes when no registers have been clobbered"
        zest.initRegisters
        expect.all.toBeUnclobbered

    test "detects when registers have been clobbered"
        zest.initRegisters
        neg ; negate A
        expect.all.toBeUnclobbered
