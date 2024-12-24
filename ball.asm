.model small
.stack 100h
.data
PUBLIC PREV_TIME_STEP, BALL_X, BALL_Y, BALL_SIZE, BALL_VELOCITY_X, BALL_VELOCITY_Y
PREV_TIME_STEP DB 0h
BALL_X DW 0a0h
BALL_Y DW 64h
INITIAL_BALL_X EQu 0a0h
INITIAL_BALL_Y EQu 64h
BALL_SIZE DW 06h
BALL_VELOCITY_X DW 06h
BALL_VELOCITY_Y DW 03h

EXTRN BAR_X:WORD, BAR_Y:WORD, BAR_LENGTH:WORD, BAR_HEIGHT:WORD , LIVES_COUNT:BYTE
EXTRN NUM_BRICKS_PER_LINE:WORD, NUM_BRICKS_PER_COLUMN:WORD, BRICK_WIDTH:WORD, BRICK_HEIGHT:WORD, COLOR_BRICK:BYTE, BRICKS_STATUS:BYTE, INITIAL_X:WORD, INITIAL_Y:WORD, Gap:WORD ,CURRENT_SCORE:BYTE

.CODE

PUBLIC DRAW_BALL, CLEAR_BALL, MOVE_BALL , CHECK_TIME , CHECK_COLLISION
EXTRN WAIT_FOR_VSYNC:NEAR, DRAW_BRICKS:NEAR , CLEAR_SCREEN_PROC:NEAR , main:FAR


DRAW_BALL PROC NEAR
    
    mov cx , BALL_X  ;set the initial x position of the ball
    mov dx , BALL_Y  ;set the initial y position of the ball

    draw_horizontal: 
        mov ah , 0ch        ;draw pixel command
        mov al , 0bh          ;set the color of the ball
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
    call WAIT_FOR_VSYNC    ; Sync with screen refresh
    call CLEAR_BALL        ; Clear old position
    
    ; Update position
    mov ax, BALL_X
    add ax, BALL_VELOCITY_X
    mov BALL_X, ax
    
    mov ax, BALL_Y
    add ax, BALL_VELOCITY_Y
    mov BALL_Y, ax
    
    call CHECK_COLLISION   ; Check for collision
    call DRAW_BALL         ; Draw at new position
    ret
MOVE_BALL ENDP


CHECK_COLLISION PROC NEAR
    push ax
    ; Check for collision with screen edges
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

    
    call CHECK_BAR_COLLISION
    call CHECK_BRICKS_COLLISION

    ; call CHECK_BRICKS_COLLISION
    pop ax
    ret

    collision_x_left:
        mov BALL_X , 0          ;set x position to 0 
        neg BALL_VELOCITY_X     ;negate the velocity
    pop ax
    ret

    collision_x_right:
        mov ax , 320
        sub ax , BALL_SIZE
        mov BALL_X , ax         ;set x position to 320 - BALL_SIZE
        neg BALL_VELOCITY_X     ;negate the velocity
    pop ax
    ret

    collision_y_up:
        mov BALL_Y , 0        ;set y position to 0
        neg BALL_VELOCITY_Y    ;negate the velocity
    pop ax
    ret

    collision_y_down:
        mov BALL_X , INITIAL_BALL_X
        mov BALL_Y , INITIAL_BALL_Y
        dec LIVES_COUNT
        cmp LIVES_COUNT ,0
        jne continue_game
        mov BALL_VELOCITY_X ,0
        mov BALL_VELOCITY_Y ,0
        call far ptr main
        ; call CLEAR_SCREEN_PROC 

        continue_game:
    pop ax
    ret
CHECK_COLLISION ENDP

CHECK_BAR_COLLISION PROC NEAR
    push ax 
    push bx
    ; Check if ball's bottom touches bar's top
    mov ax, BALL_Y
    add ax, BALL_SIZE      ; Get ball's bottom edge
    cmp ax, BAR_Y         ; Compare with bar's top
    jl no_collision       ; Ball is above bar

    ; Check horizontal overlap
    mov ax, BALL_X        ; Ball's left edge
    add ax, BALL_SIZE     ; Ball's right edge
    cmp ax, BAR_X        ; Compare with bar's left
    jl no_collision       ; Ball is left of bar

    mov ax, BALL_X
    mov bx, BAR_X
    add bx, BAR_LENGTH
    cmp ax, bx           ; Compare with bar's right
    jg no_collision       ; Ball is right of bar

    ; Collision detected - bounce ball
    neg BALL_VELOCITY_Y

    ;ensure the ball doesn't penetrate the bar
    mov ax, BAR_Y
    sub ax, BALL_SIZE
    mov BALL_Y, ax
    call DRAW_BALL
no_collision:
    pop bx
    pop ax 
    ret
CHECK_BAR_COLLISION ENDP


CHECK_BRICKS_COLLISION PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si

    ; Check ball position against brick zone
    mov ax, BALL_Y
    cmp ax, 10               ; INITIAL_Y
    jge skip_no_brick_collision     ; Ball is above the brick zone
    jmp short_no_brick_collision
    
    skip_no_brick_collision:

    cmp ax, 80                      ; Bottom of brick zone
    jle short skip_short_no_brick_collision
    jmp short_no_brick_collision     ; Ball is below the brick zone
    skip_short_no_brick_collision:

    ; Get current brick position
    mov ax, BALL_Y                  ; Current position y of the ball
    sub ax, 10                      ; Subtract INITIAL_Y to account for the first row
    mov bx, 19                      ; Brick height + gap ,,, 15+4
    xor dx, dx
    div bx                          ; Divide by height of brick to determine row
    cmp ax, NUM_BRICKS_PER_COLUMN                       ; Check row bounds, we only want 0,1,2,3
    jge short_no_brick_collision    ; Out of bounds
    mov cx, ax                      ; Save row

    ; Determine which brick in the row
    mov ax, BALL_X
    sub ax, 10                      ; Subtract INITIAL_X
    mov bx, 30                      ; Brick width + gap
    xor dx, dx
    div bx                          ; Divide by width of brick to determine column
    cmp ax, NUM_BRICKS_PER_LINE                      ; Check column bounds, we want 0-9
    jge short_no_brick_collision    ; Out of bounds

    ; We have the row and column of the brick
    ; Row * NUM_BRICKS_PER_LINE + column ,,,, here NUM_BRICKS_PER_LINE = 10
    ; Get brick index
    push ax                         ; Save column
    mov ax, cx                      ; Row
    mov bx, 010                      ; NUM_BRICKS_PER_LINE
    mul bx                          ; Row * width
    pop bx                          ; Get column
    add ax, bx                      ; Final index

    ; Check and update brick
    mov si, offset BRICKS_STATUS
    add si, ax
    cmp byte ptr [si], 0            ; Brick already destroyed
    je short_no_brick_collision     ; No collision
    dec byte ptr [si]               ; Destroy brick
    cmp byte ptr [si], 0
     jne continue_
    inc CURRENT_SCORE

    continue_:
    ; Check collision type
    mov ax, BALL_VELOCITY_Y
    cmp ax, 0
    jl short_vertical_hit           ; If moving up, handle as vertical hit

    ; Check for side collision
    mov ax, BALL_X
    add ax, BALL_SIZE               ; Add ball size to current position
    mov bx, cx                      ; Get saved row
    push ax                         ; Save ball position
    mov ax, bx
    mov bx, 30                      ; Brick width + gap
    mul bx                          ; Row * brick width
    add ax, INITIAL_X                      ; Add INITIAL_X
    mov bx, ax                      ; BX = brick left edge
    pop ax                          ; Restore ball position
    
    cmp ax, bx                      ; Compare with brick left edge
    jl short_side_hit               ; Ball is to the left of the brick
    add bx, 26                      ; Add BRICK_WIDTH
    cmp ax, bx                      ; Compare with brick right edge
    jg short_side_hit               ; Ball is to the right of the brick
    
short_vertical_hit:
    neg BALL_VELOCITY_Y             ; Vertical bounce
    jmp short_hit_done              ; Skip to hit done

short_side_hit:
    neg BALL_VELOCITY_X             ; Horizontal bounce

short_hit_done:
    call DRAW_BRICKS                ; Update display

short_no_brick_collision:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
CHECK_BRICKS_COLLISION ENDP


; CHECK_BRICKS_COLLISION PROC NEAR
;     push ax
;     push bx
;     push cx
;     push dx
;     push si

;     ; Check ball position against brick zone
;     mov ax, BALL_Y
;     cmp ax, INITIAL_Y               ; INITIAL_Y
;     jl far ptr no_brick_collision

;     cmp ax, 80              ; Bottom of brick zone
;     jg far ptr no_brick_collision

;     ; Get current brick position
;   mov ax, BALL_Y          ; Current Y position of the ball
;     sub ax, INITIAL_Y              ; Adjust for INITIAL_Y (top of brick zone)
;     mov bx, 19              ; Brick height + gap (15 + 4)
;     xor dx, dx              ; Clear DX for division
;     div bx                  ; AX / BX gives the row
;     cmp ax, NUM_BRICKS_PER_COLUMN               ; Only valid rows are 0, 1, 2, 3
;     jge far ptr no_brick_collision  ; If row >= 4, no collision
;     mov cx, ax              ; Save row index in CX

;     ;now which brick in the row
;     mov ax, BALL_X
;     sub ax, INITIAL_X             ; Subtract INITIAL_X
;     mov bx, 30            ; Brick width + gap
;     xor dx, dx
;     div bx                ; divide by the width of the brick
;     cmp ax, NUM_BRICKS_PER_LINE            ; Check column bounds, we want 0-9
;     jge far ptr no_brick_collision

;     ; we have the row and column of the brick
;     ; row * NUM_BRICKS_PER_LINE + column ,,,, here NUM_BRICKS_PER_LINE = 10
;     ; Get brick index
;     push ax               ; Save column
;     mov ax, cx           ; Row
;     mov bx, NUM_BRICKS_PER_LINE           ; NUM_BRICKS_PER_LINE
;     mul bx               ; Row * width
;     pop bx               ; Get column
;     add ax, bx           ; Final index

;     ; Check and update brick
;     mov si, offset BRICKS_STATUS
;     add si, ax
;     cmp byte ptr [si], 0 ;brick already destroyed
;     je far ptr no_brick_collision
;     dec byte ptr [si]  ; Destroy brick,,, now we should draw again , msh 3arf azbotha
;     cmp byte ptr [si], 0
;     jne continue_:
;     dec CURRENT_NUM_BRICKS
;     continue_:

;     ; Check collision type
;     mov ax, BALL_VELOCITY_Y
;     cmp ax, 0
;     jl vertical_hit       ; If moving up, handle as vertical hit

;     ; Check for side collision
;     mov ax, BALL_X
;     add ax, BALL_SIZE
;     mov bx, cx           ; Get saved row
;     push ax              ; Save ball position
;     mov ax, bx
;     mov bx, 30          ; Brick width + gap
;     mul bx              ; Row * brick width
;     add ax, INITIAL_X          ; Add INITIAL_X
;     mov bx, ax          ; BX = brick left edge
;     pop ax              ; Restore ball position
    
;     cmp ax, bx          ; Compare with brick left edge
;     jl side_hit
;     add bx, BRICK_WIDTH          ; Add BRICK_WIDTH
;     cmp ax, bx          ; Compare with brick right edge
;     jg side_hit
    
; vertical_hit:
;     neg BALL_VELOCITY_Y  ; Vertical bounce
;     jmp hit_done

; side_hit:
;     neg BALL_VELOCITY_X  ; Horizontal bounce

; hit_done:
;     call DRAW_BRICKS    ; Update display
    
; no_brick_collision:
;     pop si
;     pop dx
;     pop cx
;     pop bx
;     pop ax
;     ret
; CHECK_BRICKS_COLLISION ENDP

; end 
end
