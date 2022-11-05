notepad:
    pusha

    ; display the welcome message
    mov si, notepad_welcome_message
    call clear_screen
    call print_si

    notepad_get_buffer_loop:
        mov ah, byte 0x00
        int 0x16

        ; load the requested buffer to the si register
        cmp al, byte 49
        je notepad_load_buffer_one
        cmp al, byte 50
        je notepad_load_buffer_two
        cmp al, byte 51
        je notepad_load_buffer_three

        jmp notepad_get_buffer_loop

    notepad_init:
        ; init the cursor line / column position
        mov [cursor_column_position], byte 0
        mov [cursor_line_position], byte 0

        ; display the current buffer data
        call clear_screen
        call print_si

        ; move the cursor to line 0 column 0
        mov ah, byte 0x03
        mov bh, byte 0
        int 0x10
        mov ah, byte 0x02
        xor dx, dx
        int 0x10

        xor cx, cx

    notepad_loop:
        mov ah, byte 0x00
        int 0x16

        ; check for special keys (TODO UP AND DOWN KEYS)
        cmp ah, byte LEFT_ARROW
        je notepad_left_arrow
        cmp ah, byte RIGHT_ARROW
        je notepad_right_arrow

        ; check if another special key was pressed or if the escape button (exit button) was pressed
        cmp al, byte ESCAPE_KEY
        je notepad_exit
        cmp al, byte BACKSPACE
        je notepad_loop_backspace
        cmp al, byte 0
        je notepad_loop

        ; check if the maximum column has been reached
        cmp [cursor_column_position], byte 79
        je notepad_loop_next_line

        ; check if the maximum line has been reached
        cmp [cursor_line_position], byte 23
        je notepad_loop_check_line

        ; update the line and column positions
        inc byte [cursor_column_position]

        ; display the user input
        mov ah, byte 0x0e
        int 0x10

        ; save the user input
        mov [si], byte al
        inc si

        jmp notepad_loop

        notepad_loop_next_line:
            ; check if the maximum line has been reached
            cmp [cursor_line_position], byte 23
            je notepad_loop

            ; update the cursor position
            inc byte [cursor_line_position]
            mov [cursor_column_position], byte 0

            ; display the user input
            mov ah, byte 0x0e
            int 0x10

            ; save the user input
            mov [si], byte al
            inc si

            jmp notepad_loop

        notepad_loop_check_line:
            cmp [cursor_column_position], byte 79
            je notepad_loop

            inc byte [cursor_column_position]
            
            ; display the user input
            mov ah, byte 0x0e
            int 0x10

            ; save the user input
            mov [si], byte al
            inc si

            jmp notepad_loop

    notepad_left_arrow:
        cmp [cursor_line_position], byte 0
        je notepad_left_arrow_extra_check
        jmp notepad_left_arrow_action_selection

        notepad_left_arrow_extra_check:
            cmp [cursor_column_position], byte 0
            je notepad_loop

        notepad_left_arrow_action_selection:
            cmp [cursor_column_position], word 0
            je notepad_left_arrow_previous_line
            jne notepad_left_arrow_previous_characher

        notepad_left_arrow_previous_line:
            ; move the cursor on the top right of the previous line
            pusha
            mov ah, byte 0x03
            mov bh, byte 0
            int 0x10
            dec dh
            mov dl, byte 79
            mov ah, byte 0x02
            int 0x10
            popa

            ; decrement the pointer and the cursor position
            dec si
            dec byte [cursor_line_position]
            mov [cursor_column_position], byte 79

            jmp notepad_loop

        notepad_left_arrow_previous_characher:
            mov ah, byte 0x0e
            mov al, byte BACKSPACE
            int 0x10

            ; decrement the pointer and the cursor position
            dec si
            dec byte [cursor_column_position]

            jmp notepad_loop

    notepad_right_arrow:
        ; check if the cursor is at the last line
        cmp [cursor_line_position], byte 23
        je notepad_right_arrow_extra_check

        ; check if the cursor needs to be moved one column or one line
        cmp [cursor_column_position], byte 79
        je notepad_right_arrow_next_line
        jmp notepad_right_arrow_next_column

        notepad_right_arrow_extra_check:
            cmp [cursor_column_position], byte 79
            je notepad_loop
            jmp notepad_right_arrow_next_line

        notepad_right_arrow_next_line:
            ; mov the cursor to the next line
            pusha
            mov ah, byte 0x03
            mov bh, byte 0
            int 0x10
            mov ah, byte 0x02
            mov dl, byte 0
            inc dh
            int 0x10
            popa

            ; increment the pointer and cursor position data
            inc si
            mov [cursor_column_position], byte 0
            inc byte [cursor_line_position]

            jmp notepad_loop
        
        notepad_right_arrow_next_column:
            ; move the cursor one column to the right
            pusha
            mov ah, byte 0x03
            mov bh, byte 0
            int 0x10
            mov ah, byte 0x02
            inc dl
            int 0x10
            popa

            ; increment the pointer and cursor column position
            inc si
            inc byte [cursor_column_position]

            jmp notepad_loop

    notepad_loop_backspace:
        ; check if the cursor is at the edge of the screen
        cmp [cursor_column_position], byte 0
        je notepad_loop_backspace_extra_check
        jmp notepad_loop_backspace_main_operation

        notepad_loop_backspace_extra_check:
            cmp [cursor_line_position], byte 0
            je notepad_loop

            mov [cursor_column_position], byte 80
            dec byte [cursor_line_position]

        notepad_loop_backspace_main_operation:
            ; erase the previous character from the screen
            mov ah, byte 0x0e
            int 0x10
            mov al, byte SPACE_KEY
            int 0x10
            mov al, byte BACKSPACE
            int 0x10

            dec byte [cursor_column_position]

            dec si
            mov [si], byte SPACE_KEY

            jmp notepad_loop

    notepad_load_buffer_one:
        ; display the selected buffer
        mov ah, byte 0x0e
        int 0x10

        mov si, notepad_buffer_one
        jmp notepad_init
    
    notepad_load_buffer_two:
        ; display the selected buffer
        mov ah, byte 0x0e
        int 0x10

        mov si, notepad_buffer_two
        jmp notepad_init
    
    notepad_load_buffer_three:
        ; display the selected buffer
        mov ah, byte 0x0e
        int 0x10

        mov si, notepad_buffer_three
        jmp notepad_init

    notepad_exit:
        ; clear the screen
        call clear_screen

        popa
        ret

notepad_welcome_message: db "Please enter a notepad buffer (1-3) -> ", NULL_TERMINATOR

; console dimensions are 80 columns and 24 rows big (the buffer is left ten bytes smaller than 80 * 24)
notepad_buffer_one: times 1922 db 0
notepad_buffer_two: times 1922 db 0
notepad_buffer_three: times 1922 db 0

cursor_line_position: db 0
cursor_column_position: db 0

NOTEPAD_BUFFER_LIMIT equ 1920

LEFT_ARROW equ 75
RIGHT_ARROW equ 77
ESCAPE_KEY equ 27