.include "../dist/smsspec.asm"
.include "incrementer.asm"

; Define mocks
.ramsection "mock instances" slot 2
	smsspec.mocks.start: db
	RandomGenerator.generateByte instanceof smsspec.mock
	smsspec.mocks.end: db
.ends

.section "smsspec.suite" free
	smsspec.suite:
		.include "incrementer.spec.asm"
.ends
