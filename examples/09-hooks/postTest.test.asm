describe "postTest hook"
    call resetCounters

    it "should have run 0 times by the first test"
        ld a, (postTestCounter)
        expect.a.toBe 0

    it "should have run once by the second test"
        ld a, (postTestCounter)
        expect.a.toBe 1

describe "postTest hook (2nd describe block)"
    it "should have run 2 times by a test in another describe block"
        ld a, (postTestCounter)
        expect.a.toBe 2
