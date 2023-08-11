# Zest - Sega Master System/Z80 Test Runner

## What is it?

Zest is a unit test runner for use with the Sega Master System and WLA DX assembler. Utilising the WLA DX macro features, it provides a high-level syntax so you can easily feed routines with fixed inputs and assert their output.

```asm
describe "increment"

it "should increment the value in A"
    ld a, 0             ; prep test
    call increment      ; call routine
    expect.a.toBe 1     ; assert the result
```

If the above test fails, the tests will stop running and the test description and failure will be printed on the screen.

## Why?

Pinpointing bugs in assembly code can require lots of manual effort to recreate certain scenarios and ensure everything is working, reducing your confidence for making changes and optimisations to your code.

Instead, with a test runner you can define the list of behaviours you intend a routine to have and ensure they pass, then feel confident to change and optimise the code while being informed if you accidentally break anything.

## How to use it

Examples are included in the repo (see `/examples`). You can build these in Linux/WSL using `./examples/build.sh`. The binaries will be placed in `./examples/dist` which you can then run in an emulator.

Create a blank test suite asm file that will serve as the entry point. In this file, use .include to pull in the Zest library and the code files you want to test.

```asm
; Include Zest library
.incdir "../zest"           ; point to zest directory
    .include "zest.asm"     ; include the zest.asm library
.incdir "."                 ; return to current directory

; Include the code you want to test
.include "increment.asm"

; Define a zest.suite label, which zest will call once it's initialised
.section "myTestSuite" free
    zest.suite:
        ; Include each test file you want to run as part of the suite
        .include "increment.test.asm"

        ; End of test suite
        ret
.ends
```

Within the test file (`increment.test.asm`), the 'describe' and 'it' macros let you define the unit being tested and what behaviours it should exhibit:

```asm
describe "increment"

it "should increment the value in A"
    ld a, 0
    call increment
    expect.a.toBe 1

it "should not increment past 255"
    ld a, 255
    call increment
    expect.a.toBe 255
```

Each time you call the 'it' macro, some clean-up is performed for you which clears the registers and prevent tests from 'leaking' data and affecting other tests.

If a test fails, the message will be printed on the screen with details of the test and assertion that failed.

You can also use `test` as an alias for `it` if you prefer:

```asm
describe "math"

test "add"
    ...

test "subtract"
    ...
```

## Mocking/stubbing labels

Sometimes when testing a routine it's necessary or preferable to mock/stub out routines it calls. One such case is when testing input handling code, whereby you want to ensure the routine is fed certain input values to simulate a given scenario without having to manually press buttons on the joypad.

It may be necessary to extract some routines into separate files and ensure these files aren't imported into your test suite, then define your own fake versions of the routines instead. If the routine you're testing uses `call readPortA` to read the input value of controller A, it will instead call the fake `readPortA` you've defined in the test suite which can return a set value rather than reading the actual input.

Alternatively, Zest also provides a 'Mock' API that lets you define fake routines in RAM so that you can define different behaviour for different test scenarios.

In your test suite, define your mocks in a ramsection using `appendto zest.mocks`:

```asm
.ramsection "my mock instances" appendto zest.mocks
    ; Calls to readPortA will point to this mock in RAM
    readPortA instanceof zest.mock
.ends
```

Mocks gets reset at the start of each 'it' test with a default handler that will simply return (`ret`) to the caller. To override this in a test, wrap some code in `zest.mock.start` and `zest.mock.end`:

```asm
zest.mock.start readPortA
    ld a, %11111110 ; simulate up being pressed
    ; ret is added automatically
zest.mock.end
```

With the above, when the code you're testing calls `readPortA`, it will actually call the code you've defined between `zest.mock.start` and `zest.mock.end`. In the above case, register A would be loaded with a fixed value and would then return to the caller, which will continue running unaware.

## Status

The project is a fully functioning proof-of-concept that I work on as a hobby. Next steps will include adding more assertions and examples so it will be ready for real projects.
