.include "incrementer.asm"

.section "Incrementer spec" free
	incrementer.spec:
		describe "Incrementer"

		it "should increment the value in the a register"
			; Set up conditions
			ld a, 100

			; Run function
			call Incrementer.increment

			; Test assertions
			assertAccEquals 101


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



		ret
.ends
