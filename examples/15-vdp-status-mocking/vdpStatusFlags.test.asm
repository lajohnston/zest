describe "waitForVBlank"
    it "returns when the VBlank flag is set"
        zest.mockVdpStatusFlags zest.VDP_NO_STATUS_FLAGS

        zest.vblank.start
            zest.mockVdpStatusFlags zest.VDP_VBLANK_STATUS
        zest.vblank.end

        call waitForVBlank

describe "ifOverflow"
    it "jumps to the given label if the sprite overflow flag isn't set"
        ; Other flags set, but not overflow flag
        zest.mockVdpStatusFlags zest.VDP_VBLANK_STATUS|zest.VDP_SPRITE_COLLISION_STATUS

        ifOverflow +
            zest.fail "should have jumped"
        +:

    it "continues if the sprite overflow flag is set"
        zest.mockVdpStatusFlags zest.VDP_SPRITE_OVERFLOW_STATUS
        ifOverflow +
            jp ++
        +:

        zest.fail "should not have jumped to else"

        ++

describe "ifCollision"
    it "jumps to the given label if the sprite collision flag isn't set"
        ; Other flags set, but not collision flag
        zest.mockVdpStatusFlags zest.VDP_VBLANK_STATUS|zest.VDP_SPRITE_OVERFLOW_STATUS

        ifCollision +
            zest.fail "should have jumped"
        +:

    it "continues if the sprite collision flag is set"
        zest.mockVdpStatusFlags zest.VDP_SPRITE_COLLISION_STATUS
        ifCollision +
            jp ++
        +:

        zest.fail "should not have jumped to else"

        ++