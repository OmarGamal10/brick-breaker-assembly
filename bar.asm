.model small
.stack 100h
.data
PUBLIC BAR1_X, BAR2_X , BAR1_Y,BAR2_Y, BAR_LENGTH, BAR_HEIGHT, BAR_SPEED, BAR1_COLOR , BAR2_COLOR
BAR1_X dw 80
BAR1_Y dw 192
BAR2_Y dw 192
BAR2_X dw 80

BAR_LENGTH dw 60 ; to be decreased by levels
BAR_HEIGHT dw 6
BAR_SPEED dw 5 ;to be inccreased by levels
BAR1_COLOR db 0fh
BAR2_COLOR db 0eh
.code

PUBLIC DRAW_BAR1, CLEAR_BAR1, DRAW_BAR2 , CLEAR_BAR2,  WAIT_FOR_VSYNC, HANDLE_BAR_INPUT

WAIT_FOR_VSYNC PROC FAR
    push ax
    push dx    
    mov dx, 3DAh         ; VGA status port
vsync_wait1:
    in al, dx
    test al, 8          ; Check vertical retrace
    jnz vsync_wait1     ; Wait if already in retrace
vsync_wait2:
    in al, dx
    test al, 8          ; Wait for vertical retrace
    jz vsync_wait2    
    pop dx
    pop ax
    ret
WAIT_FOR_VSYNC ENDP

DRAW_OR_CLEAR_BAR1 PROC FAR
  push ax
  push cx
  push dx
  mov BAR1_COLOR, al
  mov cx, BAR1_X ;col
  mov dx, BAR1_Y ;row
  draw_bar1_horizontal:
    mov ah, 0ch
    mov al, BAR1_COLOR
    int 10h
    inc cx 
    mov ax, BAR1_X 
    add ax, BAR_LENGTH
    cmp cx, ax  ;next col
    jb draw_bar1_horizontal
  inc dx
  mov ax, BAR1_Y
  add ax, BAR_HEIGHT
  mov cx, BAR1_X  ;return to starting column
  cmp dx, ax      
  jb draw_bar1_horizontal ; move to next row
  pop dx
  pop cx
  pop ax
  ret
DRAW_OR_CLEAR_BAR1 ENDP

;two mini procedures to draw and clear the bar

DRAW_BAR1 PROC FAR
  push ax
  mov al, 0fh
  call far ptr DRAW_OR_CLEAR_BAR1
  pop ax
  ret
DRAW_BAR1 ENDP

CLEAR_BAR1 PROC FAR
  push ax
  mov al, 0h
  call far ptr DRAW_OR_CLEAR_BAR1
  pop ax
  ret
CLEAR_BAR1 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


DRAW_OR_CLEAR_BAR2 PROC FAR
  push ax
  push cx
  push dx
  mov BAR2_COLOR, al
  mov cx, BAR2_X ;col
  mov dx, BAR2_Y ;row
  draw_bar2_horizontal:
    mov ah, 0ch
    mov al, BAR2_COLOR
    int 10h
    inc cx 
    mov ax, BAR2_X 
    add ax, BAR_LENGTH
    cmp cx, ax  ;next col
    jb draw_bar2_horizontal
  inc dx
  mov ax, BAR2_Y
  add ax, BAR_HEIGHT
  mov cx, BAR2_X  ;return to starting column
  cmp dx, ax      
  jb draw_bar2_horizontal ; move to next row
  pop dx
  pop cx
  pop ax
  ret
DRAW_OR_CLEAR_BAR2 ENDP

;two mini procedures to draw and clear the bar

DRAW_BAR2 PROC FAR
  push ax
  mov al, 0eh
  call far ptr DRAW_OR_CLEAR_BAR2
  pop ax
  ret
DRAW_BAR2 ENDP

CLEAR_BAR2 PROC FAR
  push ax
  mov al, 0h
  call far ptr DRAW_OR_CLEAR_BAR2
  pop ax
  ret
CLEAR_BAR2 ENDP




  HANDLE_BAR_INPUT PROC FAR
    ;check if the user pressed a key
    check_input:
    mov ah, 01h
    int 16h
    jnz skip_handle_input
    jmp  handle_input_end;if no key pressed, continue the loop
    skip_handle_input:
    ; check which key was pressed
    mov ah, 00h
    int 16h
    ; use scan codes to check which key was pressed

    ; check space bar
    cmp ah, 39h
    je pause_game

    
    ; left and right arrow keys have scan codes 4b and 4d
    cmp ah, 4bh
    je move_left_bar1

    cmp ah, 4dh
    je move_right_bar1


    cmp al , 'a'
    je move_left_bar2

    cmp al ,'d'
    jne skip_move_right_bar2_1
    jmp move_right_bar2
skip_move_right_bar2_1:
    jmp handle_input_end ;if any other key is pressed, continue the loop

    pause_game:
    mov ah, 02h
    mov bh, 0
    mov dh, 12
    mov dl, 15
    int 10h


    wait_resume:
    mov ah, 01h
    int 16h
    jz wait_resume

    jmp handle_input_end


    move_left_bar1:
    ;check if the bar is at the left edge of the screen
    mov ax, BAR1_X
    cmp ax, 0
    jg skip2_handle_input;if the bar is at the left edge, continue the loop
    jmp handle_input_end

    skip2_handle_input:
    call far ptr WAIT_FOR_VSYNC
    ;clear the bar
    call far ptr CLEAR_BAR1
    ;move the bar to the left
    mov ax, BAR1_X
    sub ax, BAR_SPEED
    mov BAR1_X, ax
    ;draw the bar
    call far ptr DRAW_BAR1
    call far ptr DRAW_BAR2
    jmp check_input

    move_right_bar1:
    ;check if the bar is at the right edge of the screen
    mov ax, BAR1_X
    add ax, BAR_LENGTH
    cmp ax, 319
    jge handle_input_end ;if the bar is at the right edge, continue the loop
    call far ptr WAIT_FOR_VSYNC
    ;clear the bar
    call far ptr CLEAR_BAR1
    ;move the bar to the right
    mov ax, BAR1_X
    add ax, BAR_SPEED
    mov BAR1_X, ax
    ;draw the bar
    call far ptr DRAW_BAR1
    call far ptr DRAW_BAR2
    jmp check_input




    move_left_bar2:
    ;check if the bar is at the left edge of the screen
    mov ax, BAR2_X
    cmp ax, 0
    jle handle_input_end;if the bar is at the left edge, continue the loop
    call far ptr WAIT_FOR_VSYNC
    ;clear the bar
    call far ptr CLEAR_BAR2
    ;move the bar to the left
    mov ax, BAR2_X
    sub ax, BAR_SPEED
    mov BAR2_X, ax
    ;draw the bar
    call far ptr DRAW_BAR2
    call far ptr DRAW_BAR1
    jmp check_input

    move_right_bar2:
    ;check if the bar is at the right edge of the screen
    mov ax, BAR2_X
    add ax, BAR_LENGTH
    cmp ax, 319
    jge handle_input_end ;if the bar is at the right edge, continue the loop
    call far ptr WAIT_FOR_VSYNC
    ;clear the bar
    call far ptr CLEAR_BAR2
    ;move the bar to the right
    mov ax, BAR2_X
    add ax, BAR_SPEED
    mov BAR2_X, ax
    ;draw the bar
    call far ptr DRAW_BAR2
    call far ptr DRAW_BAR1
    jmp check_input

  handle_input_end:
    ret
  HANDLE_BAR_INPUT ENDP
end