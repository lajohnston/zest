.include "example/incrementer.asm"

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


		it "should do something else"

			jr +
			blahHandler:
				halt
			+:

			;ld hl, (blahMock.address)
			;ld (hl), _blah

			;jr +
			;_blah:
		;		ld hl, $C060
		;		ld (hl), $AB
		;		ret
		;	+:



		ret
.ends
