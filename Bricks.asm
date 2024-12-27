.MODEL small
.STACK 100h
.data
PUBLIC BRICK_X, BRICK_Y, INITIAL_X, INITIAL_Y, NUM_BRICKS_PER_LINE, NUM_BRICKS_PER_COLUMN, BRICK_WIDTH, BRICK_HEIGHT, COLOR_BRICK, Gap, BRICKS_STATUS , CURRENT_SCORE  
BRICK_X dw 0ah  
BRICK_Y dw 0ah
INITIAL_X EQu 0ah 
INITIAL_Y EQu 0ah 
NUM_BRICKS_PER_LINE EQu 10
NUM_BRICKS_PER_COLUMN EQu 4
BRICK_WIDTH dw 1ah  ; brick width 26 pixels
BRICK_HEIGHT dw 0fh ; brick height 10 pixels
COLOR_BRICK db 01h ; color of the brick
Gap EQu 4 
BRICKS_STATUS db 10 dup(4) ; 40 bricks
              db 10 dup(3)
              db 2 dup(2)
              db 1 dup(5)
              db 1 dup(2)
              db 1 dup(6)
              db 2 dup(2)
              db 1 dup(5)
              db 2 dup(2)
              db 10 dup(1)


CURRENT_SCORE db 0 

    ;screen format    | 10 26 4 26 4 ......26 10|   each 26 is the brick and 4 is the gap between bricks and there is padding 10 pixels 
    ;                 | 10 4  4  4  ...........4|
    ;                 | 10 26 4 26 4 ......26 10|
.code


PUBLIC DRAW_BRICK, DRAW_BRICKS, RESET_BRICKS_STATUS

RESET_BRICKS_STATUS proc far
    push ax
    push cx
    push si
    
    mov cx, 10         ; First 3 rows (10 bricks * 3)
    mov si, offset BRICKS_STATUS
    mov al, 4          ; Strong bricks
reset_red:
    mov [si], al
    inc si
    loop reset_red
    
    mov cx, 10         ; Last row
    mov al, 3          ; Weak bricks
reset_yellow:
    mov [si], al
    inc si
    loop reset_yellow


    mov cx, 4         ; Last row
    mov al, 2          ; Weak bricks
reset_green_left:
    mov [si], al
    inc si
    loop reset_green_left


        mov cx, 2         ; Last row
    mov al, 5          ; Weak bricks
reset_magenta:
    mov [si], al
    inc si
    loop reset_magenta

        mov cx, 4         ; Last row
    mov al, 2          ; Weak bricks
reset_green_right:
    mov [si], al
    inc si
    loop reset_green_right

            mov cx, 10         ; Last row
    mov al, 1          ; Weak bricks
reset_blue:
    mov [si], al
    inc si
    loop reset_blue
    
    pop si
    pop cx
    pop ax
    ret
RESET_BRICKS_STATUS endp


DRAW_BRICK Proc FAR
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

DRAW_BRICKS proc FAR
    push ax
    push cx
    push dx

    ; mov cx, 0  ; Outer loop counter (rows)
    mov dx , 0
outer_loop:
    ; push cx                        ; Save the outer loop counter

    mov cx, 0    ; Inner loop counter (bricks per row)
inner_loop:

    ; Step 1: Calculate the LiFAR Index
    push dx
    mov ax, dx                  ; AX = row index (i)
    mov di , NUM_BRICKS_PER_LINE
    mul di     ; AX = i * NUM_BRICKS_PER_LINE
    add ax, cx                  ; AX = i * NUM_BRICKS_PER_LINE + j

    ; Step 2: Compute the Address
   mov si, offset BRICKS_STATUS ; SI = base address of BRICKS_STATUS
    add si, ax                   ; SI = address of BRICKS_STATUS[i][j]

    pop dx

    ; Check brick status and set color
    mov bl, [si]                 ; Get brick status
    cmp bl , 6 
    jne check_status_5
    mov COLOR_BRICK , 0ch
    jmp cont
    check_status_5:
    cmp bl , 5
    jne check_status_4
    mov COLOR_BRICK, 05h         ; Magenta color
    jmp cont
check_status_4:
    cmp bl ,4                       ; Check if status is 4
    jne check_status_3
    mov COLOR_BRICK, 04h         ; Red color
    jmp cont
check_status_3:
    cmp bl, 3                    ; Check if status is 3
    jne check_status_2
    mov COLOR_BRICK, 0eh         ; yellow color
    jmp cont

check_status_2:
    cmp bl, 2                    ; Check if status is 2
    jne check_status_1  
    mov COLOR_BRICK, 02h         ; Green color
    jmp cont

check_status_1:
    cmp bl, 1                    ; Check if status is 1
    jne status_zero
    mov COLOR_BRICK, 01h         ; Blue color
    jmp cont

status_zero:
    mov COLOR_BRICK, 00h         ; Black color

cont:
    push bx
    call far ptr DRAW_BRICK             ; Draw one brick
    pop bx

next:

    mov ax, BRICK_X                ; Move to the next brick horizontally
    add ax, BRICK_WIDTH            ; Add the brick width
    add ax, Gap                      ; Add the horizontal gap
    mov BRICK_X, ax                ; Update BRICK_X position
    inc cx
    cmp cx , NUM_BRICKS_PER_LINE
    jl inner_loop                ; Continue drawing bricks in the row

    ; pop cx                         ; Restore the outer loop counter
    inc  dx 
    cmp dx , NUM_BRICKS_PER_COLUMN                        ; Move to the next row
    je done                        ; If all rows are drawn, exit

    mov ax, BRICK_Y                ; Move to the next row verticall far ptry
    add ax, BRICK_HEIGHT           ; Add the brick height
    add ax, Gap                      ; Add the vertical gap
    mov BRICK_Y, ax                ; Update BRICK_Y position

    mov BRICK_X, INITIAL_X         ; Reset BRICK_X to the initial position
    jmp outer_loop                 ; Continue drawing the next row



done:
    mov BRICK_X, INITIAL_X         ; Reset BRICK_X to the initial position
    mov BRICK_Y, INITIAL_Y         ; Reset BRICK_Y to the initial position
    pop dx
    pop cx
    pop ax
    ret
DRAW_BRICKS endp

end