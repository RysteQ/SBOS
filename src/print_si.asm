print_si:
    pusha

    mov ah, 0x0e

    print_si_print_char:
        mov al, byte [si]
        cmp al, byte NULL_TERMINATOR
        je print_si_exit

        inc si
        int 0x10

        cmp al, NEW_LINE
        je print_si_new_line

        jmp print_si_print_char

    print_si_new_line:
        mov al, byte CARRIAGE_RETURN
        int 0x10

        jmp print_si_print_char

    print_si_exit:
        popa
        ret