notepad:
    edit_existing_note:
        pusha

        ; put a null terminator at the end of the buffer
        call select_notepad_buffer
        mov ax, word NOTEPAD_INPUT_BUFFER_SIZE
        dec ax
        add si, ax
        mov [si], byte NULL_TERMINATOR

        ; display the current note
        call select_notepad_buffer
        call print_si

        ; prepare some values for future use
        call select_notepad_buffer
        mov [cursor_x_pos], byte 0
        mov [cursor_y_pos], byte 0

        ; move the cursor at the top right of the screen
        mov ah, 0x02
        mov dx, word 0
        mov bh, byte 0
        int 0x10

        jmp notepad_get_char

    clear_notepad_buffer:
        ; prepare some registers
        mov ax, word NOTEPAD_INPUT_BUFFER_SIZE
        dec ax

        ; select the right input buffer
        cmp [select_notepad_buffer], byte 0
        je select_notepad_buffer_one_to_be_deleted
        cmp [select_notepad_buffer], byte 1
        je select_notepad_buffer_two_to_be_deleted

        mov si, notepad_input_buffer_three

        select_notepad_buffer_one_to_be_deleted:
            mov si, notepad_input_buffer
            jmp clear_notepad_input_buffer_memory

        select_notepad_buffer_two_to_be_deleted:
            mov si, notepad_input_buffer_two
            jmp clear_notepad_input_buffer_memory

        clear_notepad_input_buffer_memory:
            mov [si], byte SPACE

            inc si
            dec ax

            cmp ax, byte 0
            jne clear_notepad_input_buffer_memory

            ; save the null terminator
            mov [si], byte NULL_TERMINATOR

            ret

    select_notepad_buffer:
        ; check which buffer the user selected
        cmp [selected_notepad_buffer], byte 0
        je select_notepad_buffer_number_one

        ; check which buffer the user selected
        cmp [selected_notepad_buffer], byte 1
        je select_notepad_buffer_number_two

        mov si, notepad_input_buffer_three
        ret

        select_notepad_buffer_number_one:
            mov si, notepad_input_buffer
            ret

        select_notepad_buffer_number_two:
            mov si, notepad_input_buffer_two
            ret

    notepad_get_char:
        ; get the input from the user
        mov ah, byte 0x00
        int 0x16

        ; check for special key presses
        cmp al, byte BACKSPACE
        je notepad_backspace

        cmp al, byte CARRIAGE_RETURN
        je notepad_next_line_enter

        cmp al, byte ESCAPE
        je exit_notepad

        cmp al, byte TAB_KEY
        je notepad_tab_key

        cmp ah, byte UP_ARROW_ASCII_CODE
        je notepad_up_arrow

        cmp ah, byte DOWN_ARROW_ASCII_CODE
        je notepad_down_arrow

        cmp ah, byte LEFT_ARROW_ASCII_CODE
        je notepad_left_arrow

        cmp ah, byte RIGHT_ARROW_ASCII_CODE
        je notepad_right_arrow

        ; display the character back to the user
        mov ah, byte 0x0e
        int 0x10

        ; save the character to the si register
        mov [si], byte al
        inc si

        ; update the cursor positions
        inc byte [cursor_x_pos]

        cmp [cursor_x_pos], byte MAXIMUM_X_POS
        jg notepad_next_line

        ; repeat
        jmp notepad_get_char

    notepad_up_arrow:
        ; check if the current cursor position is in bounds
        cmp [cursor_y_pos], byte 0
        je notepad_get_char

        ; update some values
        dec byte [cursor_y_pos]
        sub si, byte MAXIMUM_X_POS

        ; move the cursor one line upwards
        mov ah, byte 0x02
        mov dh, byte [cursor_y_pos]
        mov dl, byte [cursor_x_pos]
        int 0x10

        ; go back to the main sub routine
        jmp notepad_get_char

    notepad_down_arrow:
        ; check if the current cursor position is in bounds
        cmp [cursor_y_pos], byte MAXIMUM_Y_POS
        je notepad_get_char

        ; update some values
        inc byte [cursor_y_pos]    
        add si, byte MAXIMUM_X_POS
        inc si

        ; move the cursor one line upwards
        mov ah, byte 0x02
        mov dh, byte [cursor_y_pos]
        mov dl, byte [cursor_x_pos]
        int 0x10

        ; go back to the main sub routine
        jmp notepad_get_char
        
    notepad_left_arrow:
        ; check if the cursor is within bounds
        cmp [cursor_x_pos], byte 0
        je notepad_get_char

        ; move the cursor one column backwards
        mov ah, byte 0x0e
        mov al, byte BACKSPACE
        int 0x10

        ; update the si register and the cursor x position
        dec si
        dec byte [cursor_x_pos]
        
        jmp notepad_get_char

    notepad_right_arrow:
        ; check if the cursor is in bounds
        mov al, byte [cursor_x_pos]
        cmp al, byte MAXIMUM_X_POS
        je notepad_right_arrow_next_line

        ; increment the cursor x pos by one
        inc byte [cursor_x_pos]

        ; move the cursor one column to the right
        mov ah, byte 0x02
        mov dh, byte [cursor_y_pos]
        mov dl, byte [cursor_x_pos]
        int 0x10

        ; increment the si register and go back to the main subroutine
        inc si
        jmp notepad_get_char

        notepad_right_arrow_next_line:
            ; check if the cursor y pos is swithin bounds
            mov al, byte [cursor_y_pos]
            cmp al, byte MAXIMUM_Y_POS
            je get_char

            ; update the cursor x and y position
            mov [cursor_x_pos], byte 0
            inc byte [cursor_y_pos]

            ; move the cursor down to the next line
            mov ah, byte 0x0e
            mov al, byte CARRIAGE_RETURN
            int 0x10
            mov al, byte NEW_LINE
            int 0x10

            ; increment the si register and go back to the main subroutine
            inc si
            jmp notepad_get_char

    notepad_backspace:
        cmp [cursor_x_pos], byte 0
        je notepad_backspace_check_y_pos

        ; update the cursor position
        dec byte [cursor_x_pos]

        ; delete the character from the screen
        mov ah, 0x0e
        int 0x10
        mov al, SPACE
        int 0x10
        mov al, BACKSPACE
        int 0x10

        ; delete the character from the string
        dec si
        mov [si], byte EMPTY_CHARACTER

        ; go back to the main sub routine
        jmp notepad_get_char

        notepad_backspace_check_y_pos:
            ; check if it's possible to go one line backwards
            cmp [cursor_y_pos], byte 0
            je notepad_get_char

            ; update the cursor position
            mov [cursor_x_pos], byte MAXIMUM_X_POS
            dec byte [cursor_y_pos]

            ; move the cursor accordingly
            mov ah, 0x02
            mov dh, byte [cursor_y_pos]
            mov dl, byte MAXIMUM_X_POS
            mov bh, 0
            int 0x10

            ; update the string index register
            dec si
            mov [si], byte EMPTY_CHARACTER

            ; go back to the main sub routine
            jmp notepad_get_char

    notepad_next_line_enter:
        ; check if we reached the end of them allowed limit
        cmp [cursor_y_pos], byte MAXIMUM_Y_POS
        je notepad_get_char

        ; update the cursor positions
        inc byte [cursor_y_pos]
        mov [si], byte EMPTY_CHARACTER

        ; go to the next line
        mov ah, 0x0e
        mov al, byte CARRIAGE_RETURN
        int 0x10
        mov al, NEW_LINE
        int 0x10

        ; update the string index
        xor ax, ax
        mov al, byte [cursor_x_pos]
        sub si, word ax
        add si, word MAXIMUM_X_POS
        inc si
        mov [si], byte EMPTY_CHARACTER
        
        ; update the cursor x position
        mov [cursor_x_pos], byte 0

        ; return back to the main sub routine
        jmp notepad_get_char

    notepad_next_line:
        ; check if we reached the end of them allowed limit
        cmp [cursor_y_pos], byte MAXIMUM_Y_POS
        je notepad_get_char

        ; update the cursor positions
        inc byte [cursor_y_pos]
        mov [si], byte EMPTY_CHARACTER

        ; update the string index
        xor ax, ax
        mov al, byte [cursor_x_pos]
        sub si, word ax
        add si, word MAXIMUM_X_POS
        inc si
        
        ; update the cursor x position
        mov [cursor_x_pos], byte 0

        ; return back to the main sub routine
        jmp notepad_get_char

    notepad_tab_key:
        ; check if the x pos will become out of bounds
        add [cursor_x_pos], byte NOTEPAD_TAB_SPACES
        cmp [cursor_x_pos], byte MAXIMUM_X_POS
        jg notepad_tab_key_next_line_check
        jmp notepad_tab_key_print_space

        notepad_tab_key_next_line_check:
            ; check if the y pos will become out of bounds
            mov al, byte [cursor_y_pos]
            cmp al, byte MAXIMUM_Y_POS
            jge notepad_tab_key_exit

            ; apply the changes
            inc byte [cursor_y_pos]
            mov [cursor_x_pos], byte 0

        notepad_tab_key_print_space:
            mov cl, byte NOTEPAD_TAB_SPACES
            mov ah, 0x0e
            mov al, byte SPACE

            notepad_tab_key_print_space_loop:
                int 0x10

                ; save the spaces to the buffer
                mov [si], byte SPACE
                inc si

                ; check if there are more spaces
                dec cl
                cmp cl, byte 0
                jne notepad_tab_key_print_space_loop

                jmp notepad_get_char

        notepad_tab_key_exit:
            ; remove the spaces and return
            sub [cursor_x_pos], byte NOTEPAD_TAB_SPACES
            jmp notepad_get_char

    exit_notepad:
        ; put the null terminator at the end of the buffer
        call select_notepad_buffer
        add si, word NOTEPAD_INPUT_BUFFER_SIZE
        dec si
        mov [si], byte NULL_TERMINATOR

        call clear_screen

        popa
        ret

notepad_input_buffer: times 1856 db 0xff
notepad_input_buffer_two: times 1856 db 0xff
notepad_input_buffer_three: times 1856 db 0xff
selected_notepad_buffer: db 0
cursor_x_pos: db 0
cursor_y_pos: db 0

NOTEPAD_TAB_SPACES equ 4
NOTEPAD_INPUT_BUFFER_SIZE equ 1856
MAXIMUM_X_POS equ 79
MAXIMUM_Y_POS equ 22