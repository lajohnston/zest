ld a, (preSuiteCounter)
ld (testValue), a

describe "preSuite hook"
    it "should have run once before the first test"
        ld a, (testValue)
        expect.a.toBe 1
