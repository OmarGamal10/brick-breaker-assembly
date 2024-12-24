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
mov ah,3h
mov bh,0h
int 10h
mov X_SENDER,dl
mov Y_SENDER,dh
ENDM SAVE_CURSOR_SENDER_MACRO  

SAVE_CURSOR_RECEIVER_MACRO MACRO
mov ah,3h
mov bh,0h
int 10h
mov X_RECEIVE,dl
mov Y_RECEIVE,dh
ENDM SAVE_CURSOR_RECEIVER_MACRO 


CLEAR_UPPER_MACRO MACRO
   
mov ax,060Dh
mov bh,03h
mov ch,0       
mov cl,0       
mov dh,12    
mov dl,79
int 10h 
  
ENDM CLEAR_UPPER_MACRO 


SCROLL_UPPER_MACRO MACRO
   
mov ah,6
mov al , 1
mov bh,03h
mov ch,0       
mov cl,0       
mov dh,12    
mov dl,79
int 10h 
  
ENDM SCROLL_UPPER_MACRO 


SCROLL_LOWER_MACRO MACRO
   
mov ah,6
mov al , 1
mov bh,30h
mov ch,13     
mov cl,0        
mov dh,24    
mov dl,79 
int 10h 
  
ENDM SCROLL_LOWER_MACRO 

CLEAR_LOWER_MACRO MACRO
   
mov ax,060Ch
mov bh,30h
mov ch,13     
mov cl,0        
mov dh,24    
mov dl,79 
int 10h 
  
ENDM CLEAR_LOWER_MACRO


SET_CURSOR_MACRO MACRO x, y ; IDK why but sometimes using macro is a must to avoid errors from PROC
    mov ah, 2
    mov bh, 0
    mov dl, x
    mov dh, y
    int 10h
ENDM SET_CURSOR_MACRO


;-----------------------------------------------------------------------------------------------------
.model small
.data
    ; ball data
                     EXTRN  BALL_X:WORD, BALL_Y:WORD, BALL_SIZE:WORD, BALL_VELOCITY_X:WORD, BALL_VELOCITY_Y:WORD
    ; bar data
                     EXTRN  BAR_X:WORD, BAR1_Y:WORD,BAR2_Y:WORD, BAR_LENGTH:WORD, BAR_HEIGHT:WORD, BAR_SPEED:WORD, BAR_COLOR:BYTE
    ; brick data
                     EXTRN  BRICK_X:WORD, BRICK_Y:WORD, INITIAL_X:WORD, INITIAL_Y:WORD, NUM_BRICKS_PER_LINE:WORD, NUM_BRICKS_PER_COLUMN:WORD, BRICK_WIDTH:WORD, BRICK_HEIGHT:WORD, COLOR_BRICK:BYTE , Gap:WORD, BRICKS_STATUS:BYTE , CURRENT_SCORE:WORD

    ; Main Menu Variables

                     PUBLIC LIVES_COUNT
    TITLE_VARIABLE   db     "BRICK BREAKER - MAIN MENU$"
    OPTION1_VARIABLE db     "1. Start Game$"
    OPTION2_VARIABLE db     "2. Chat$"
    OPTION3_VARIABLE db     "3. Exit$"
    SCORE_MESSAGE    db     "SCORE: $"
    LIVES_MESSAGE    db     "LIVES: $"

    SELECTED_OPTION  db     0
    NO_OF_OPTIONS    db     2                                                                                                                                                                                                                              ; Number of menu options - 1
    CLEAR            db     " $"
    HEART            db     3                                                                                                                                                                                                                              ; Heart symbol is 3 IDK how but it works
    LIVES_COUNT      db     50
    temp             db     0
    ; Chat Variables
    VALUE            db     ?                                                                                                                                                                                                                              ;VALUE which will be sent or recieved by user
    Y_SENDER         db     0                                                                                                                                                                                                                              ;y position of sending initial will be 0
    X_SENDER         db     0                                                                                                                                                                                                                              ;x position of sending initail wiil be 0
    X_RECEIVE        db     0                                                                                                                                                                                                                              ;x position of recieving initial will be 0
    Y_RECEIVE        db     0Dh                                                                                                                                                                                                                            ;y position of recieving initial wil be D because of lower part of screen
.stack 100h
.code
    ;bar procedures
                      EXTRN                      DRAW_BAR:NEAR, CLEAR_BAR:NEAR, WAIT_FOR_VSYNC:NEAR, HANDLE_BAR_INPUT:FAR

    ;ball procedures
                      EXTRN                      DRAW_BALL:NEAR, CLEAR_BALL:NEAR, MOVE_BALL:NEAR , CHECK_TIME:NEAR , CHECK_COLLISION:NEAR

    ;brick procedures
                      EXTRN                      DRAW_BRICK:NEAR,  DRAW_BRICKS:NEAR

                      PUBLIC                     main


CLEAR_SCREEN_PROC proc far
                      mov                        ah, 0
                      mov                        al, 3
                      int                        10h
                      ret
CLEAR_SCREEN_PROC endp


DISPLAY_TEXT_PROC proc far                                                                                                                   ; Display text offset in dx
                      mov                        ah, 9
                      int                        21h
                      ret
DISPLAY_TEXT_PROC endp

SET_CURSOR_PROC proc far                                                                                                                     ; Set cursot at position x in dl and y in dh
                      mov                        ah,2
                      int                        10h
                      ret
SET_CURSOR_PROC endp

PRINT_HEART_PROC proc far
                      push                       cx
                      mov                        al , HEART
                      mov                        ah,9
                      mov                        cx,1h
                      mov                        bl,04h
                      int                        10h
                      pop                        cx
                      ret
PRINT_HEART_PROC endp

DISPLAY_MENU_PROC proc far



    first_option:     
                      mov                        dl, 5                                                                                       ; Column position for all items
                      mov                        dh, 5                                                                                       ; Row position for first item
                      call                       SET_CURSOR_PROC

                      mov                        dx, offset OPTION1_VARIABLE
                      call                       DISPLAY_TEXT_PROC

    second_option:    
                      mov                        dl, 5                                                                                       ; Column position for all items
                      mov                        dh, 8                                                                                       ; Row position for second item
                      call                       SET_CURSOR_PROC

                      mov                        dx, offset OPTION2_VARIABLE
                      call                       DISPLAY_TEXT_PROC

    third_option:     
                      mov                        dl, 5                                                                                       ; Column position for all items
                      mov                        dh, 11                                                                                      ; Row position for second item
                      call                       SET_CURSOR_PROC

                      mov                        dx, offset OPTION3_VARIABLE
                      call                       DISPLAY_TEXT_PROC

                      ret
DISPLAY_MENU_PROC endp


PRINT_CURSOR_PROC proc far
    ; Print the cursor selector
    ; Clear all selectors
                      mov                        dl, 3
                      mov                        dh, 5
                      call                       SET_CURSOR_PROC
                      mov                        dx, offset CLEAR
                      call                       DISPLAY_TEXT_PROC

                      mov                        dl, 3
                      mov                        dh, 8
                      call                       SET_CURSOR_PROC
                      mov                        dx, offset CLEAR
                      call                       DISPLAY_TEXT_PROC

                      mov                        dl, 3
                      mov                        dh, 11
                      call                       SET_CURSOR_PROC
                      mov                        dx, offset CLEAR
                      call                       DISPLAY_TEXT_PROC



                      cmp                        SELECTED_OPTION , 0
                      je                         y_first_option
                      cmp                        SELECTED_OPTION , 1
                      je                         y_second_option
                      cmp                        SELECTED_OPTION , 2
                      je                         y_third_option

    y_first_option:   
                      mov                        dl, 3
                      mov                        dh , 5
                      jmp                        print_cursor

    y_second_option:  
                      mov                        dl, 3
                      mov                        dh , 8
                      jmp                        print_cursor

    y_third_option:   
                      mov                        dl, 3
                      mov                        dh , 11
                      jmp                        print_cursor

    print_cursor:     
                      call                       SET_CURSOR_PROC
                      mov                        ah,9
                      mov                        al,'>'
                      mov                        cx,1h
                      mov                        bl,03h
                      int                        10h
                      ret
PRINT_CURSOR_PROC endp

main proc far
                      mov                        ax, @data
                      mov                        ds, ax

    start_menu:       
                      mov                        ah,0
                      mov                        al,13h
                      int                        10h

    ; call CLEAR_SCREEN_PROC ;NOT NEEDED
    print_start_menu: 
    ; Set Cursor Center for Title
                      mov                        dl,7
                      mov                        dh,2
                      call                       SET_CURSOR_PROC

    ; Display the title
                      mov                        dx, offset TITLE_VARIABLE
                      call                       DISPLAY_TEXT_PROC
    ; Display Menu
                      call                       DISPLAY_MENU_PROC

    menu_loop:        

    ; Read keyboard input for navigation
                      call                       PRINT_CURSOR_PROC

                      mov                        ah,0
                      int                        16h

                      cmp                        ah, 48h                                                                                     ; Arrow Up key
                      je                         navigate_up
                      cmp                        ah, 50h                                                                                     ; Arrow Down key
                      je                         navigate_down
                      cmp                        ah, 1Ch                                                                                     ; Enter key
                      je                         select_option
                      jmp                        menu_loop

    navigate_up:      
                      dec                        SELECTED_OPTION
                      cmp                        SELECTED_OPTION, 0
                      jl                         reset_to_bottom
                      jmp                        menu_loop

    navigate_down:    
                      inc                        SELECTED_OPTION
                      mov                        al , NO_OF_OPTIONS
                      cmp                        SELECTED_OPTION, al
                      jg                         reset_to_top
                      jmp                        menu_loop

    reset_to_top:     
                      mov                        SELECTED_OPTION, 0
                      jmp                        menu_loop

    reset_to_bottom:  
                      mov                        al , NO_OF_OPTIONS
                      mov                        SELECTED_OPTION, al
                      jmp                        menu_loop

    select_option:    
                      cmp                        SELECTED_OPTION, 0
                      je                         start_game
                      cmp                        SELECTED_OPTION, 1
                      jmp                        far ptr show_chat
                      cmp                        SELECTED_OPTION, 2
                      jmp                        far ptr exit_game
                      jmp                        menu_loop

    start_game:       
    ;draw initial screen
                      CLEAR_SCREEN_MACRO
    
 
                      mov                        ax, 13h
                      int                        10h
    

                      call                       DRAW_BRICKS
                      call                       DRAW_BAR
                      call                       DRAW_BALL

    ;; Set Cursor for Score
                      mov                        dl, 1
                      mov                        dh, 0
                      call                       SET_CURSOR_PROC
    ;; Display Score Message
                      mov                        dx, offset SCORE_MESSAGE
                      call                       DISPLAY_TEXT_PROC

                      mov                        dl, 25
                      mov                        dh, 0
                      call                       SET_CURSOR_PROC

                      mov                        dx, offset LIVES_MESSAGE
                      call                       DISPLAY_TEXT_PROC

                      
    ; Reset Y position


    ; ;; Set Cursor for Lives
    ;                   mov                        cl , LIVES_COUNT
    ;                   mov                        dl , 30
    ;                   mov                        dh , 0
    ; lives_loop:
    ;                   add                        dl,2
    ;                   call                       SET_CURSOR_PROC
    ;                   call                       PRINT_HEART_PROC
    ;                   loop                       lives_loop

    ;; Clear previous hearts first
    ;                   mov                        dl, 30                                                                                      ; Start X position
    ;                   mov                        dh, 0                                                                                       ; Y position
    ;                   mov                        cx, 3                                                                                       ; Maximum hearts to clear
    ; clear_hearts:
    ;                   add                        dl, 2
    ;                   call                       SET_CURSOR_PROC
    ;                   mov                        al, ' '                                                                                     ; Space character
    ;                   mov                        ah, 0eh                                                                                     ; BIOS teletype
    ;                   int                        10h
    ;                   loop                       clear_hearts

    ; ;; Print new hearts based on LIVES_COUNT
    ;                   mov                        cl, LIVES_COUNT
    ;                   mov                        dl, 30                                                                                      ; Reset X position
    ;                   mov                        dh, 0                                                                                       ; Reset Y position
    ; lives_loop:
    ;                   add                        dl, 2
    ;                   call                       SET_CURSOR_PROC
    ;                   call                       PRINT_HEART_PROC
    ;                   loop                       lives_loop

    ;   mov                        dl, 32
    ;   mov                        dh, 0
    ;   call                       SET_CURSOR_PROC
    ;   call                       PRINT_HEART_PROC

    ;   mov                        dl, 34
    ;   mov                        dh, 0
    ;   call                       SET_CURSOR_PROC
    ;   call                       PRINT_HEART_PROC
    
    ;   mov                        dl, 36
    ;   mov                        dh, 0
    ;   call                       SET_CURSOR_PROC
    ;   call                       PRINT_HEART_PROC

    game_loop:        
                      mov                        ah, 1
                      int                        16h

    ; Print CURRENT_SCORE
                      mov                        ax, CURRENT_SCORE
    ;; Convert to ascii
                      aam
                      add                        al, '0'
                      add                        ah ,'0'

    ; Print al
                      mov                        temp , ah
                      mov                        dl, 8
                      mov                        dh, 0
                      call                       SET_CURSOR_PROC

                      mov                        ah,9
                      mov                        cx,1h
                      mov                        bl,03h
                      int                        10h

    ; Print ah
                      mov                        al , temp
                      mov                        dl, 7
                      mov                        dh, 0
                      call                       SET_CURSOR_PROC

                      mov                        ah,9
                      mov                        cx,1h
                      mov                        bl,03h
                      int                        10h


    ;TODO                       Print LIVES_COUNT when I get them ANAS IBRAHEM
                      mov                        al , LIVES_COUNT
                      add                        al , '0'
                      mov                        dl, 31
                      mov                        dh, 0
                      call                       SET_CURSOR_PROC

                      mov                        ah,9
                      mov                        cx,1h
                      mov                        bl,04h
                      int                        10h


                      mov                        ah,1                                                                                        ; Check if a key is pressed
                      int                        16h
                      cmp                        al, 27d                                                                                     ; ESC key
                      jnz                        continue_game
                      CLEAR_SCREEN_MACRO
                      jmp                        far ptr start_menu
    continue_game:    

    
                      call                       HANDLE_BAR_INPUT
                      call                       CHECK_TIME                                                                                  ; Check timing first
                      call                       MOVE_BALL                                                                                   ; Includes clear, update, collision, draw
                      jmp                        game_loop

    show_chat:        
                      call                       CLEAR_SCREEN_PROC

                      mov                        dx,3fbh                                                                                     ; Line cont_receiveol Register
                      mov                        al,10000000b
                      out                        dx,al

    ;Set up the baud rate
                      mov                        dx,3f8h
                      mov                        al,0ch
                      out                        dx,al

                      mov                        dx,3f9h
                      mov                        al,00h
                      out                        dx,al

    ;Set port configuration
                      mov                        dx,3fbh
                      mov                        al,00011011b
                      out                        dx,al

    ; SetUp the screen
                      mov                        ah, 0                                                                                       ; Ensure text mode
                      mov                        al, 3
                      int                        10h
    
                      CLEAR_UPPER_MACRO
                      CLEAR_LOWER_MACRO

                      mov                        dl , 0
                      mov                        dh , 0
                      Call                       SET_CURSOR_PROC

    ;start sending and recieving
                      call                       DETECT_CHAT_PROC



DETECT_CHAT_PROC proc

    chat_loop:        
    ; Check if there is a key pressed
                      mov                        ah,1
                      int                        16h

                      jz                         short check_recieve                                                                         ; if not then jmp to check_recieve // short to fix out of range

    check_recieve:    
                      jmp                        far ptr recieve                                                                             ; jump to recieving mode

                      jnz                        send                                                                                        ;if yes jmp to send mode


    send:             
                      mov                        ah,0                                                                                        ; clear the keyboard buffer
                      int                        16h

                      mov                        VALUE,al                                                                                    ; ascii code in al
                      CMP                        al,0Dh                                                                                      ; IF ENTER
                      jnz                        cont
                      jz                         new_line_send

    new_line_send:    
                      CMP                        Y_SENDER,12                                                                                 ; check if out of range
                      jz                         overflow
                      jnz                        increment

    overflow:         
                      SCROLL_UPPER_MACRO
                      jmp                        print
    
    increment:        
                      inc                        Y_SENDER                                                                                    ;if new line then go to the next line
                      mov                        X_SENDER,0

    cont:             
    ; setting the cursor
                      SET_CURSOR_MACRO           X_SENDER,Y_SENDER
                      CMP                        X_SENDER,79                                                                                 ; if the x goes to 79 the most right of screen check where is y
                      JZ                         checkY
                      jnz                        print

    checkY:           
                      CMP                        Y_SENDER,12                                                                                 ;if y goes to the lower bound of the first half of the screen go to clear the upper half of screen
                      JNZ                        print
                      SCROLL_UPPER_MACRO
                      mov                        Y_SENDER,12
                      mov                        X_SENDER,0                                                                                  ;set the cursor manually to 0,Y
                      SET_CURSOR_MACRO           X_SENDER,Y_SENDER



    print:            
                      mov                        ah,2                                                                                        ; printing the char
                      mov                        dl,VALUE
                      int                        21h
    
    send_status:      
                      mov                        dx,3FDH                                                                                     ; Line Status Register
    again:            
                      In                         al , dx                                                                                     ;Read Line Status
                      test                       al , 00100000b
                      jz                         recieve                                                                                     ;Not empty

                      mov                        dx , 3F8H                                                                                   ; Transmit data register
                      mov                        al,VALUE                                                                                    ; put the data into al
                      out                        dx , al                                                                                     ; sending the data

                      CMP                        al,27                                                                                       ; if the key was esc terminate the programe and this check must be after the send is done
                      JZ                         start_menu_bridge
                      SAVE_CURSOR_SENDER_MACRO                                                                                               ; we need to save the cursor here
                      jmp                        chat_loop                                                                                   ; loop again

    start_menu_bridge:jmp                        start_menu

    send_bridge:      jmp                        send


    recieve:          
                      mov                        ah,1                                                                                        ;check if there is key pressed then go to the sending mode
                      int                        16h
                      jnz                        send_bridge

    read_status:      
                      mov                        dx , 3FDH                                                                                   ; Line Status Register
                      in                         al , dx
                      test                       al , 1
                      JZ                         recieve

    read:             
                      mov                        dx , 03F8H
                      in                         al , dx
                      mov                        VALUE,al                                                                                    ;check if the recieved data is sec key then terminate the programe
                      CMP                        VALUE,27                                                                                    ; if the key was esc exit chat
                      JZ                         start_menu_bridge

                      CMP                        VALUE,0Dh                                                                                   ;check if the key is enter
                      JNZ                        cont_receive
                      JZ                         new_line_receive

    new_line_receive: 
                      cmp                        Y_RECEIVE,24
                      JZ                         overflow_recieve
                      jnz                        increment_receive

    overflow_recieve: 
                      SCROLL_LOWER_MACRO
                      jmp                        print_receive                                                                               ; print the char

    increment_receive:
                      inc                        Y_RECEIVE
                      mov                        X_RECEIVE,0

    cont_receive:     
                      SET_CURSOR_MACRO           X_RECEIVE,Y_RECEIVE
                      CMP                        X_RECEIVE,79                                                                                ; if the x goes to 79 the most right of screen check where is y
                      JZ                         checkYR
                      jnz                        print_receive

    checkYR:          
                      cmp                        Y_RECEIVE,24
                      jnz                        print_receive
                      SCROLL_LOWER_MACRO
                      mov                        Y_RECEIVE,24
                      mov                        X_RECEIVE,0
                      SET_CURSOR_MACRO           X_RECEIVE,Y_RECEIVE
        
    print_receive:    
                      mov                        ah,2                                                                                        ; printing the char
                      mov                        dl,VALUE
                      int                        21h

                      SAVE_CURSOR_RECEIVER_MACRO                                                                                             ; we need to save the cursor here

                      jmp                        chat_loop
   
DETECT_CHAT_PROC endp

    exit_game:        
                      mov                        ah, 4ch
                      int                        21h
                      ret

main endp
end main