describe "increment.asm increment"
    it "should increment the value in register A"
        ld a, 1         ; set A to 1
        call increment  ; call the routine we're testing
        expect.a.toBe 2 ; expect A to now be 2

    it "should not increment the value beyond 255"
        ld a, 255           ; set A to 255
        call increment      ; call the routine we're testing
        expect.a.toBe 255   ; expect A to still be 255
