;====
; This example showcases the ability to mock/stub out labels. When code
; calls or jumps to these labels, they will actually call a dynamic mediator
; which means you can define a separate handler for each test
;====

; Include the Zest lib
.incdir "../../"
    .include "zest.asm"
.incdir "."

;====
; Define the labels you want to mock/stub
;====
.ramsection "mock instances" appendto zest.mocks
    someLabel       instanceof zest.Mock
    anotherLabel    instanceof zest.Mock
.ends

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "mock.test.asm"
.ends
