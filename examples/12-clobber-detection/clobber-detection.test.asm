describe "expect.all.toBeUnclobbered"
    test "passes when no registers have been clobbered"
        zest.initRegisters
        expect.all.toBeUnclobbered

    ; test "detects when registers have been clobbered"
    ;     zest.initRegisters
    ;     neg ; negate A
    ;     expect.all.toBeUnclobbered

describe "expect.all.toBeUnclobberedExcept should pass if the register is on the ignore list"
    test "register A"
        zest.initRegisters
        ld a, b
        expect.all.toBeUnclobberedExcept "a"

    test "register F"
        zest.initRegisters
        or a    ; clobber flags
        expect.all.toBeUnclobberedExcept "f"

    test "register B"
        zest.initRegisters
        ld b, a
        expect.all.toBeUnclobberedExcept "b"

    test "register C"
        zest.initRegisters
        ld c, a
        expect.all.toBeUnclobberedExcept "c"

    test "register D"
        zest.initRegisters
        ld d, a
        expect.all.toBeUnclobberedExcept "d"

    test "register E"
        zest.initRegisters
        ld e, a
        expect.all.toBeUnclobberedExcept "e"

    test "register H"
        zest.initRegisters
        ld h, a
        expect.all.toBeUnclobberedExcept "h"

    test "register L"
        zest.initRegisters
        ld l, a
        expect.all.toBeUnclobberedExcept "l"

    test "register IXH"
        zest.initRegisters
        ld ixh, a
        expect.all.toBeUnclobberedExcept "ixh"

    test "register IXL"
        zest.initRegisters
        ld ixl, a
        expect.all.toBeUnclobberedExcept "ixl"

    test "register IYH"
        zest.initRegisters
        ld iyh, a
        expect.all.toBeUnclobberedExcept "iyh"

    test "register IYL"
        zest.initRegisters
        ld iyl, a
        expect.all.toBeUnclobberedExcept "iyl"

    test "register I"
        zest.initRegisters
        ld i, a
        expect.all.toBeUnclobberedExcept "i"

    test "register A'"
        zest.initRegisters
        ex af, af'
        ld a, b
        ex af, af'

        expect.all.toBeUnclobberedExcept "a'"

    test "register F'"
        zest.initRegisters
        ex af, af'
        or a
        ex af, af'
        expect.all.toBeUnclobberedExcept "f'"

    test "register B'"
        zest.initRegisters
        exx
        ld b, a
        exx
        expect.all.toBeUnclobberedExcept "b'"

    test "register C'"
        zest.initRegisters
        exx
        ld c, a
        exx
        expect.all.toBeUnclobberedExcept "c'"

    test "register D'"
        zest.initRegisters
        exx
        ld d, a
        exx
        expect.all.toBeUnclobberedExcept "d'"

    test "register E'"
        zest.initRegisters
        exx
        ld e, a
        exx
        expect.all.toBeUnclobberedExcept "e'"

    test "register H'"
        zest.initRegisters
        exx
        ld h, a
        exx
        expect.all.toBeUnclobberedExcept "h'"

    test "register L'"
        zest.initRegisters
        exx
        ld l, a
        exx
        expect.all.toBeUnclobberedExcept "l'"

    test "registers AF"
        zest.initRegisters
        inc a
        or a
        expect.all.toBeUnclobberedExcept "af"

    test "registers BC"
        zest.initRegisters
        ld b, a
        ld c, a
        expect.all.toBeUnclobberedExcept "bc"

    test "registers DE"
        zest.initRegisters
        ld d, a
        ld e, a
        expect.all.toBeUnclobberedExcept "de"

    test "registers HL"
        zest.initRegisters
        ld h, a
        ld l, a
        expect.all.toBeUnclobberedExcept "hl"

    test "registers IX"
        zest.initRegisters
        ld ixh, a
        ld ixl, a
        expect.all.toBeUnclobberedExcept "ix"

    test "registers IY"
        zest.initRegisters
        ld iyh, a
        ld iyl, a
        expect.all.toBeUnclobberedExcept "iy"

    test "registers AF'"
        zest.initRegisters
        ex af, af'
            inc a
            or a
        ex af, af'
        expect.all.toBeUnclobberedExcept "af'"

    test "registers BC'"
        zest.initRegisters
        exx
            ld b, a
            ld c, a
        exx
        expect.all.toBeUnclobberedExcept "bc'"

    test "registers DE'"
        zest.initRegisters
        exx
            ld d, a
            ld e, a
        exx
        expect.all.toBeUnclobberedExcept "de'"

    test "registers HL'"
        zest.initRegisters
        exx
            ld h, a
            ld l, a
        exx
        expect.all.toBeUnclobberedExcept "hl'"

    test "multiple registers"
        zest.initRegisters
        ld b, a
        ld c, a
        ld d, a
        ld e, a
        expect.all.toBeUnclobberedExcept "b", "c", "d", "e"
