.section "Incrementer" free
	Incrementer.increment:
		; Intentional bug, dec instead of inc
		dec a
		ret
.ends
