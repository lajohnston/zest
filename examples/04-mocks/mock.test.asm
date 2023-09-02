describe "Zest mock handlers"
    test "expect.mock.toHaveBeenCalled should pass if the given mock was called at least once"
        ; Call the mocks
        call someLabel
        call anotherLabel
        call anotherLabel

        ; These should now pass
        expect.mock.toHaveBeenCalled someLabel
        expect.mock.toHaveBeenCalled anotherLabel

    test "returning values from mock handlers"
        ; Start conditions
        ld a, 0
        ld hl, 0

        ; Create a handler that sets the values to something else
        zest.mock.start someLabel
            ld a, $ab
            ld hl, $abcd
        zest.mock.end

        ; Ensure the handler doesn't get called right away
        expect.a.toBe 0
        expect.hl.toBe 0

        ; Call the mock label
        call someLabel

        ; Assert that we now have the values the handler set
        expect.a.toBe $ab
        expect.hl.toBe $abcd

    test "register values get passed unchanged to the handler"
        ld a, $ab
        ld hl, $abcd

        zest.mock.start someLabel
            expect.a.toBe $ab
            expect.hl.toBe $abcd
        zest.mock.end

        call someLabel

describe "zest.mock.getTimesCalled"
    test "loads A with the number of times the handler has been called"
        ; Assert starting times called in 0
        zest.mock.getTimesCalled someLabel
        expect.a.toBe 0

        ; First handler
        zest.mock.start someLabel
            zest.mock.getTimesCalled someLabel
            expect.a.toBe 1
        zest.mock.end

        call someLabel

        ; Second handler
        zest.mock.start someLabel
            zest.mock.getTimesCalled someLabel
            expect.a.toBe 2
        zest.mock.end

        call someLabel

        ; Also, check the other mock's times called is still 0
        zest.mock.getTimesCalled anotherLabel
        expect.a.toBe 0

    test "caps the times called at 255"
        ; Call mock 256 times
        ld b, 0
        -:
            call someLabel
        djnz -

        zest.mock.getTimesCalled someLabel
        expect.a.toBe 255