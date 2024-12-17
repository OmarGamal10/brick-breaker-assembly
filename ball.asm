.model small
.stack 100h
.data
PUBLIC PREV_TIME_STEP, BALL_X, BALL_Y, BALL_SIZE, BALL_VELOCITY_X, BALL_VELOCITY_Y
PREV_TIME_STEP DB 0h
BALL_X DW 0h
BALL_Y DW 0h
BALL_SIZE DW 05h
BALL_VELOCITY_X DW 06h
BALL_VELOCITY_Y DW 03h


.CODE

PUBLIC DRAW_BALL, CLEAR_BALL, MOVE_BALL , CHECK_TIME , CHECK_COLLISION


DRAW_BALL PROC NEAR
    
    mov cx , BALL_X  ;set the initial x position of the ball
    mov dx , BALL_Y  ;set the initial y position of the ball

    draw_horizontal: 
        mov ah , 0ch        ;draw pixel command
        mov al , 0eh          ;set the color of the ball
        int 10h             ;interrupt to draw the pixel
        inc cx              ;increment x position
        mov ax , BALL_X
        add ax , BALL_SIZE
        cmp cx , ax         ;check if x position is less than the (size of the ball + initial x position)
        jne draw_horizontal
        mov cx , BALL_X     ;reset x position to initial x position
        inc dx              ;increment y position
        mov ax , BALL_Y
        add ax , BALL_SIZE
        cmp dx , ax         ;check if y position is less than the (size of the ball + initial y position)
        jne draw_horizontal

    RET
DRAW_BALL ENDP

CLEAR_BALL PROC NEAR
    mov cx , BALL_X  ;set the initial x position of the ball
    mov dx , BALL_Y  ;set the initial y position of the ball

    clear_horizontal: 
        mov ah , 0ch        ;draw pixel command
        mov al , 0          ;set the color to black
        int 10h             ;interrupt to draw the pixel
        inc cx              ;increment x position
        mov ax , BALL_X
        add ax , BALL_SIZE
        cmp cx , ax         ;check if x position is less than the (size of the ball + initial x position)
        jne clear_horizontal
        mov cx , BALL_X     ;reset x position to initial x position
        inc dx              ;increment y position
        mov ax , BALL_Y
        add ax , BALL_SIZE
        cmp dx , ax         ;check if y position is less than the (size of the ball + initial y position)
        jne clear_horizontal

    RET
CLEAR_BALL ENDP

 

CHECK_TIME PROC NEAR
check_time:
        mov ah , 2ch    ; get the current time
        int 21h         ; ch = hour , cl = minutes , dh = seconds , dl = 1/100 seconds

        cmp dl , PREV_TIME_STEP    ; Compare current time step with previous time step
        je check_time
    
    mov PREV_TIME_STEP , dl  ; Update previous time step
    ret
CHECK_TIME ENDP



MOVE_BALL PROC NEAR

    move_x:
        mov ax , BALL_X
        add ax , BALL_VELOCITY_X
        mov BALL_X , ax         ;add velocity to x position

    move_y:
        mov ax , BALL_Y
        add ax , BALL_VELOCITY_Y
        mov BALL_Y , ax         ;add velocity to y position


    
    RET

MOVE_BALL ENDP

CHECK_COLLISION PROC NEAR

    cmp BALL_X , 0
    jle collision_x_left    ;check if x position is less than 0

    mov ax , BALL_X
    add ax , BALL_SIZE
    cmp ax , 320
    jge collision_x_right ;check if x position is greater than 320


    cmp BALL_Y , 0
    jle collision_y_up      ;check if y position is less than 0

    mov ax , BALL_Y
    add ax , BALL_SIZE
    cmp ax , 200
    jge collision_y_down    ;check if y position is greater than 200

    ; call CHECK_BRICKS_COLLISION

    ret

    collision_x_left:
        mov BALL_X , 0          ;set x position to 0 
        neg BALL_VELOCITY_X     ;negate the velocity

    ret

    collision_x_right:
        mov ax , 320
        sub ax , BALL_SIZE
        mov BALL_X , ax         ;set x position to 320 - BALL_SIZE
        neg BALL_VELOCITY_X     ;negate the velocity

    ret

    collision_y_up:
        mov BALL_Y , 0        ;set y position to 0
        neg BALL_VELOCITY_Y    ;negate the velocity

    ret

    collision_y_down:
        mov ax , 200
        sub ax , BALL_SIZE
        mov BALL_Y , ax         ;set y position to 200 - BALL_SIZE
        neg BALL_VELOCITY_Y     ;negate the velocity

    ret
CHECK_COLLISION ENDP

; CHECK_BRICKS_COLLISION PROC near



;     check_horizontal:
;         mov ax , BALL_X
;         cmp ax , cx
;         jl next_horizontal
;         mov ax , BALL_X
;         add ax , BALL_SIZE
;         cmp ax , cx
;         jg next_horizontal
;         mov ax , BALL_Y
;         cmp ax , dx
;         jl next_horizontal
;         mov ax , BALL_Y
;         add ax , BALL_SIZE
;         cmp ax , dx
;         jg next_horizontal
;         mov BALL_VELOCITY_Y , -BALL_VELOCITY_Y
;         ret

;         next_horizontal:
;             inc cx
;             mov ax , BRICK_X
;             add ax , BRICK_WIDTH
;             cmp cx , ax
;             jl check_horizontal
;             mov cx , BRICK_X
;             inc dx
;             mov ax , BRICK_Y
;             add ax , BRICK_HEIGHT
;             cmp dx , ax
;             jl check_horizontal

;     ret


; CHECK_BRICKS_COLLISION ENDP





end 
