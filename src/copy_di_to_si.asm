copy_di_to_si:
    pusha

    copy_di_to_si_loop:
        ; check if we are done copying the contents of the di register to the di register
        cmp [di], byte NULL_TERMINATOR
        je exit_copy_di_to_si

        ; copy the contents of di to si
        mov al, byte [di]
        mov [si], byte al
        inc si
        inc di

        ; start all over again
        jmp copy_di_to_si_loop

    exit_copy_di_to_si:
        ; save the null terminator
        mov [si], byte NULL_TERMINATOR

        ; return
        popa
        ret