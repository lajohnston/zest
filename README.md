#SMSSpec

##What is it?
SMSSpec is a unit test/spec runner for the Sega Master System, for use with the WLA DX assembler. It can be used to help you to implement TDD in retro homebrew projects, so you can build the project incrementally without it getting too complex to debug.


## Why?
The mantra 'Debugging sucks. Testing rocks' applies extremely well to assembly programming. To prevent yourself having to trawl through your code step-by-step in the debugger trying to hunt bugs, you might save yourself a headache or two by implementing automated tests that test each part of the code in isolation and help pin-point where something might have gone wrong.

With a test-driven development workflow, you can plan out what you want a routine to do in plain text ('it should do x; it should do y'), write repeatable tests to assert these requirements under different scenarios, then write the actual asm code to get the requirements to pass. Once you've got the routine working, you're then free to optimize it while ensuring you don't break anything.

## How to use it

    ; Within your test suite
    .include "smsspec.asm"      ; Include the smsspec.asm library
    .include "src/counter.asm"  ; Include the files you want to test

    describe "Counter"
        it "should increment the value in the accumulator"
            ld a, 5
            call counter.increment
            assertAccEquals 6

## Design idea
SMSSpec uses WLA DX macros to define some high level constructs that are common in other test runners. When the test suite gets assembled, the macros output the necessary assembly instructions to carry out the tasks.

The 'describe' and 'it' macros let you specify strings to describe the unit being tested and the behaviour being tested, respectively. SMSSpec will output these to the console if an assertion fails, so you can easily refer to the broken test. As the 'it' macro marks the beginning of a test, it will also perform some clean up to clear the registers and create a clean slate for the test.

In addition, the runner defines assertion macros which will ensure the output matches the expectation, and if not will jump to a routine that will display the test that has failed in the console. You can of course define your own additional assertion macros in your test suite.

## Mocking
If the unit under test calls a routine using a WLA DX label, you can mock this label within your test suite to run a custom routine. Because labels are set in stone at compile time, the mocking implementation in SMSSpec sets up a proxy in RAM which allows you to change the mock at runtime so that you can define different mock behaviours for each test.

More documentation will be available once the implementation settles.

## Status
The project is a working proof-of-concept. I'm currently working on the console output to display the test results.
