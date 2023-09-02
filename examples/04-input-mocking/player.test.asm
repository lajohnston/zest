describe "player.asm updatePosition"
    it "should not update the position if neither left or right are pressed"
        ; Set playerXPos to 100
        ld a, 100
        ld (playerXPos), a

        ; Stub readPlayer1Input to return no input
        zest.mock.start readPlayer1Input
            ld a, %11111111 ; no buttons pressed (1 = not pressed)
        zest.mock.end

        ; Call the function we're testing
        call updatePosition

        ; You can check the mock was actually called if needed
        expect.mock.toHaveBeenCalled readPlayer1Input

        ; Assert playerXPos is still 100
        ld a, (playerXPos)
        expect.a.toBe 100

    it "should increment the player's position when right is pressed"
        ; Set playerXPos to 100
        ld a, 100
        ld (playerXPos), a

        ; Stub readPlayer1Input to return right input
        zest.mock.start readPlayer1Input
            ld a, %11110111 ; right button pressed
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

        ; Stub readPlayer1Input to return left input
        zest.mock.start readPlayer1Input
            ld a, %11111011 ; left button pressed
        zest.mock.end

        ; Call the function we're testing
        call updatePosition

        ; Assert playerXPos is now 101
        ld a, (playerXPos)
        expect.a.toBe 99
