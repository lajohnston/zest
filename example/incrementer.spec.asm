describe "Incrementer"
    it "should increment the value in the a register"
        ld a, 100                   ; Set up conditions
        call Incrementer.increment  ; Call function
        expect.a.toBe 101           ; Test output

    it "should increment the value by a random amount"
        ; Set up conditions
        ld a, 100

        ; Mock the random generator so it returns a fixed value we can test
        smsspec.mock.start RandomGenerator.generateByte
            ld a, 50	; Mock will return the value of 50 in register a
        smsspec.mock.end

        ; Run test
        call Incrementer.incrementRandom

        ; Test assertions
        expect.a.toBe 150
