describe "player.asm updatePosition"
    it "should not update the position if neither left or right are pressed"
        ; Set playerXPos to 100
        ld a, 100
        ld (playerXPos), a

        ; Stub readPlayer1Input to return no input
        zest.mock.start readPlayer1Input
            ; No buttons pressed (0 = pressed, 1 = not pressed)
            ld a, %11111111
        zest.mock.end

        ; Call the function we're testing
        call updatePosition

        ; Assert playerXPos is still 100
        ld a, (playerXPos)
        expect.a.toBe 100

    it "should increment the player's position when right is pressed"
        ; Set playerXPos to 100
        ld a, 100
        ld (playerXPos), a

        ; Stub readPlayer1Input to return right input
        zest.mock.start readPlayer1Input
            ; Right button pressed (0 = pressed, 1 = not pressed)
            ld a, %11110111
        zest.mock.end

        ; Call the function we're testing
        call updatePosition

        ; Assert playerXPos is now 101
        ld a, (playerXPos)
        expect.a.toBe 101

    it "should decrement the player's position when left is pressed"
        ; Set playerXPos to 100
        ld a, 100
        ld (playerXPos), a

        ; Stub readPlayer1Input to return right input
        zest.mock.start readPlayer1Input
            ; Right button pressed (0 = pressed, 1 = not pressed)
            ld a, %11111011
        zest.mock.end

        ; Call the function we're testing
        call updatePosition

        ; Assert playerXPos is now 101
        ld a, (playerXPos)
        expect.a.toBe 99
