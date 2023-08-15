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

    test "expect.bc.toBe passes when BC matches the expected value"
        ld bc, $1234
        expect.bc.toBe $1234

    test "expect.de.toBe passes when DE matches the expected value"
        ld de, $1234
        expect.de.toBe $1234

    test "expect.hl.toBe passes when HL matches the expected value"
        ld hl, $1234
        expect.hl.toBe $1234

    test "expect.ix.toBe passes when IX matches the expected value"
        ld ix, $1234
        expect.ix.toBe $1234

    test "expect.carry.toBe 0 passes when carry flag is reset"
        scf ; set carry flag
        ccf ; invert carry flag to off
        expect.carry.toBe 0

    test "expect.carry.toBe 1 passes when carry flag is set"
        scf ; set carry flag
        expect.carry.toBe 1

    test "expect.parityOverflow.toBe 0 passes when the parity/overflow flag is reset (parity check)"
        ld a, %00000001 ; 1 bit set (uneven)
        or a            ; update flags
        expect.parityOverflow.toBe 0

    test "expect.parityOverflow.toBe 1 passes when the parity/overflow flag is set (parity check)"
        ld a, %00000101 ; 2 bits set (even)
        or a            ; update flags
        expect.parityOverflow.toBe 1

    test "expect.parityOverflow.toBe 0 passes when the parity/overflow flag is reset (addition check)"
        ld a, 128
        add 127     ; 255
        expect.parityOverflow.toBe 0

    test "expect.parityOverflow.toBe 1 passes when the parity/overflow flag is reset (addition check)"
        ld a, 128
        add 128     ; 256 - overflow
        expect.parityOverflow.toBe 1

    test "expect.sign.toBe 0 passes when the sign flag is reset"
        ld a, %01111111 ; 7th bit reset
        or a            ; update flags
        expect.sign.toBe 0

    test "expect.sign.toBe 1 passes when the sign flag is reset"
        ld a, %10000000 ; 7th bit set
        or a            ; update flags
        expect.sign.toBe 1

    test "expect.zeroFlag.toBe 0 passes when the zero flag is reset"
        ld a, 1
        or a    ; update flags
        expect.zeroFlag.toBe 0

    test "expect.zeroFlag.toBe 1 passes when the zero flag is set"
        xor a   ; set A to zero and update flags
        expect.zeroFlag.toBe 1