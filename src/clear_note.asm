clear_note:
    pusha

    ; display the welcome message
    mov si, clear_note_welcome_message
    call print_si

    clear_note_select_note_loop:
        xor ah, byte ah
        int 0x16

        sub al, byte 48

        ; select the proper buffer
        cmp al, byte 1
        je clear_note_select_buffer_one
        cmp al, byte 2
        je clear_note_select_buffer_two
        cmp al, byte 3
        je clear_note_select_buffer_three

        jmp clear_note_select_note_loop

    clear_note_select_buffer_one:
        mov si, notepad_buffer_one
        jmp clear_note_clear_buffer

    clear_note_select_buffer_two:
        mov si, notepad_buffer_two
        jmp clear_note_clear_buffer
        
    clear_note_select_buffer_three:
        mov si, notepad_buffer_three
        jmp clear_note_clear_buffer
        
    clear_note_clear_buffer:
        mov cx, word NOTEPAD_BUFFER_LIMIT

        ; display the selected buffer
        mov ah, byte 0x0e
        add al, byte 48
        int 0x10

        clear_note_clear_buffer_loop:
            mov [si], byte NULL_TERMINATOR

            inc si
            dec cx

            cmp cx, word 0
            jne clear_note_clear_buffer_loop

    clear_note_exit:
        call new_line
        call new_line

        popa
        ret

clear_note_welcome_message: db "Note to clear (1 - 3) -> ", NULL_TERMINATOR