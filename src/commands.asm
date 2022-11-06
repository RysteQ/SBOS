check_command:
    pusha

    mov di, help_command
    call compare_si_di
    cmp [si_di_strings_equal], byte TRUE
    je help_command_label

    mov di, notepad_command
    call compare_si_di
    cmp [si_di_strings_equal], byte TRUE
    je notepad_command_label

    mov di, clear_screen_command
    call compare_si_di
    cmp [si_di_strings_equal], byte TRUE
    je clear_command_label

    mov di, brainfuck_command
    call compare_si_di
    cmp [si_di_strings_equal], byte TRUE
    je brainfuck_command_label

    mov di, clear_note_command
    call compare_si_di
    cmp [si_di_strings_equal], byte TRUE
    je clear_note_label

    mov di, copy_note_command
    call compare_si_di
    cmp [si_di_strings_equal], byte TRUE
    je copy_note_label

    jmp unknown_command

    check_command_exit:
        popa
        ret

help_command_label:
    ; display all available commands
    mov si, help_command
    call print_si
    call new_line

    mov si, notepad_command
    call print_si
    call new_line

    mov si, clear_screen_command
    call print_si
    call new_line

    mov si, brainfuck_command
    call print_si
    call new_line

    mov si, clear_note_command
    call print_si
    call new_line

    mov si, copy_note_command
    call print_si
    call new_line

    call new_line

    jmp check_command_exit

notepad_command_label:
    call notepad
    jmp check_command_exit

clear_command_label:
    call clear_screen
    jmp check_command_exit

brainfuck_command_label:
    call brainfuck
    jmp check_command_exit

clear_note_label:
    call clear_note
    jmp check_command_exit

copy_note_label:
    call copy_note
    jmp check_command_exit

unknown_command:
    mov si, unknown_command_message_start
    call print_si
    mov si, input_buffer
    call print_si

    call new_line
    mov si, unknown_command_message_end
    call print_si

    jmp check_command_exit

help_command: db "help", NULL_TERMINATOR
notepad_command: db "notepad", NULL_TERMINATOR
clear_screen_command: db "clear", NULL_TERMINATOR
brainfuck_command: db "brainfuck", NULL_TERMINATOR
clear_note_command: db "clear note", NULL_TERMINATOR
copy_note_command: db "copy note", NULL_TERMINATOR

unknown_command_message_start: db "Unknown command ", NULL_TERMINATOR
unknown_command_message_end: db "Type help to display all available commands", NEW_LINE, NULL_TERMINATOR