
describe "preTest hook"
    call resetCounters

    it "should have run once before the first test"
        ld a, (preTestCounter)
        expect.a.toBe 1

    it "should have run twice by the second test"
        ld a, (preTestCounter)
        expect.a.toBe 2

describe "preTest hook (2nd describe block)"
    it "should have run 3 times by a test in another describe block"
        ld a, (preTestCounter)
        expect.a.toBe 3
