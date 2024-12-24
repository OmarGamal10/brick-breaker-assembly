jz game_loop
    jz short check_second_player ;TODO if not then jmp to check the second player  if not needed delete that 


check_second_player:    
    jmp far ptr second_player_receive ; jump to receiving mode
    jnz first_player_send ; TODO deelete if not needed


first_player_send:
    ; MAGEE4 8eer law fe key pressed
    mov ah,0 ;
    int 16h

    mov KEY, al ; ascii code in al ; TODO add more options for keys like pause
    cmp al, 'a' ; left arrow key
    je move_left_bar1
    cmp al, 'd' ; right arrow key
    je move_right_bar1
    cmp al , 27 ; ckeck if the key was esc
    je start_menu_send
    jmp game_loop

move_left_bar1:
  ; check if the bar is at the left edge of the screen
  mov ax, BAR1_X
  cmp ax, 0
  jg skip2_handle_input ; if the bar is at the left edge, continue the loop
  jmp game_loop

skip2_handle_input:
  call WAIT_FOR_VSYNC
  ; clear the bar
  call CLEAR_BAR1
  ; move the bar to the left
  mov ax, BAR1_X
  sub ax, BAR_SPEED
  mov BAR1_X, ax
  ; draw the bar
  call DRAW_BAR1
  call DRAW_BAR2
  jmp send_status_first_player

move_right_bar1:
  ; check if the bar is at the right edge of the screen
  mov ax, BAR1_X
  add ax, BAR_LENGTH
  cmp ax, 319
  jl skip_game_loop1
  jmp game_loop ; if the bar is at the right edge, continue the loop
  skip_game_loop1: call WAIT_FOR_VSYNC
  ; clear the bar
  call CLEAR_BAR1
  ; move the bar to the right
  mov ax, BAR1_X
  add ax, BAR_SPEED
  mov BAR1_X, ax
  ; draw the bar
  call DRAW_BAR1
  call DRAW_BAR2
  jmp send_status_first_player

start_menu_send:

send_status_first_player:
    mov dx, 3FDH ; Line Status Register

again_first_player_send:
    In al, dx ; Read Line Status
    test al, 00100000b
    jz second_player_receive ; Not empty

    mov dx, 3F8H ; Transmit data register
    mov al, KEY ; put the key into al
    out dx, al ; sending the data
    cmp KEY , 27 
    jnz skip_start_menu_bridge1
    jmp start_menu_bridge
    skip_start_menu_bridge1:
    ; HERE TO AFTER SENDING WETHER PAUSE OR ANYTHING ELSE ;TODO
    ; check space bar
    ; cmp al, 39h
    ; je pause_game

    jmp game_loop


second_player_receive:
    mov ah, 1 ; check if there is key to send first 
    int 16h
    jz read_status_second_player
    jmp first_player_send

read_status_second_player:
    mov dx, 3FDH ; Line Status Register
    in al, dx
    test al, 1
    jz second_player_receive ;; if then receive the data

read_second_player:
    mov dx, 3F8H ; Receive data register
    In al, dx ; Read the data
    mov KEY, al ; put the key into al
    cmp al, 'a' ; left arrow key
    je move_left_bar2
    cmp al, 'd' ; right arrow key
    je move_right_bar2
    jmp game_loop

move_left_bar2:
  ; check if the bar is at the left edge of the screen
  mov ax, BAR2_X
  cmp ax, 0
  jg skip_game_loop2
  jmp game_loop ; if the bar is at the left edge, continue the loop
  skip_game_loop2: call WAIT_FOR_VSYNC
  ; clear the bar
  call CLEAR_BAR2
  ; move the bar to the left
  mov ax, BAR2_X
  sub ax, BAR_SPEED
  mov BAR2_X, ax
  ; draw the bar
  call DRAW_BAR2
  call DRAW_BAR1
  jmp game_loop

move_right_bar2:
  ; check if the bar is at the right edge of the screen
  mov ax, BAR2_X
  add ax, BAR_LENGTH
  cmp ax, 319
  jl skip_game_loop3
  jmp game_loop ; if the bar is at the right edge, continue the loop
  skip_game_loop3: call WAIT_FOR_VSYNC
  ; clear the bar
  call CLEAR_BAR2
  ; move the bar to the right
  mov ax, BAR2_X
  add ax, BAR_SPEED
  mov BAR2_X, ax
  ; draw the bar
  call DRAW_BAR2
  call DRAW_BAR1
  jmp game_loop