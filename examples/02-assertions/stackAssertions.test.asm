describe "expect.stack.toContain"
    test "passes when sp points to the given value"
        ld bc, $1234
        push bc
        expect.stack.toContain $1234
        pop bc

    test "does not clobber the stack or registers"
        ld bc, $1234
        push bc

        ld a, 0
        ld bc, 0
        ld de, 0
        ld hl, 0
        scf

        expect.stack.toContain $1234
        expect.stack.toContain $1234

        expect.a.toBe 0
        expect.carry.toBe 1

        expect.b.toBe 0
        expect.de.toBe 0
        expect.hl.toBe 0

        pop bc

describe "expect.stack.toContain with offset"
    it "should pick the value from x stack positions back"
        ld bc, $1234
        push bc
        ld bc, $0000
        push bc

        expect.stack.toContain $1234 1

        pop bc
        pop bc

    test "does not clobber the stack or registers"
        ld bc, $1234
        push bc
        ld bc, $0000
        push bc

        ld a, 0
        ld de, 0
        ld hl, 0
        scf

        expect.stack.toContain $1234 1
        expect.stack.toContain $1234 1

        expect.a.toBe 0
        expect.carry.toBe 1

        expect.b.toBe 0
        expect.de.toBe 0
        expect.hl.toBe 0

        pop bc
        pop bc

describe "expect.stack.size.toBe"
    test "returns the number of words pushed to the stack"
        expect.stack.size.toBe 0
        push af
        expect.stack.size.toBe 1
        push af
        expect.stack.size.toBe 2

        pop af
        pop af

    test "does not clobber the registers"
        ld a, $12
        ld de, $34
        ld hl, $56
        scf ; set carry flag

        expect.stack.size.toBe 0
        expect.a.toBe $12
        expect.de.toBe $34
        expect.hl.toBe $56
        expect.carry.toBe 1

    test "does not clobber the stack"
        ld bc, $1234
        push bc
        expect.stack.size.toBe 1
        expect.stack.toContain $1234
        pop bc
