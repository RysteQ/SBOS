[org 0x7e00]
[bits 16]

; print out the welcome message
mov si, welcome_message
call clear_screen
call print_si

main_loop:
    mov si, command_prompt
    call print_si
    call get_input
    call new_line
    call new_line

    mov si, input_buffer
    call check_command

    jmp main_loop

welcome_message: db "Welcome to SBOS", NEW_LINE, "For help type help", NEW_LINE, NEW_LINE, NULL_TERMINATOR
command_prompt: db "Command -> ", NULL_TERMINATOR

%include "print_si.asm"
%include "get_input.asm"
%include "compare_si_di.asm"
%include "commands.asm"
%include "new_line.asm"
%include "clear_screen.asm"
%include "notepad.asm"
%include "brainfuck.asm"

NULL_TERMINATOR equ 0
NEW_LINE equ 10
CARRIAGE_RETURN equ 13