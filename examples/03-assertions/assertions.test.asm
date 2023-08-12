describe "Assertions"
    test "expect.r.toBe"
        ld a, 1
        ld b, 2
        ld c, 3
        ld d, 4
        ld e, 5
        ld h, 6
        ld l, 7

        ld ixh, 8
        ld ixl, 9

        ld iyh, 10
        ld iyl, 11

        ld i, a

        expect.a.toBe 1
        expect.b.toBe 2
        expect.c.toBe 3
        expect.d.toBe 4
        expect.e.toBe 5
        expect.h.toBe 6
        expect.l.toBe 7

        expect.ixh.toBe 8
        expect.ixl.toBe 9

        expect.iyh.toBe 10
        expect.iyl.toBe 11

        expect.i.toBe 1

    test "expect.carry.toBe 0 passes when carry flag is reset"
        scf ; set carry flag
        ccf ; invert carry flag to off
        expect.carry.toBe 0

    test "expect.carry.toBe 1 passes when carry flag is set"
        scf ; set carry flag
        expect.carry.toBe 1
