.include "smsspec.asm"

; Define mocks
.ramsection "mock instances" slot 2
	smsspec.mocks.start: db

	blahMock instanceof smsspec.mock
	blahMock2 instanceof smsspec.mock

	smsspec.mocks.end: db
.ends

.section "mock labels" free
	blah: smsspec.mock.call blahMock
.ends




; Incrementer tests
.include "example/incrementer.spec.asm"

.section "smsspec.suite" free
	smsspec.suite:
		call incrementer.spec
.ends
