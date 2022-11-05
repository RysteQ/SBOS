compare_si_di:
    pusha

    compare_si_di_loop:
        ; check if the end of the string has been reached
        cmp [si], byte NULL_TERMINATOR
        je compare_si_di_exit_extra_check

        mov al, byte [di]
        cmp al, byte [si]
        jne compare_si_di_exit_false

        ; increment the pointers
        inc si
        inc di

        ; loop back
        jmp compare_si_di_loop

    compare_si_di_exit_extra_check:
        ; check if the end of both strings is equal or not
        cmp [di], byte NULL_TERMINATOR
        je compare_si_di_exit_true
        jmp compare_si_di_exit_false

    compare_si_di_exit_false:
        mov [si_di_strings_equal], byte FALSE
        popa
        ret

    compare_si_di_exit_true:
        mov [si_di_strings_equal], byte TRUE
        popa
        ret

si_di_strings_equal: db 0

TRUE equ 1
FALSE equ 0