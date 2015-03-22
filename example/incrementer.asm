.section "Incrementer" free
	Incrementer.increment:
		; Intentional bug, dec instead of inc
		dec a

		call blah

		ret
.ends
