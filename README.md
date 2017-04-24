# SMSSpec

## What is it?
SMSSpec is a unit test/spec runner for use with the Sega Master System/WLA DX assembler. Utilising the WLA DX macro features, it provides a high-level syntax so you can feed routines with fixed inputs and assert their output.

## Why?
Pinpointing bugs in assembly code can be very time consuming, so the TDD mantra 'Debugging sucks. Testing rocks' applies extremely well here.

With a TDD workflow you can define the expected behaviour of a routine before you start work on it, and once the tests pass you can tighten and optimize the code while being informed if you break anything.

## How to use it
There's an example project included in the repo (see /example). Create a blank test suite asm file that will serve as the entry point. In this file, use .include to pull in the SMSSpec library and the code files you want to test.

    ; Within your test suite file
    .include "smsspec.asm"      ; Include the smsspec.asm library
    .include "src/counter.asm"  ; Include the file(s) you want to test

Define an 'smsspec.suite' label that smsspec will call to start the tests, and within it include the tests you wish to include in the suite.

    ; Within the test suite file
    .section "smsspec.suite" free
        smsspec.suite:
            ; Include each test file you want to run as part of the suite
            .include "counter.spec.asm"

            ; End of test suite
            ret
    .ends

In each test file, you can use the 'describe' macro to define each unit being tested, and the 'it' macro to describe the expected behaviour.

    ; Within counter.spec.asm
    describe "Counter"
        it "should increment the value in the accumulator"
            ld a, 1
            call counter.increment
            expect.a.toBe 2

When you compile the test suite and run it in an emulator (SMSSpec is currently untested on real hardware), you be notified on screen if any tests fail. If the above test failed, you would see the following message in red: 'Counter should increment the value in the accumulator'.

Each time you call the 'it' macro, some clean-up is performed for you to empty the registers and prevent tests from 'leaking' data and affecting other tests.

## Mocking
Mocking allows you to focus tests on specific routines rather than their dependencies, and are also useful for stubbing out difficult to test routines such as one that reads an input port.

Labels are set in stone at assemble time, so if you mock a label you won't be able to include the actual label within the same test suite. To test them separately you would therefore just need to house them in a separate test suite.

The mocking implementation in SMSSpec sets up a proxy routine in RAM, allowing you to define different mocks for each 'it' test. This mock gets reset at the start of each test, with a default handler that will simply return (ret) to the caller.

    ; In your test suite, define your mocks in RAM (bookended by start and stop bytes)
    .ramsection "mock instances" slot 2
        smsspec.mocks.start: db
        getPortA instanceof smsspec.mock    ; a call to getPortA will now point to this mock in RAM
        smsspec.mocks.end: db
    .ends

    ; In your test files, mock the routine that fetches input from port A, so it returns a fixed value
    ; This mock only lasts for the duration of the current 'it' test, so you can define it again in another one
    smsspec.mock.start getPortA
        ld a, %00001111 ; Mock routine to return a fixed value rather than reading the actual input port
        ; ret is added automatically
    smsspec.mock.end

With the above, when your code calls 'getPortA', it will actually get redirected to the mock you've defined. In the above case, register a would be loaded with a fixed value and would then return.

## Status
The project is a fully functioning proof-of-concept that I work on as a hobby. Next steps will include adding more assertions and notifications so it will be ready for real projects.
