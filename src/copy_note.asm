copy_note:
    pusha

    copy_note_select_source_buffer:
        mov si, copy_note_source_message
        call print_si

        copy_note_select_source_buffer_loop:
            xor ah, byte ah
            int 0x16

            sub al, byte 48

            ; select the right source buffer
            cmp al, byte 1
            je copy_note_select_source_buffer_select_buffer_one
            cmp al, byte 2
            je copy_note_select_source_buffer_select_buffer_two
            cmp al, byte 3
            je copy_note_select_source_buffer_select_buffer_three

            jmp copy_note_select_source_buffer_loop

        copy_note_select_source_buffer_select_buffer_one:
            mov di, notepad_buffer_one
            jmp copy_note_select_target_buffer

        copy_note_select_source_buffer_select_buffer_two:
            mov di, notepad_buffer_two
            jmp copy_note_select_target_buffer

        copy_note_select_source_buffer_select_buffer_three:
            mov di, notepad_buffer_three
            jmp copy_note_select_target_buffer

    copy_note_select_target_buffer:
        ; display the selected source buffer
        mov ah, byte 0x0e
        add al, byte 48
        int 0x10

        ; ask the user for the target buffer
        mov si, copy_note_target_message
        call new_line
        call print_si

        copy_note_select_target_buffer_loop:
            xor ah, byte ah
            int 0x16

            sub al, byte 48

            ; select the right target buffer
            cmp al, byte 1
            je copy_note_select_target_buffer_select_buffer_one
            cmp al, byte 2
            je copy_note_select_target_buffer_select_buffer_two
            cmp al, byte 3
            je copy_note_select_target_buffer_select_buffer_three

            jmp copy_note_select_target_buffer_loop

            copy_note_select_target_buffer_select_buffer_one:
                mov si, notepad_buffer_one
                jmp copy_note_copy_source_to_target

            copy_note_select_target_buffer_select_buffer_two:
                mov si, notepad_buffer_two
                jmp copy_note_copy_source_to_target

            copy_note_select_target_buffer_select_buffer_three:
                mov si, notepad_buffer_three
                jmp copy_note_copy_source_to_target

    copy_note_copy_source_to_target:
        ; display the selected target buffer
        mov ah, byte 0x0e
        add al, byte 48
        int 0x10

        mov cx, word NOTEPAD_BUFFER_LIMIT

        copy_note_copy_source_to_target_loop:
            mov al, byte [di]
            mov [si], byte al

            ; update the pointers and decrement the cx register 
            inc di
            inc si
            dec cx

            cmp cx, word 0
            jne copy_note_copy_source_to_target_loop

    call new_line
    call new_line

    popa
    ret

copy_note_source_message: db "Source (1 - 3) -> ", NULL_TERMINATOR
copy_note_target_message: db "Target (1 - 3) -> ", NULL_TERMINATOR