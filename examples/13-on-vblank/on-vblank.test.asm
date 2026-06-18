describe "zest.vblank.start"
    it "calls the zest.vblank.start callback when VBlank occurs"
        zest.vblank.start
            inc a
        zest.vblank.end

        ld a, 1
        halt
        expect.a.toBe 2

    it "is reset before the next test"
        ld a, 0
        halt
        expect.a.toBe 0
