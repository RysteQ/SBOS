get_input:
    pusha

    ; prepare the registers
    mov si, input_buffer
    mov di, previous_command
    xor dx, dx
    xor cl, cl
    mov cl, byte INPUT_BUFFER_SIZE
    dec cl

    get_char:
        ; get the character
        mov ah, byte 0x00
        int 0x16

        ; check if the user pressed the enter button
        cmp al, byte CARRIAGE_RETURN
        je exit_get_input

        ; check if the user pressed the backspace button
        cmp al, byte BACKSPACE
        je handle_backspace_input

        cmp ah, byte UP_ARROW_ASCII_CODE
        je execute_previous_command

        ; check if the maximum allowed string size was reached or not
        cmp dh, byte cl
        je get_char

        ; save the input in the si and di registers
        mov [si], byte al
        mov [di], byte al
        inc si
        inc di
        inc dl
        inc dh

        ; display the input
        mov ah, byte 0x0e
        int 0x10
        mov ah, byte 0x00

        ; start all over again
        jmp get_char

    handle_backspace_input:
        ; check if the backspace is valid
        cmp dl, byte 0
        je get_char

        ; delete the previous character from the screen
        mov ah, byte 0x0e
        int 0x10
        mov al, byte SPACE
        int 0x10
        mov al, byte BACKSPACE
        int 0x10

        ; remove the character from memory
        dec si
        dec di
        dec dl
        dec dh

        mov [si], byte NULL_TERMINATOR

        jmp get_char

    execute_previous_command:
        ; copy the previous command from si to di and execute it
        call new_line
        call copy_di_to_si
        call command_line_si

        jmp main_loop

    exit_get_input:
        mov [si], byte NULL_TERMINATOR
        mov [di], byte NULL_TERMINATOR

        call new_line

        popa
        ret

input_buffer: times 60 db 0
previous_command_buffer: times 60 db 0

INPUT_BUFFER_SIZE equ 60