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




; Incrementer tests
.include "incrementer.spec.asm"

.section "smsspec.suite" free
	smsspec.suite:
		call incrementer.spec
.ends
