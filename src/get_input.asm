get_input:
    pusha

    ; get the current cursor position (smallest allowed) and save it for later use
    pusha
    mov ah, byte 0x03
    int 0x10
    mov [lowest_column_allowed], byte dl
    popa

    ; clean the input buffer
    call get_input_clean_input_buffer

    ; ch = current maximum length, cl = current cursor position
    mov si, input_buffer
    xor cx, cx

    get_input_get_char:
        mov ah, byte 0x00
        int 0x16

        ; check if the end of the buffer has been reached
        cmp ah, byte ENTER_BUTTON
        je get_input_exit
        cmp ch, byte INPUT_BUFFER_SIZE
        je get_input_get_char_maximum_length

        ; check for special keys
        cmp ah, byte LEFT_ARROW
        je get_input_get_char_left_arrow
        cmp ah, byte RIGHT_ARROW
        je get_input_get_char_right_arrow
        cmp al, byte NULL_TERMINATOR
        je get_input_get_char

        ; check if the character is inside the string and not on the end of the buffer
        cmp ch, byte cl
        jne get_input_get_char_mid_char

        ; check for the backspace key
        cmp al, byte BACKSPACE
        je get_input_get_char_backspace

        ; print the character back to the user
        mov ah, 0x0e
        int 0x10

        ; if the character was not a left / right key arrow or the enter button then save the result and increment
        ; the maximum column, current cursor position and si pointer
        mov [si], byte al
        inc si
        inc cl
        inc ch

        jmp get_input_get_char

        get_input_get_char_maximum_length:
            ; allow the backspace even if the maximum length has been reached
            cmp al, byte BACKSPACE
            je get_input_get_char_backspace
            jmp get_input_get_char

        get_input_get_char_backspace:
            ; update the registers
            dec si
            dec cl
            dec ch
    
            ; remove the byte and save the null terminator at its place
            mov [si], byte NULL_TERMINATOR

            ; remove the character from screen
            mov ah, byte 0x0e
            int 0x10
            mov al, byte SPACE_KEY
            int 0x10
            mov al, byte BACKSPACE
            int 0x10

            jmp get_input_get_char

        get_input_get_char_mid_char:
            ; check if there is any more room left
            cmp cx, INPUT_BUFFER_SIZE
            je get_input_get_char

            cmp al, byte BACKSPACE
            je get_input_get_char_mid_char_backspace
            jne get_input_get_char_mid_char_not_backspace

            get_input_get_char_mid_char_backspace:
                cmp cl, byte [lowest_column_allowed]
                je get_input_get_char

                ; keep track of the bytes moved
                push word cx
                xor cl, cl

                get_input_get_char_mid_char_backspace_loop:
                    ; remove / move the byte / bytes
                    mov al, byte [si]
                    dec si
                    mov [si], byte al
                    inc si
                    inc cl

                    ; check if the end of the buffer has been reached
                    cmp [si], byte NULL_TERMINATOR
                    je get_input_get_char_mid_char_backspace_exit

                    inc si
                    jmp get_input_get_char_mid_char_backspace_loop

                get_input_get_char_mid_char_backspace_exit:
                    get_input_get_char_mid_char_backspace_exit_loop:
                        dec si
                        dec cl

                        cmp cl, byte 0
                        jne get_input_get_char_mid_char_backspace_exit_loop

                    ; move the cursor one column to the left
                    pusha
                    mov ah, byte 0x03
                    mov bh, byte 0
                    int 0x10
                    mov ah, byte 0x02
                    dec dl
                    int 0x10

                    ; print the current string and remove the last character
                    call print_si
                    push word ax
                    mov ah, byte 0x0e
                    mov al, byte SPACE_KEY
                    int 0x10

                    ; move the cursor back
                    pop word ax
                    int 0x10

                    popa

                    pop word cx

                    dec ch
                    dec cl

                    jmp get_input_get_char

            get_input_get_char_mid_char_not_backspace:
                ; push the si register to the stack
                pusha
                xor cl, cl

                get_input_get_char_mid_char_not_backspace_loop:
                    ; display the current character
                    mov ah, byte 0x0e
                    int 0x10

                    ; change the byte at the input buffer
                    mov ah, byte [si]
                    mov [si], byte al
                    mov al, byte ah

                    ; check if the end of the string has been reached
                    inc si
                    inc cl
                    cmp [si], byte NULL_TERMINATOR
                    jne get_input_get_char_mid_char_not_backspace_loop

                    ; display the last character
                    mov ah, byte 0x0e
                    int 0x10

                    ; move the last byte in place and top it all off with the null terminator
                    mov [si], byte al
                    inc si
                    mov [si], byte NULL_TERMINATOR

                get_input_get_char_mid_char_not_backspace_exit:
                    ; pop the si register before going back to the main subroutine
                    get_input_get_char_mid_char_not_backspace_exit_loop:
                        ; move the cursor backwards
                        mov ah, byte 0x0e
                        mov al, byte BACKSPACE
                        int 0x10

                        dec cl

                        cmp cl, byte 0
                        jne get_input_get_char_mid_char_not_backspace_exit_loop

                    popa

                    inc si
                    inc cl
                    inc ch

                    jmp get_input_get_char

        get_input_get_char_left_arrow:
            pusha

            ; check if the lower column limit has been reached            
            mov ch, byte [lowest_column_allowed]
            cmp cl, ch
            je get_input_get_char_left_arrow_exit

            ; move the cursor one columb backwards
            mov ah, byte 0x0e
            mov al, byte BACKSPACE
            int 0x10

            get_input_get_char_left_arrow_exit:
                popa

                ; decrement the cursor position and the input buffer pointer
                dec si
                dec cl

                jmp get_input_get_char

        get_input_get_char_right_arrow:
            ; check if the maximum column limit has been reached
            cmp ch, byte cl
            je get_input_get_char

            pusha

            ; mov to the next column
            mov ah, byte 0x0e
            mov al, byte [si]
            int 0x10

            get_input_get_char_right_arrow_exit:
                popa

                ; increment the cursor position and the input buffer pointer
                inc si
                inc cl

                jmp get_input_get_char

    get_input_clean_input_buffer:
        mov cl, byte INPUT_BUFFER_SIZE
        add cl, byte 2
        mov si, input_buffer

        get_input_clean_input_buffer_loop:
            mov [si], byte NULL_TERMINATOR
            inc si
            dec cl

            cmp cl, byte 0
            jne get_input_clean_input_buffer_loop
            ret

    get_input_exit:
        popa
        ret

input_buffer: times 42 db 0
lowest_column_allowed: db 0

; Always keep this to the size of the input buffer - 2
INPUT_BUFFER_SIZE equ 40

LEFT_ARROW equ 75
RIGHT_ARROW equ 77
BACKSPACE EQU 8
ENTER_BUTTON equ 28
SPACE_KEY equ 32