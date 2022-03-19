command_line_si:
    pusha

    analyze_command:
        ; check if the input is equal to the clear screen command
        mov si, input_buffer
        mov di, COMMAND_CLEAR_SCREEN
        call compare_si_di_strings
        cmp [equal], byte TRUE
        je execute_command_clear_screen

        ; check if the input is equal to the change body colour command
        mov si, input_buffer
        mov di, COMMAND_CHANGE_BODY_COLOUR
        call compare_si_di_strings
        cmp [equal], byte TRUE
        je execute_command_change_body_colour

        ; check if the input is equal to the change body colour command
        mov si, input_buffer
        mov di, COMMAND_DISPLAY_HELP
        call compare_si_di_strings
        cmp [equal], byte TRUE
        je execute_command_display_help

        ; check if the input is equal to the start notepad command
        mov si, input_buffer
        mov di, COMMAND_START_NOTEPAD
        call compare_si_di_strings
        cmp [equal], byte TRUE
        je execute_command_start_notepad

        ; check if the input is equal to the display notes command
        mov si, input_buffer
        mov di, COMMAND_DISPLAY_NOTES
        call compare_si_di_strings
        cmp [equal], byte TRUE
        je execute_command_display_notes

        ; check if the input is equal to the display notes command
        mov si, input_buffer
        mov di, COMMAND_EDIT_NOTE
        call compare_si_di_strings
        cmp [equal], byte TRUE
        je execute_edit_note
        
        ; check if the input is equal to the display notes command
        mov si, input_buffer
        mov di, COMMAND_BF_INTERPRETER
        call compare_si_di_strings
        cmp [equal], byte TRUE
        je execute_bf_interpreter

        jmp execute_false_command

    execute_command_clear_screen:
        ; clear the screen
        call clear_screen

        ; change the colour
        mov ah, byte 0x0b
        mov bh, byte 0x00
        mov bl, byte [COLOUR_CURRENT_COLOUR]
        int 0x10

        ; exit the sub routine
        jmp exit_command_line

    execute_command_change_body_colour:
        ; show all available colours
        call new_line
        call new_line
        mov si, COLOUR_PALLETE_LIST
        call print_si
        call new_line
        call new_line

        ; get the user feedback
        mov si, COLOUR_CHOICE_INPUT_INFORM_MESSAGE
        call print_si
        call get_single_char

        mov bl, byte [single_character_input]
        sub bl, byte 65

        ; check if the inout is valid
        cmp bl, byte 13
        jg execute_command_change_body_colour

        ; apply the changes
        mov ah, byte 0x0b
        mov bh, byte 0x00
        int 0x10

        ; save the colour for future use
        mov [COLOUR_CURRENT_COLOUR], byte bl

        ; exit the sub routine
        jmp exit_command_line
        
    execute_command_display_help:
        ; print all available commands one by one
        mov si, COMMAND_CLEAR_SCREEN
        call print_si
        call new_line
        mov si, COMMAND_CHANGE_BODY_COLOUR
        call print_si
        call new_line
        mov si, COMMAND_DISPLAY_HELP
        call print_si
        call new_line
        mov si, COMMAND_START_NOTEPAD
        call print_si
        call new_line
        mov si, COMMAND_EDIT_NOTE
        call print_si
        call new_line
        mov si, COMMAND_DISPLAY_NOTES
        call print_si
        call new_line
        mov si, COMMAND_BF_INTERPRETER
        call print_si
        call new_line

        call new_line

        ; exit the sub routine
        jmp exit_command_line

    execute_command_start_notepad:
        ; ask the user which note they want to use
        mov si, NOTEPAD_AVAILABLE_NOTES
        call print_si

        ; get the feedback
        call get_single_char

        mov cl, byte [single_character_input]
        sub cl, byte 65

        ; check if the note the user selected is within bounds
        cmp cl, byte 2
        jg execute_command_start_notepad
        mov [selected_notepad_buffer], byte cl

        call clear_notepad_buffer

        ; exit the sub routine
        jmp exit_command_line

    execute_command_display_notes:
        ; display to the user the available options
        mov si, NOTEPAD_AVAILABLE_NOTES
        call print_si
        
        ; get the user input
        call get_single_char
        mov cl, byte [single_character_input]
        sub cl, byte 65

        ; check if the note the user selected is within bounds
        cmp cl, byte 2
        jg execute_command_display_notes
        
        ; load the appropriate buffer
        cmp cl, byte 0
        je execute_command_display_notes_select_notepad_buffer_one
        cmp cl, byte 1
        je execute_command_display_notes_select_notepad_buffer_two

        mov si, notepad_input_buffer_three
        jmp execute_command_display_notes_display_selected_note

        execute_command_display_notes_select_notepad_buffer_one:
            mov si, notepad_input_buffer
            jmp execute_command_display_notes_display_selected_note

        execute_command_display_notes_select_notepad_buffer_two:
            mov si, notepad_input_buffer_two

        execute_command_display_notes_display_selected_note:
            ; print the selected input buffer
            call clear_screen
            call print_si
            call new_line
        
        ; exit the sub routine
        jmp exit_command_line

    execute_edit_note:
        ; ask the user which note the want to edit
        mov si, NOTEPAD_AVAILABLE_NOTES
        call print_si

        ; get the feedback
        call get_single_char

        mov cl, byte [single_character_input]
        sub cl, byte 65

        ; check if the note the user selected is within bounds
        cmp cl, byte 2
        jg execute_edit_note
        mov [selected_notepad_buffer], byte cl

        ; clear the screen beforehand
        call clear_screen
        mov ah, byte 0x0b
        mov bh, byte 0x00
        mov bl, byte [COLOUR_CURRENT_COLOUR]
        int 0x10

        jmp edit_existing_note

    execute_bf_interpreter:
        ; print to the user the available options
        mov si, NOTEPAD_AVAILABLE_NOTES
        call print_si

        ; get the user feedback
        call get_single_char

        mov cl, [single_character_input]
        sub cl, byte 65

        ; check if the input is valid
        cmp cl, byte 2
        jg execute_bf_interpreter

        ; load the correct note as the program
        cmp cl, byte 0
        je load_notepad_buffer_one_bfi

        cmp cl, byte 1
        je load_notepad_buffer_two_bfi
        
        load_notepad_buffer_one_bfi:
            mov si, notepad_input_buffer
            call bf_interpreter
            jmp exit_command_line

        load_notepad_buffer_two_bfi:
            mov si, notepad_input_buffer_two
            call bf_interpreter
            jmp exit_command_line

        ; run the intepreter
        mov si, notepad_input_buffer_three
        call bf_interpreter

        ; return to the main subroutine
        jmp exit_command_line

    execute_false_command:
        ; display the error message and display the command the user has entered
        mov si, unknown_command
        call print_si
        mov si, input_buffer
        call print_si
        call new_line

        ; exit the sub routine
        jmp exit_command_line

    exit_command_line:
        ; pop the register values from the stack and return to the main routine
        popa
        ret

; "variables"
previous_command: times INPUT_BUFFER_SIZE db 0
selected_note: db 0

; all available commands
COMMAND_CLEAR_SCREEN: db "clear", NULL_TERMINATOR
COMMAND_CHANGE_BODY_COLOUR: db "set bgcolour", NULL_TERMINATOR
COMMAND_DISPLAY_HELP: db "help", NULL_TERMINATOR
COMMAND_START_NOTEPAD: db "delete note", NULL_TERMINATOR
COMMAND_DISPLAY_NOTES: db "show note", NULL_TERMINATOR
COMMAND_EDIT_NOTE: db "edit note", NULL_TERMINATOR
COMMAND_BF_INTERPRETER: db "run bfi", NULL_TERMINATOR

; information messages
COLOUR_PALLETE_LIST: db "A) Black", NEW_LINE, "B) Blue", NEW_LINE, "C) Light green", NEW_LINE, "D) Cyan", NEW_LINE, "E) Red", NEW_LINE, "F) Magenta", NEW_LINE, "G) Dark yellow", NEW_LINE, "H) Light gray", NEW_LINE, "I) Dark green", NEW_LINE, "J) Light blue", NEW_LINE, "K) Light green", NEW_LINE, "L) Light cyan", NEW_LINE, "M) Light red", NEW_LINE, "N) Light magenta", NULL_TERMINATOR
COLOUR_CHOICE_INPUT_INFORM_MESSAGE: db "Colour > ", NULL_TERMINATOR
COLOUR_CURRENT_COLOUR: db 0
NOTEPAD_AVAILABLE_NOTES: db NEW_LINE, "Select a note to use (A - C)", NEW_LINE, "> ", NULL_TERMINATOR

; error messages
unknown_command: db "Unknown command ", NULL_TERMINATOR