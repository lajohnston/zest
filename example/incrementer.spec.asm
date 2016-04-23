describe "Incrementer"
	it "should increment the value in the a register"
		ld a, 100					; Set up conditions
		call Incrementer.increment	; Call function
		assertAccEquals 101			; Test output

	it "should increment the value by a random amount"
		; Set up conditions
		ld a, 100

		; Mock the random generator
		smsspec.mock.set randomGeneratorMock, _random

		jr +
		_random:
			; Mock will return the value of 50 in register a
			ld a, 50
			ret
		+:

		; Run test
		call Incrementer.incrementRandom

		; Test assertions
		assertAccEquals 150
