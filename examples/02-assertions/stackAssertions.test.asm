describe "expect.stack.toContain"
    test "passes when sp points to the given value"
        ld bc, $1234
        push bc
        expect.stack.toContain $1234
        pop bc

    test "does not clobber the stack or registers"
        ; Push value to stack
        ld bc, $1234
        push bc

        ; Initialise registers
        zest.initRegisters

        ; Assert twice, to ensure the stack value doesn't get overwritten
        expect.stack.toContain $1234
        expect.stack.toContain $1234 0 "Expected stack to be unchanged"

        ; Expect all registers to be unclobbered
        expect.all.toBeUnclobbered

describe "expect.stack.toContain with offset"
    it "should pick the value from x stack positions back"
        ld bc, $0002
        push bc
        ld bc, $0001
        push bc
        ld bc, $0000
        push bc

        expect.stack.toContain $0002 2
        expect.stack.toContain $0001 1
        expect.stack.toContain $0000 0

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
        ; Initialise registers
        zest.initRegisters

        ; Call assertion
        expect.stack.size.toBe 0

        ; Assert the register values haven't changed
        expect.all.toBeUnclobbered

    test "does not clobber the stack"
        ld bc, $1234
        push bc
        expect.stack.size.toBe 1
        expect.stack.toContain $1234
        pop bc
