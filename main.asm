CLEAR_SCREEN MACRO
                  mov ax, 0600h
                  mov bh, 07h
                  mov cx, 0
                  mov dx, 184fh
                  int 10h
ENDM


.model small
.stack 100h

.data
     ; ball data
          EXTRN BALL_X:WORD, BALL_Y:WORD, BALL_SIZE:WORD, BALL_VELOCITY_X:WORD, BALL_VELOCITY_Y:WORD
     ; bar data
          EXTRN BAR_X:WORD, BAR_Y:WORD, BAR_LENGTH:WORD, BAR_HEIGHT:WORD, BAR_SPEED:WORD, BAR_COLOR:BYTE
     ; brick data
          EXTRN BRICK_X:WORD, BRICK_Y:WORD, INITIAL_X:WORD, INITIAL_Y:WORD, NUM_BRICKS_PER_LINE:WORD, NUM_BRICKS_PER_COLUMN:WORD, BRICK_WIDTH:WORD, BRICK_HEIGHT:WORD, COLOR_BRICK:BYTE , Gap:WORD, BRICKS_STATUS:BYTE

.code
     ;bar procedures
               EXTRN        DRAW_BAR:NEAR, CLEAR_BAR:NEAR, WAIT_FOR_VSYNC:NEAR, HANDLE_BAR_INPUT:FAR

     ;ball procedures
               EXTRN        DRAW_BALL:NEAR, CLEAR_BALL:NEAR, MOVE_BALL:NEAR , CHECK_TIME:NEAR , CHECK_COLLISION:NEAR

     ;brick procedures
               EXTRN        DRAW_BRICK:NEAR,  DRAW_BRICKS:NEAR

Main PROC FAR
               mov          ax, @data
               mov          ds, ax
               CLEAR_SCREEN
               mov          ax,13h
               int          10h

     ;draw initial screen
               call         DRAW_BRICKS
               call         DRAW_BAR
               call         DRAW_BALL

     ;main loop
     game_loop:
               call         WAIT_FOR_VSYNC
               call         HANDLE_BAR_INPUT
               call         CHECK_TIME
               call         CLEAR_BALL
               call         MOVE_BALL
               CALL         CHECK_COLLISION
               call         DRAW_BALL
               jmp          game_loop

     exit:     
               mov          ax, 4c00h
               int          21h
Main ENDP
END Main