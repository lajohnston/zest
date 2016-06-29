#SMSSpec

## What is it?
SMSSpec is a unit test/spec runner for use with Sega Master System/WLA DX assembler. Utilising the WLA DX macro features, it provides a high-level syntax so you can feed routines with inputs and assert their output.

## Why?
Pinpointing bugs in assembly code can be very time consuming, so the TDD mantra 'Debugging sucks. Testing rocks' applies extremely well here.

With a TDD workflow you can define the expected behaviour of a routine before you start work on it, and once the tests pass you can tighten and optimize the code while being informed if you break anything.

## How to use it
Create one of more test suite asm files which use .include to pull in the SMSSpec library and the code files you want to test.

    ; Within your test suite file
    .include "smsspec.asm"      ; Include the smsspec.asm library
    .include "src/counter.asm"  ; Include the files you want to test

You can use the 'describe' macro to define each unit being tested, and the 'it' macro to describe the expected behaviour.

    describe "Counter"
        it "should increment the value in the accumulator"
            ld a, 5
            call counter.increment
            assertAccEquals 6

When you compile the test suite and run it in an emulator (SMSSPec is currently untested on real hardware), you be notified on screen if any tests fail. If the above test failed, you would see the text 'Counter should increment the value in the accumulator' in red and know that this particular behaviour isn't working as expected.

## Mocking
If the unit under test calls a routine using a WLA DX label, you can mock this label within your test suite to run a custom routine. Because labels are set in stone at compile time, the mocking implementation in SMSSpec sets up a proxy in RAM which allows you to change the mock at runtime so that you can define different mock behaviours for each test.

More documentation will be available once the implementation settles.

## Status
The project is a fully functioning proof-of-concept.
