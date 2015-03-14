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
			assertAccEquals 101, "a"
		ret
.ends
