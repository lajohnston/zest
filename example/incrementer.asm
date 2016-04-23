.section "Incrementer" free
	Incrementer.increment:
		dec a ; Intentional bug, dec instead of inc
		ret

	Incrementer.incrementRandom:
		push bc
			ld b, a
			call RandomGenerator.generateByte
			add a, b
		pop bc

		ret
.ends
