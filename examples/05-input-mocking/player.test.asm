describe "player.asm updatePositions (Player 1)"
    it "should decrement the player's position when left is pressed"
        ; Set player1XPosition to 100
        ld a, 100
        ld (player1XPosition), a

        ; Stub readPlayer1Input to return left input
        zest.mockController1 zest.LEFT

        ; Call the function we're testing
        call updatePlayer1Position

        ; Assert player1XPosition is now 99
        ld a, (player1XPosition)
        expect.a.toBe 99

    it "should increment the player's position when right is pressed"
        ; Set player1XPosition to 100
        ld a, 100
        ld (player1XPosition), a

        ; Stub readPlayer1Input to return right input
        zest.mockController1 zest.RIGHT

        ; Call the function we're testing
        call updatePlayer1Position

        ; Assert player1XPosition is now 101
        ld a, (player1XPosition)
        expect.a.toBe 101

    it "should not update the position if neither left or right are pressed"
        ; Set player1XPosition to 100
        ld a, 100
        ld (player1XPosition), a

        ; Stub readPlayer1Input to return no input
        zest.mockController1 zest.NO_INPUT

        ; Call the function we're testing
        call updatePlayer1Position

        ; Assert player1XPosition is still 100
        ld a, (player1XPosition)
        expect.a.toBe 100

describe "player.asm updatePositions (Player 2)"
    it "should decrement the player's position when left is pressed"
        ; Set player2XPosition to 100
        ld a, 100
        ld (player2XPosition), a

        ; Stub readPlayer1Input to return left input
        zest.mockController2 zest.LEFT

        ; Call the function we're testing
        call updatePlayer2Position

        ; Assert player2XPosition is now 99
        ld a, (player2XPosition)
        expect.a.toBe 99

    it "should increment the player's position when right is pressed"
        ; Set player2XPosition to 100
        ld a, 100
        ld (player2XPosition), a

        ; Stub readPlayer1Input to return right input
        zest.mockController2 zest.RIGHT

        ; Call the function we're testing
        call updatePlayer2Position

        ; Assert player2XPosition is now 101
        ld a, (player2XPosition)
        expect.a.toBe 101

    it "should not update the position if neither left or right are pressed"
        ; Set player2XPosition to 100
        ld a, 100
        ld (player2XPosition), a

        ; Stub readPlayer1Input to return no input
        zest.mockController2 zest.NO_INPUT

        ; Call the function we're testing
        call updatePlayer2Position

        ; Assert player2XPosition is still 100
        ld a, (player2XPosition)
        expect.a.toBe 100
