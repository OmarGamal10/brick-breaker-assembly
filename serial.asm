   start_multi:        
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
    

    ;start sending and recieving
                      call                       MULTI_PROC



MULTI_PROC proc

    check_loop:        
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
                      jmp                        check_loop                                                                                   ; loop again

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

                      jmp                        check_loop
   
DETECT_CHAT_PROC endp

    exit_game:        
                      mov                        ah, 4ch
                      int                        21h
                      ret

main endp
end main