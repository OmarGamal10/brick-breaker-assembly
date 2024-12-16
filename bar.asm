.model small
.stack 100h
.data
PUBLIC BAR_X, BAR_Y, BAR_LENGTH, BAR_HEIGHT, BAR_SPEED, BAR_COLOR
BAR_X dw 135
BAR_Y dw 190
BAR_LENGTH dw 60 ; to be decreased by levels
BAR_HEIGHT dw 6
BAR_SPEED dw 5 ;to be inccreased by levels
BAR_COLOR db 0fh
.code

PUBLIC DRAW_BAR, CLEAR_BAR, WAIT_FOR_VSYNC, HANDLE_BAR_INPUT

WAIT_FOR_VSYNC PROC NEAR
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

DRAW_OR_CLEAR_BAR PROC NEAR
  push ax
  push cx
  push dx
  mov BAR_COLOR, al
  mov cx, BAR_X ;col
  mov dx, BAR_Y ;row
  draw_bar_horizontal:
    mov ah, 0ch
    mov al, BAR_COLOR
    int 10h
    inc cx 
    mov ax, BAR_X 
    add ax, BAR_LENGTH
    cmp cx, ax  ;next col
    jb draw_bar_horizontal
  inc dx
  mov ax, BAR_Y
  add ax, BAR_HEIGHT
  mov cx, BAR_X  ;return to starting column
  cmp dx, ax      
  jb draw_bar_horizontal ; move to next row
  pop dx
  pop cx
  pop ax
  ret
DRAW_OR_CLEAR_BAR ENDP

;two mini procedures to draw and clear the bar

DRAW_BAR PROC NEAR
  push ax
  mov al, 0fh
  call DRAW_OR_CLEAR_BAR
  pop ax
  ret
DRAW_BAR ENDP

CLEAR_BAR PROC NEAR
  push ax
  mov al, 0h
  call DRAW_OR_CLEAR_BAR
  pop ax
  ret
CLEAR_BAR ENDP




  HANDLE_BAR_INPUT PROC FAR
    ;check if the user pressed a key
    check_input:
    mov ah, 01h
    int 16h
    jz handle_input_end ;if no key pressed, continue the loop

    ; check which key was pressed
    mov ah, 00h
    int 16h
    ; use scan codes to check which key was pressed
    ; left and right arrow keys have scan codes 4b and 4d
    cmp ah, 4bh
    je move_left

    cmp ah, 4dh
    je move_right

    jmp handle_input_end ;if any other key is pressed, continue the loop

    move_left:
    ;check if the bar is at the left edge of the screen
    mov ax, BAR_X
    cmp ax, 0
    jle handle_input_end;if the bar is at the left edge, continue the loop
    call WAIT_FOR_VSYNC
    ;clear the bar
    call CLEAR_BAR
    ;move the bar to the left
    mov ax, BAR_X
    sub ax, BAR_SPEED
    mov BAR_X, ax
    ;draw the bar
    call DRAW_BAR
    jmp check_input

    move_right:
    ;check if the bar is at the right edge of the screen
    mov ax, BAR_X
    add ax, BAR_LENGTH
    cmp ax, 319
    jge handle_input_end ;if the bar is at the right edge, continue the loop
    call WAIT_FOR_VSYNC
    ;clear the bar
    call CLEAR_BAR
    ;move the bar to the right
    mov ax, BAR_X
    add ax, BAR_SPEED
    mov BAR_X, ax
    ;draw the bar
    call DRAW_BAR
    jmp check_input

  handle_input_end:
    ret
  HANDLE_BAR_INPUT ENDP
end