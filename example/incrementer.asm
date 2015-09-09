.section "Incrementer" free
	Incrementer.increment:
		; Intentional bug, dec instead of inc
		dec a
		ret

	Incrementer.incrementRandom:
		push bc
			ld b, a
			call RandomGenerator.generateByte
			add a, b
		pop bc

		ret
.ends
