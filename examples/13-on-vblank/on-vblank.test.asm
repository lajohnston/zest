describe "zest.onVBlank"
    it "calls the onVBlank callback when VBlank occurs"
        zest.onVBlank, +
            inc a
            ret
        +:

        ld a, 1
        halt
        expect.a.toBe 2

    it "is reset before the next test"
        ld a, 0
        halt
        expect.a.toBe 0
