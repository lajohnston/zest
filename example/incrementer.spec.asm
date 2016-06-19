describe "Incrementer"
	it "should increment the value in the a register"
		ld a, 100					; Set up conditions
		call Incrementer.increment	; Call function
		assertAccEquals 101			; Test output

	it "should increment the value by a random amount"
		; Set up conditions
		ld a, 100

		; Mock the random generator so it returns a fixed value we can test
		smsspec.mock.start randomGeneratorMock
			ld a, 50	; Mock will return the value of 50 in register a
		smsspec.mock.end

		; Run test
		call Incrementer.incrementRandom

		; Test assertions
		assertAccEquals 150
