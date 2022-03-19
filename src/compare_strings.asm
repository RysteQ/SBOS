compare_si_di_strings:
    pusha

    compare_si_di_character:
        mov ah, byte [si]
        mov al, byte [di]

        cmp ah, byte al
        jne exit_compare_si_di_strings_false

        cmp ah, byte NULL_TERMINATOR
        je exit_compare_si_di_strings_true

        inc si
        inc di

        jmp compare_si_di_character

    exit_compare_si_di_strings_false:
        mov [equal], byte FALSE

        popa
        ret

    exit_compare_si_di_strings_true:
        mov [equal], byte TRUE

        popa
        ret

equal: db FALSE

FALSE equ 0
TRUE equ 1