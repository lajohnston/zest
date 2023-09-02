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

; Append your test files to zest.suite
.section "suite" appendto zest.suite
    .include "increment.test.asm"
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
    readPortA instanceof zest.Mock
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

## Expectations

Zest comes with the following expectations out of the box:

### Registers

Example usage:
    - `expect.a.toBe 255`
    - `expect.b.toBe -128`

```asm
expect.a.toBe -128
expect.b.toBe 255
expect.c.toBe 255
expect.d.toBe 255
expect.e.toBe 255
expect.h.toBe 255
expect.l.toBe 255
expect.i.toBe 255
expect.ixh.toBe 255
expect.ixl.toBe 255
expect.iyh.toBe 255
expect.iyl.toBe 255

expect.bc.toBe -32768
expect.de.toBe 65535
expect.hl.toBe 65535
expect.ix.toBe 65535
expect.iy.toBe 65535
```

### Flags

```asm
expect.carry.toBe 0
expect.carry.toBe 1

expect.parityOverflow.toBe 0
expect.parityOverflow.toBe 1

expect.sign.toBe 0
expect.sign.toBe 1

expect.zeroFlag.toBe 0
expect.zeroFlag.toBe 1
```

## Timeout detection

By default, Zest will timeout and fail a test if it takes more than 10 full frames/VBlanks to complete, in case the code has got itself into an infinite loop, forgotten to return, or jumped to an invalid location. It does this by decrementing a counter at each VBlank and timing out when it reaches zero. Note: this timeout detection relies on the code not disabling interrupts.

As the test won't necessarily begin at the start of a full frame, an additional frame is added to this number to represent the current partial frame.

The default timeout can be overridden for all tests by defining the `zest.defaultTimeout` value before importing Zest.

```
; Timeout tests if they take more than 1 full frame
.define zest.defaultTimeout 1

.incdir "../zest"
    .include "zest.asm"
.incdir "."
```

To override this default timeout for individual tests, use `zest.setTimeout` within the test. You could use this to increase the timeout for tests you expect to take a longer amount of time:

```
it "should not timeout"
    ; Only timeout this test if it takes more than 20 full frames
    zest.setTimeout 20
    call mySlowRoutine
```

## Memory overwrite detection

Zest will attempt to detect if its RAM state has been overwritten by a test, and if so will stop the program with an error message. A backup of the test description pointers is kept in VRAM (within the sprite attribute table gap) and Zest will attempt to restore these so it can recover and display the test that exhibits the issue.

## Status

The project is a fully functioning proof-of-concept that I work on as a hobby. Next steps will include adding more assertions and examples so it will be ready for real projects.
