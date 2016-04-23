.include "../dist/smsspec.asm"

; Define mocks
.ramsection "mock instances" slot 2
	smsspec.mocks.start: db
	randomGeneratorMock instanceof smsspec.mock
	smsspec.mocks.end: db
.ends

.section "mock labels" free
	RandomGenerator.generateByte: smsspec.mock.call randomGeneratorMock
.ends

.include "incrementer.asm"

.section "smsspec.suite" free
	smsspec.suite:
		.include "incrementer.spec.asm"
.ends
