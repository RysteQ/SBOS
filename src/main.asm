[org 0x7e00]
[bits 16]

; clear the screen and show the welcome message
call clear_screen
mov si, welcome_message
call print_si

main_loop:
    ; get the user input and analyze the command
    mov si, prompt
    call print_si
    call get_input
    call command_line_si

    jmp main_loop

jmp $

NULL_TERMINATOR equ 0
NEW_LINE equ 10
CARRIAGE_RETURN equ 13
BACKSPACE equ 8
SPACE equ 32
UP_ARROW_ASCII_CODE equ 72
DOWN_ARROW_ASCII_CODE equ 80
LEFT_ARROW_ASCII_CODE equ 75
RIGHT_ARROW_ASCII_CODE equ 77  
ESCAPE equ 27
TAB_KEY equ 9

welcome_message: db "Welcome to SBOS", NEW_LINE, NEW_LINE, NULL_TERMINATOR
prompt: db "> ", NULL_TERMINATOR

%include "print.asm"
%include "input.asm"
%include "new_line.asm"
%include "compare_strings.asm"
%include "commands.asm"
%include "copy_di_to_si.asm"
%include "single_char_input.asm"
%include "notepad.asm"
%include "clear_screen.asm"
%include "bf_interpreter.asm"