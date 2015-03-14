; Incrementer tests
.include "example/incrementer.spec.asm"

.section "smsspec.suite" free
	smsspec.suite:
		call incrementer.spec
.ends
