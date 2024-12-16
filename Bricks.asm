.MODEL small
.STACK 100h
.data
PUBLIC BRICK_X, BRICK_Y, INITIAL_X, INITIAL_Y, NUM_BRICKS_PER_LINE, NUM_BRICKS_PER_COLUMN, BRICK_WIDTH, BRICK_HEIGHT, COLOR_BRICK
BRICK_X dw 0ah  
BRICK_Y dw 0ah
INITIAL_X EQu 0ah 
INITIAL_Y EQu 0ah 
NUM_BRICKS_PER_LINE EQu 10
NUM_BRICKS_PER_COLUMN EQu 4
BRICK_WIDTH dw 1ah  ; brick width 26 pixels
BRICK_HEIGHT dw 0fh
COLOR_BRICK db 01h ; color of the brick

    ;screen format    | 10 26 4 26 4 ......26 10|   each 26 is the brick and 4 is the gap between bricks and there is padding 10 pixels 
    ;                 | 10 4  4  4  ...........4|
    ;                 | 10 26 4 26 4 ......26 10|
.code


PUBLIC DRAW_BRICK, DRAW_BRICKS



DRAW_BRICK Proc near
    push ax
    push cx
    push dx

    mov cx , BRICK_X  ;brick intial position x
    mov dx, BRICK_Y ;brick intial position x
    
draw_horizontal:
    
    mov al,COLOR_BRICK ; color of the pixel
    mov ah,0ch ;draw pixel
    mov bh,00h 
    int 10h   ; excute the command


    inc cx    ; cx = cx +1 
    
    mov ax,cx ; cx - brick_x > brick_width then draw the next line 
    sub ax,BRICK_X ; subtract the current_x with the inital_x to get the number of drawn pixels if greater than width go next line
    cmp ax,BRICK_WIDTH
    jng draw_horizontal ; if not greater complete drawing the line 
    mov cx , BRICK_X   ; if greater go for next line
    inc dx

    mov ax ,dx        ; same as above but for the height 
    sub ax,BRICK_Y    
    cmp ax,BRICK_HEIGHT  ;compare the current height with the brick_height if not greater then draw the line if not return and the brick is drawn
    jng draw_horizontal

    pop dx
    pop cx
    pop ax
    ret

DRAW_BRICK endp

DRAW_BRICKS proc near
    push ax
    push cx
    push dx

    mov cx, NUM_BRICKS_PER_COLUMN  ; Outer loop counter (rows)
outer_loop:
    push cx                        ; Save the outer loop counter

    mov cx, NUM_BRICKS_PER_LINE    ; Inner loop counter (bricks per row)
inner_loop:
    call DRAW_BRICK         ; Draw one brick
    inc COLOR_BRICK                ; Change the color for the next brick
    cmp COLOR_BRICK,0fh
    jne next
    mov COLOR_BRICK,01h

next:

    mov ax, BRICK_X                ; Move to the next brick horizontally
    add ax, BRICK_WIDTH            ; Add the brick width
    add ax, 4                      ; Add the horizontal gap
    mov BRICK_X, ax                ; Update BRICK_X position
    loop inner_loop                ; Continue drawing bricks in the row

    pop cx                         ; Restore the outer loop counter
    dec cx                         ; Move to the next row
    jz done                        ; If all rows are drawn, exit

    mov ax, BRICK_Y                ; Move to the next row vertically
    add ax, BRICK_HEIGHT           ; Add the brick height
    add ax, 4                      ; Add the vertical gap
    mov BRICK_Y, ax                ; Update BRICK_Y position

    mov BRICK_X, INITIAL_X         ; Reset BRICK_X to the initial position
    jmp outer_loop                 ; Continue drawing the next row

done:
    pop dx
    pop cx
    pop ax
    ret
DRAW_BRICKS endp

end