print_si:
    pusha

    mov ah, 0x0e
    mov al, byte [si]

    print_char:
        ; check if we have reached the end if the string
        cmp al, byte NULL_TERMINATOR
        je exit_print_si

        ; check for a \n character
        cmp al, byte NEW_LINE
        je print_new_line

        ; print the character
        int 0x10

        inc si
        mov al, byte [si]
        
        jmp print_char

    print_new_line:
        ; print a new line
        int 0x10
        mov al, byte 13
        int 0x10

        inc si
        mov al, byte [si]

        jmp print_char

    exit_print_si:
        popa
        ret