; Author: Anas Ibrahem
; Description: A simple main menu for a brick breaker
; ; 3 5  / 3 8 /  3 11 Cursor Positions
;; Updated By : Anas Ibrahem    24 / 12 / 2024
CLEAR_SCREEN_GAME_MACRO MACRO ;; Not used in this file
    mov ax, 0600h ; Clear Screen
    mov bh, 07h
    mov cx, 0
    mov dx, 184fh
    int 10h
ENDM CLEAR_SCREEN_GAME_MACRO  

CLEAR_SCREEN_MACRO MACRO
    mov ah, 0
    mov al, 3
    int 10h
ENDM CLEAR_SCREEN_MACRO 

SAVE_CURSOR_SENDER_MACRO MACRO
    mov ah, 3h
    mov bh, 0h
    int 10h
    mov X_SENDER, dl
    mov Y_SENDER, dh
ENDM SAVE_CURSOR_SENDER_MACRO  

SAVE_CURSOR_RECEIVER_MACRO MACRO
    mov ah, 3h
    mov bh, 0h
    int 10h
    mov X_RECEIVE, dl
    mov Y_RECEIVE, dh
ENDM SAVE_CURSOR_RECEIVER_MACRO 

CLEAR_UPPER_MACRO MACRO
    mov ax, 060Dh
    mov bh, 03h
    mov ch, 0
    mov cl, 0
    mov dh, 12
    mov dl, 79
    int 10h
ENDM CLEAR_UPPER_MACRO 

SCROLL_UPPER_MACRO MACRO
    mov ah, 6
    mov al, 1
    mov bh, 03h
    mov ch, 0
    mov cl, 0
    mov dh, 12
    mov dl, 79
    int 10h
ENDM SCROLL_UPPER_MACRO 

SCROLL_LOWER_MACRO MACRO
    mov ah, 6
    mov al, 1
    mov bh, 30h
    mov ch, 13
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
ENDM SCROLL_LOWER_MACRO 

CLEAR_LOWER_MACRO MACRO
    mov ax, 060Ch
    mov bh, 30h
    mov ch, 13
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
ENDM CLEAR_LOWER_MACRO

SET_CURSOR_MACRO MACRO x, y
    mov ah, 2
    mov bh, 0
    mov dl, x
    mov dh, y
    int 10h
ENDM SET_CURSOR_MACRO

;-----------------------------------------------------------------------------------------------------
.model small
.data
    PUBLIC READY1 , READY2
    ; ball data
    EXTRN BALL_X:WORD, BALL_Y:WORD, BALL_SIZE:WORD, BALL_VELOCITY_X:WORD, BALL_VELOCITY_Y:WORD , PREV_TIME_STEP:BYTE
    ; bar data
    ; EXTRN BAR_X:WORD, BAR1_Y:WORD, BAR2_Y:WORD, BAR_LENGTH:WORD, BAR_HEIGHT:WORD, BAR_SPEED:WORD, BAR_COLOR:BYTE
    EXTRN BAR1_X:WORD, BAR2_X :WORD, BAR1_Y:WORD,BAR2_Y:WORD, BAR_LENGTH:WORD, BAR_HEIGHT:WORD, BAR_SPEED:WORD, BAR1_COLOR:BYTE , BAR2_COLOR:BYTE

    ; brick data
    EXTRN BRICK_X:WORD, BRICK_Y:WORD, INITIAL_X:WORD, INITIAL_Y:WORD, NUM_BRICKS_PER_LINE:WORD, NUM_BRICKS_PER_COLUMN:WORD, BRICK_WIDTH:WORD, BRICK_HEIGHT:WORD, COLOR_BRICK:BYTE, Gap:WORD, BRICKS_STATUS:BYTE, CURRENT_SCORE:WORD

    ; Main Menu Variables
    PUBLIC LIVES_COUNT
    TITLE_VARIABLE db "BRICKs BREAKER - MAIN MENU$"
    OPTION1_VARIABLE db "1. Start Game$"
    OPTION2_VARIABLE db "2. Chat$"
    OPTION3_VARIABLE db "3. Exit$"
    SCORE_MESSAGE db "SCORE: $"
    LIVES_MESSAGE db "LIVES: $"
    SELECTED_OPTION db 0
    NO_OF_OPTIONS db 2
    CLEAR db " $"
    KEY db 0
    HEART db 3
    READY_KEY db 'r'
    READY1 db 0
    READY2 db 0
    LIVES_COUNT db 4
    temp db 0
    ; Chat Variables
    VALUE db ?
    Y_SENDER db 0
    X_SENDER db 0
    X_RECEIVE db 0
    Y_RECEIVE db 0Dh
.stack 100h
.code
    ; bar procedures
    EXTRN DRAW_BAR:FAR, CLEAR_BAR:FAR, WAIT_FOR_VSYNC:FAR, HANDLE_BAR_INPUT:FAR
    ; ball procedures
    EXTRN DRAW_BALL:FAR, CLEAR_BALL:FAR, MOVE_BALL:FAR, CHECK_TIME:FAR, CHECK_COLLISION:FAR
    ; brick procedures
    EXTRN DRAW_BRICK:FAR, DRAW_BRICKS:FAR
    
    EXTRN DRAW_BAR1:FAR, CLEAR_BAR1:FAR, DRAW_BAR2:FAR , CLEAR_BAR2:FAR,  WAIT_FOR_VSYNC:FAR

    PUBLIC main

CLEAR_SCREEN_PROC proc far
    mov ah, 0
    mov al, 3
    int 10h
    ret
CLEAR_SCREEN_PROC endp

DISPLAY_TEXT_PROC proc far
    mov ah, 9
    int 21h
    ret
DISPLAY_TEXT_PROC endp

SET_CURSOR_PROC proc far
    mov ah, 2
    int 10h
    ret
SET_CURSOR_PROC endp

PRINT_HEART_PROC proc far
    push cx
    mov al, HEART
    mov ah, 9
    mov cx, 1h
    mov bl, 04h
    int 10h
    pop cx
    ret
PRINT_HEART_PROC endp
UPDATE_STATS_PROC proc far
    push ax
    push bx
    push cx
    push dx

    mov ax, CURRENT_SCORE
    ;; Convert to ascii
    aam
    add al, '0'
    add ah, '0'

    ; Print al
    mov temp, ah
    mov dl, 8
    mov dh, 0
    call far ptr SET_CURSOR_PROC
    mov ah, 9
    mov cx, 1h
    mov bl, 03h
    int 10h

    ; Print ah
    mov al, temp
    mov dl, 7
    mov dh, 0
    call far ptr SET_CURSOR_PROC
    mov ah, 9
    mov cx, 1h
    mov bl, 03h
    int 10h
    ; Print Lives
    mov al, LIVES_COUNT
    add al, '0'
    mov dl, 31
    mov dh, 0
    call far ptr SET_CURSOR_PROC
    mov ah, 9
    mov cx, 1h
    mov bl, 04h
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
  ret
UPDATE_STATS_PROC ENDP


DISPLAY_MENU_PROC proc far
    first_option:
    mov dl, 5
    mov dh, 5
    call far ptr SET_CURSOR_PROC
    mov dx, offset OPTION1_VARIABLE
    call far ptr DISPLAY_TEXT_PROC

    second_option:
    mov dl, 5
    mov dh, 8
    call far ptr SET_CURSOR_PROC
    mov dx, offset OPTION2_VARIABLE
    call far ptr DISPLAY_TEXT_PROC

    third_option:
    mov dl, 5
    mov dh, 11
    call far ptr SET_CURSOR_PROC
    mov dx, offset OPTION3_VARIABLE
    call far ptr DISPLAY_TEXT_PROC
    ret
DISPLAY_MENU_PROC endp

PRINT_CURSOR_PROC proc far
    ; Print the cursor selector
    ; Clear all selectors
    mov dl, 3
    mov dh, 5
    call far ptr SET_CURSOR_PROC
    mov dx, offset CLEAR
    call far ptr DISPLAY_TEXT_PROC

    mov dl, 3
    mov dh, 8
    call far ptr SET_CURSOR_PROC
    mov dx, offset CLEAR
    call far ptr DISPLAY_TEXT_PROC

    mov dl, 3
    mov dh, 11
    call far ptr SET_CURSOR_PROC
    mov dx, offset CLEAR
    call far ptr DISPLAY_TEXT_PROC

    cmp SELECTED_OPTION, 0
    je y_first_option
    cmp SELECTED_OPTION, 1
    je y_second_option
    cmp SELECTED_OPTION, 2
    je y_third_option

    y_first_option:
    mov dl, 3
    mov dh, 5
    jmp print_cursor

    y_second_option:
    mov dl, 3
    mov dh, 8
    jmp print_cursor

    y_third_option:
    mov dl, 3
    mov dh, 11
    jmp print_cursor

    print_cursor:
    call far ptr SET_CURSOR_PROC
    mov ah, 9
    mov al, '>'
    mov cx, 1h
    mov bl, 03h
    int 10h
    ret
PRINT_CURSOR_PROC endp

main proc far
    mov ax, @data
    mov ds, ax

    start_menu:
    mov ah, 0
    mov al, 13h
    int 10h

    ; call far ptr CLEAR_SCREEN_PROC ;NOT NEEDED
    print_start_menu:
    ; Set Cursor Center for Title
    mov dl, 7
    mov dh, 2
    call far ptr SET_CURSOR_PROC

    ; Display the title
    mov dx, offset TITLE_VARIABLE
    call far ptr DISPLAY_TEXT_PROC
    ; Display Menu
    call far ptr DISPLAY_MENU_PROC

    menu_loop:
    ; Read keyboard input for navigation
    call far ptr PRINT_CURSOR_PROC
    mov ah, 0
    int 16h
    cmp ah, 48h ; Arrow Up key
    je navigate_up
    cmp ah, 50h ; Arrow Down key
    je navigate_down
    cmp ah, 1Ch ; Enter key
    je select_option
    jmp menu_loop

    navigate_up:
    dec SELECTED_OPTION
    cmp SELECTED_OPTION, 0
    jl reset_to_bottom
    jmp menu_loop

    navigate_down:
    inc SELECTED_OPTION
    mov al, NO_OF_OPTIONS
    cmp SELECTED_OPTION, al
    jg reset_to_top
    jmp menu_loop

    reset_to_top:
    mov SELECTED_OPTION, 0
    jmp menu_loop

    reset_to_bottom:
    mov al, NO_OF_OPTIONS
    mov SELECTED_OPTION, al
    jmp menu_loop

    select_option:
    cmp SELECTED_OPTION, 0
    je start_game
    cmp SELECTED_OPTION, 1
    jne skip_option_1
    jmp far ptr show_chat
    skip_option_1:
    cmp SELECTED_OPTION, 2
    jne skip_option_2
    jmp far ptr exit_game
    skip_option_2:
    jmp menu_loop

    start_game:
    ; draw initial screen
    CLEAR_SCREEN_MACRO
    mov ax, 13h
    int 10h
    call far ptr DRAW_BRICKS
    call far ptr DRAW_BAR
    call far ptr DRAW_BALL

    ;; Set Cursor for Score
    mov dl, 1
    mov dh, 0
    call far ptr SET_CURSOR_PROC
    ;; Display Score Message
    mov dx, offset SCORE_MESSAGE
    call far ptr DISPLAY_TEXT_PROC

    mov dl, 25
    mov dh, 0
    call far ptr SET_CURSOR_PROC
    mov dx, offset LIVES_MESSAGE
    call far ptr DISPLAY_TEXT_PROC

  ;; INITIALIZATION of Communication
  mov dx, 3fbh ; Line control Register
  mov al, 10000000b
  out dx, al

  ; Set up the baud rate
  mov dx, 3f8h
  mov al, 0c0h
  out dx, al

  mov dx, 3f9h
  mov al, 00h
  out dx, al

  ; Set port configuration
  mov dx, 3fbh
  mov al, 00011111b
  out dx, al

outer_check_loop:
        mov ah, 01h
        int 16h
        jz check_2nd_ready_loop
        cmp al , READY_KEY
        jne check_2nd_ready_loop
        mov READY1, 1
        ; Send ready Key
        mov dx, 3FDH ; Line Status Register
        In al, dx ; Read Line Status
        test al, 00100000b
        jz check_2nd_ready_loop ; Not empty
        mov dx, 3F8H ; Transmit data register
        mov al, READY_KEY ; put the key into al
        out dx, al ; sending the data
check_2nd_ready_loop:
        mov dx, 3FDH ; Line Status Register
        in al, dx
        test al, 1
        jnz read_ready_from_second_player
        jmp test_ready 
read_ready_from_second_player:
        mov dx, 3F8H ; Receive data register
        In al, dx ; Read the data
        cmp al, READY_KEY ;
        jne test_ready
        mov READY2, 1
test_ready:
cmp READY1 , 1
jne outer_check_loop
cmp READY2 , 1
jne outer_check_loop

game_loop:
    ; Start Communication and logic
    mov ah, 1 ; Check if a key is pressed
    int 16h
    jnz first_player_press_key
    jmp far ptr second_player_receive ; jump to receiving mode
    first_player_press_key:
        mov ah,0
        int 16h

        mov KEY, al ; ascii code in al ; TODO add more options for keys like pause
        send_status_first_player:
        mov dx, 3FDH ; Line Status Register
        In al, dx ; Read Line Status
        test al, 00100000b
        jz second_player_receive ; Not empty

        mov dx, 3F8H ; Transmit data register
        mov al, KEY ; put the key into al
        out dx, al ; sending the data

        cmp al, 'a' ; left arrow key
        je move_left_bar1
        cmp al, 'd' ; right arrow key
        je move_right_bar1
        ;cmp al , 27 ; ckeck if the key was esc
        ;je start_menu_send
        jmp update_ball


    move_left_bar1:
        ; check if the bar is at the left edge of the screen
        mov ax, BAR1_X
        cmp ax, 0
        jg skip2_handle_input ; if the bar is at the left edge, continue the loop
        jmp update_ball


    skip2_handle_input:
        call far ptr WAIT_FOR_VSYNC
        ; clear the bar
        call far ptr CLEAR_BAR1
        ; move the bar to the left
        mov ax, BAR1_X
        sub ax, BAR_SPEED
        mov BAR1_X, ax
        ; draw the bar
        call far ptr DRAW_BAR1
        call far ptr DRAW_BAR2
        jmp second_player_receive


    move_right_bar1:
        ; check if the bar is at the right edge of the screen
        mov ax, BAR1_X
        add ax, BAR_LENGTH
        cmp ax, 319
        jl skip_game_loop1
        jmp update_ball ; if the bar is at the right edge, continue the loop
        skip_game_loop1: call far ptr WAIT_FOR_VSYNC
        ; clear the bar
        call far ptr CLEAR_BAR1
        ; move the bar to the right
        mov ax, BAR1_X
        add ax, BAR_SPEED
        mov BAR1_X, ax
        ; draw the bar
        call far ptr DRAW_BAR1
        call far ptr DRAW_BAR2
        jmp second_player_receive

    second_player_receive:
        mov dx, 3FDH ; Line Status Register
        in al, dx
        test al, 1
        jnz read_from_second_player
        jmp update_ball 

    read_from_second_player:
        mov dx, 3F8H ; Receive data register
        In al, dx ; Read the data
        mov KEY, al ; put the key into al
        cmp al, 'a' ; left arrow key
        je move_left_bar2
        cmp al, 'd' ; right arrow key
        je move_right_bar2
        jmp update_ball


    move_left_bar2:
        ; check if the bar is at the left edge of the screen
        mov ax, BAR2_X
        cmp ax, 0
        jg skip_game_loop2
        jmp update_ball ; if the bar is at the left edge, continue the loop
        skip_game_loop2: call far ptr WAIT_FOR_VSYNC
        ; clear the bar
        call far ptr CLEAR_BAR2
        ; move the bar to the left
        mov ax, BAR2_X
        sub ax, BAR_SPEED
        mov BAR2_X, ax
        ; draw the bar
        call far ptr DRAW_BAR2
        call far ptr DRAW_BAR1
        jmp update_ball

    move_right_bar2:
        ; check if the bar is at the right edge of the screen
        mov ax, BAR2_X
        add ax, BAR_LENGTH
        cmp ax, 319
        jl skip_game_loop3
        jmp update_ball ; if the bar is at the right edge, continue the loop
        skip_game_loop3: call far ptr WAIT_FOR_VSYNC
        ; clear the bar
        call far ptr CLEAR_BAR2
        ; move the bar to the right
        mov ax, BAR2_X
        add ax, BAR_SPEED
        mov BAR2_X, ax
        ; draw the bar
        call far ptr DRAW_BAR2
        call far ptr DRAW_BAR1
        jmp update_ball
        
        update_ball:
        mov ah , 2ch    ; get the current time
        int 21h         ; ch = hour , cl = minutes , dh = seconds , dl = 1/100 seconds
        cmp dl , PREV_TIME_STEP    ; Compare current time step with previous time step
        jne skip_game_loop_4
        jmp game_loop ; if equal then continue the loop
        skip_game_loop_4:
        mov PREV_TIME_STEP , dl  ; Update previous time step
        call far ptr MOVE_BALL
        call far ptr UPDATE_STATS_PROC
jmp game_loop ; stuck at game loop


show_chat:
    call far ptr CLEAR_SCREEN_PROC
    mov dx, 3fbh ; Line control Register
    mov al, 10000000b
    out dx, al

    ; Set up the baud rate
    mov dx, 3f8h
    mov al, 0ch
    out dx, al

    mov dx, 3f9h
    mov al, 00h
    out dx, al

    ; Set port configuration
    mov dx, 3fbh
    mov al, 00011011b
    out dx, al

    ; SetUp the screen
    mov ah, 0 ; Ensure text mode
    mov al, 3
    int 10h

    CLEAR_UPPER_MACRO
    CLEAR_LOWER_MACRO

    mov dl, 0
    mov dh, 0
    call far ptr SET_CURSOR_PROC

    ; start sending and receiving
    call far ptr DETECT_CHAT_PROC

DETECT_CHAT_PROC proc
    chat_loop:
    ; Check if there is a key pressed
    mov ah, 1
    int 16h
    jz short check_receive ; if not then jmp to check_receive // short to fix out of range

    check_receive:
    jmp far ptr receive ; jump to receiving mode
    jnz send ; if yes jmp to send mode

    send:
    mov ah, 0 ; clear the keyboard buffer
    int 16h
    mov VALUE, al ; ascii code in al
    cmp al, 0Dh ; IF ENTER
    jnz cont
    jz new_line_send

    new_line_send:
    cmp Y_SENDER, 12 ; check if out of range
    jz overflow
    jnz increment

    overflow:
    SCROLL_UPPER_MACRO
    jmp print

    increment:
    inc Y_SENDER ; if new line then go to the next line
    mov X_SENDER, 0

    cont:
    ; setting the cursor
    SET_CURSOR_MACRO X_SENDER, Y_SENDER
    cmp X_SENDER, 79 ; if the x goes to 79 the most right of screen check where is y
    jz checkY
    jnz print

    checkY:
    cmp Y_SENDER, 12 ; if y goes to the lower bound of the first half of the screen go to clear the upper half of screen
    jnz print
    SCROLL_UPPER_MACRO
    mov Y_SENDER, 12
    mov X_SENDER, 0 ; set the cursor manually to 0, Y
    SET_CURSOR_MACRO X_SENDER, Y_SENDER

    print:
    mov ah, 2 ; printing the char
    mov dl, VALUE
    int 21h

    send_status:
    mov dx, 3FDH ; Line Status Register
    again:
    in al, dx ; Read Line Status
    test al, 00100000b
    jz receive ; Not empty

    mov dx, 3F8H ; Transmit data register
    mov al, VALUE ; put the data into al
    out dx, al ; sending the data

    cmp al, 27 ; if the key was esc terminate the program and this check must be after the send is done
    jz start_menu_bridge
    SAVE_CURSOR_SENDER_MACRO ; we need to save the cursor here
    jmp chat_loop ; loop again

    start_menu_bridge:
    jmp start_menu

    send_bridge:
    jmp send

    receive:
    mov ah, 1 ; check if there is key pressed then go to the sending mode
    int 16h
    jnz send_bridge

    read_status:
    mov dx, 3FDH ; Line Status Register
    in al, dx
    test al, 1
    jz receive

    read:
    mov dx, 03F8H
    in al, dx
    mov VALUE, al ; check if the received data is sec key then terminate the program
    cmp VALUE, 27 ; if the key was esc exit chat
    jz start_menu_bridge

    cmp VALUE, 0Dh ; check if the key is enter
    jnz cont_receive
    jz new_line_receive

    new_line_receive:
    cmp Y_RECEIVE, 24
    jz overflow_receive
    jnz increment_receive

    overflow_receive:
    SCROLL_LOWER_MACRO
    jmp print_receive ; print the char

    increment_receive:
    inc Y_RECEIVE
    mov X_RECEIVE, 0

    cont_receive:
    SET_CURSOR_MACRO X_RECEIVE, Y_RECEIVE
    cmp X_RECEIVE, 79 ; if the x goes to 79 the most right of screen check where is y
    jz checkYR
    jnz print_receive

    checkYR:
    cmp Y_RECEIVE, 24
    jnz print_receive
    SCROLL_LOWER_MACRO
    mov Y_RECEIVE, 24
    mov X_RECEIVE, 0
    SET_CURSOR_MACRO X_RECEIVE, Y_RECEIVE

    print_receive:
    mov ah, 2 ; printing the char
    mov dl, VALUE
    int 21h
    SAVE_CURSOR_RECEIVER_MACRO ; we need to save the cursor here
    jmp chat_loop

DETECT_CHAT_PROC endp

exit_game:
    mov ah, 4ch
    int 21h
    ret

main endp
end main
