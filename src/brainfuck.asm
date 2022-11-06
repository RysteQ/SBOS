brainfuck:
    pusha

    ; display the welcome message
    mov si, brainfuck_welcome_message
    call clear_screen
    call print_si

    ; make sure the memory buffer is full of zeroes only
    brainfuck_init:
        mov di, brainfuck_memory
        mov cl, byte BRAINFUCK_MEMORY_LIMIT

        brainfuck_init_loop:
            mov [di], byte NULL_TERMINATOR

            ; update the registers
            inc di
            dec cl

            ; check if the end has been reached
            cmp cl, byte 0
            jne brainfuck_init_loop

    ; load the memory buffer
    mov [brainfuck_memory_index], byte 0
    mov di, brainfuck_memory

    brainfuck_select_buffer_loop:
        xor ah, byte ah
        int 0x16

        sub al, 48

        ; select the correct buffer
        cmp al, byte 1
        je brainfuck_select_buffer_one
        cmp al, byte 2
        je brainfuck_select_buffer_two
        cmp al, byte 3
        je brainfuck_select_buffer_three

        jmp brainfuck_select_buffer_loop

        brainfuck_select_buffer_one:
            mov si, notepad_buffer_one
            jmp brainfuck_select_buffer_loop_exit

        brainfuck_select_buffer_two:
            mov si, notepad_buffer_two
            jmp brainfuck_select_buffer_loop_exit

        brainfuck_select_buffer_three:
            mov si, notepad_buffer_three
            jmp brainfuck_select_buffer_loop_exit

        brainfuck_select_buffer_loop_exit:
            call clear_screen
            jmp brainfuck_loop

    brainfuck_loop:
        ; check if the end of the program has been reached
        cmp [si], byte NULL_TERMINATOR
        je brainfuck_exit

        ; check for any valid instructions
        cmp [si], byte BRAINFUCK_INCREMENT_MEMORY_CELL
        je brainfuck_loop_increment_memory_cell
        cmp [si], byte BRAINFUCK_DECREMENT_MEMORY_CELL
        je brainfuck_loop_decrement_memory_cell
        cmp [si], byte BRAINFUCK_GO_TO_NEXT_MEMORY_CELL
        je brainfuck_loop_next_memory_cell
        cmp [si], byte BRAINFUCK_GO_TO_PREVIOUS_MEMORY_CELL
        je brainfuck_loop_previous_memory_cell
        cmp [si], byte BRAINFUCK_PRINT_MEMORY_CELL_VALUE
        je brainfuck_loop_print_out_memory_cell
        cmp [si], byte BRAINFUCK_READ_TO_MEMORY_CELL
        je brainfuck_loop_read_to_memory_cell
        cmp [si], byte BRAINFUCK_OPEN_BRACKET
        je brainfuck_loop_open_bracket
        cmp [si], byte BRAINFUCK_CLOSE_BRACKET
        je brainfuck_loop_close_bracket

        brainfuck_loop_continue:
            inc si

            jmp brainfuck_loop

        brainfuck_loop_increment_memory_cell:
            inc byte [di]

            jmp brainfuck_loop_continue

        brainfuck_loop_decrement_memory_cell:
            dec byte [di]

            jmp brainfuck_loop_continue

        brainfuck_loop_next_memory_cell:
            inc byte [brainfuck_memory_index]

            ; check if an overflow occured
            cmp [brainfuck_memory_index], byte BRAINFUCK_MEMORY_LIMIT
            je brainfuck_loop_next_memory_cell_overflow

            ; increment the pointer
            inc di

            jmp brainfuck_loop_continue

            brainfuck_loop_next_memory_cell_overflow:
                mov [brainfuck_memory_index], byte 0

                ; decrement the pointer
                mov cx, word BRAINFUCK_MEMORY_LIMIT
                dec cx
                sub di, word cx

                jmp brainfuck_loop_continue

        brainfuck_loop_previous_memory_cell:
            cmp [brainfuck_memory_index], byte 0
            je brainfuck_loop_previous_memory_cell_underflow

            ; decrement the pointer and memory index
            dec di
            dec byte [brainfuck_memory_index]

            jmp brainfuck_loop_continue

            brainfuck_loop_previous_memory_cell_underflow:
                mov cx, word BRAINFUCK_MEMORY_LIMIT
                dec cx

                ; update the memory index and memory pointer
                mov [brainfuck_memory_index], byte BRAINFUCK_MEMORY_LIMIT
                dec byte [brainfuck_memory_index]
                add di, word cx

                jmp brainfuck_loop_continue

        brainfuck_loop_print_out_memory_cell:
            mov ah, byte 0x0e
            mov al, byte [di]
            int 0x10

            jmp brainfuck_loop_continue

        brainfuck_loop_read_to_memory_cell:
            xor ah, byte ah
            int 0x16

            mov [di], byte al

            jmp brainfuck_loop_continue

        brainfuck_loop_open_bracket:
            cmp [di], byte 0
            jne brainfuck_loop_open_bracket_exit

            mov [brainfuck_conditional_or_byte], byte FALSE

            brainfuck_loop_open_bracket_loop:
                ; check if the loop should keep going or not
                cmp [si], byte BRAINFUCK_CLOSE_BRACKET
                jne brainfuck_loop_open_bracket_loop_set_or_byte_to_true
                
                cmp [brainfuck_open_brackets_count], byte 0
                jne brainfuck_loop_open_bracket_loop_set_or_byte_to_true

                jmp brainfuck_loop_open_bracket_loop_continue

                brainfuck_loop_open_bracket_loop_set_or_byte_to_true:
                    mov [brainfuck_conditional_or_byte], byte TRUE
                    jmp brainfuck_loop_open_bracket_loop_continue

                brainfuck_loop_open_bracket_loop_continue:
                    ; exit the loop if the conditions were not met
                    cmp [brainfuck_conditional_or_byte], byte FALSE
                    je brainfuck_loop_open_bracket_exit

                    ; increment the pointer 
                    inc si

                    cmp [si], byte BRAINFUCK_OPEN_BRACKET
                    je brainfuck_loop_open_bracket_loop_continue_increment_open_brackets

                    cmp [si], byte BRAINFUCK_CLOSE_BRACKET
                    je brainfuck_loop_open_bracket_loop_continue_decrement_open_brackets

                    jmp brainfuck_loop_open_bracket_loop

                brainfuck_loop_open_bracket_loop_continue_increment_open_brackets:
                    ; increment the open brackets count
                    inc byte [brainfuck_open_brackets_count]

                    jmp brainfuck_loop_open_bracket_loop

                brainfuck_loop_open_bracket_loop_continue_decrement_open_brackets:
                    ; decrement the open brackets count
                    dec byte [brainfuck_open_brackets_count]

                    jmp brainfuck_loop_open_bracket_loop

            brainfuck_loop_open_bracket_exit:
                jmp brainfuck_loop_continue

        brainfuck_loop_close_bracket:
            cmp [di], byte 0
            je brainfuck_loop_close_bracket_exit

            mov [brainfuck_conditional_or_byte], byte FALSE

            brainfuck_loop_close_bracket_loop:
                ; check if the loop should keep going or not
                cmp [si], byte BRAINFUCK_OPEN_BRACKET
                jne brainfuck_loop_close_bracket_loop_set_or_byte_to_true
                
                cmp [brainfuck_close_brackets_count], byte 0
                jne brainfuck_loop_close_bracket_loop_set_or_byte_to_true

                jmp brainfuck_loop_close_bracket_loop_continue

                brainfuck_loop_close_bracket_loop_set_or_byte_to_true:
                    mov [brainfuck_conditional_or_byte], byte TRUE
                    jmp brainfuck_loop_close_bracket_loop_continue

                brainfuck_loop_close_bracket_loop_continue:
                    ; exit the loop if the conditions were not met
                    cmp [brainfuck_conditional_or_byte], byte FALSE
                    je brainfuck_loop_close_bracket_exit

                    ; decrement the pointer 
                    dec si

                    cmp [si], byte BRAINFUCK_CLOSE_BRACKET
                    je brainfuck_loop_close_bracket_loop_continue_increment_close_brackets

                    cmp [si], byte BRAINFUCK_OPEN_BRACKET
                    je brainfuck_loop_close_bracket_loop_continue_decrement_close_brackets

                    jmp brainfuck_loop_close_bracket_loop

                brainfuck_loop_close_bracket_loop_continue_increment_close_brackets:
                    ; increment the close brackets count
                    inc byte [brainfuck_close_brackets_count]

                    jmp brainfuck_loop_close_bracket_loop

                brainfuck_loop_close_bracket_loop_continue_decrement_close_brackets:
                    ; decrement the close brackets count
                    dec byte [brainfuck_close_brackets_count]

                    jmp brainfuck_loop_close_bracket_loop

            brainfuck_loop_close_bracket_exit:
                jmp brainfuck_loop_continue

    brainfuck_exit:
        ; move the cursor to the last line, column zero
        mov ah, byte 0x02
        xor bh, bh
        xor dl, dl
        mov dh, byte 23
        int 0x10

        ; print out the exit message
        mov si, brainfuck_exit_message
        call print_si

        ; stop the code from exiting without a user input
        xor ah, ah
        int 0x16

        ; clear the screen before exit
        call clear_screen

        ; exit
        popa
        ret

brainfuck_welcome_message: db "Select notepad buffer (1 - 3) -> ", NULL_TERMINATOR
brainfuck_exit_message: db "Press any key to exit", NULL_TERMINATOR
brainfuck_memory: times 100 db 0
brainfuck_memory_index: db 0

brainfuck_conditional_or_byte: db 0

brainfuck_open_brackets_count: db 0
brainfuck_close_brackets_count: db 0

BRAINFUCK_MEMORY_LIMIT equ 100

BRAINFUCK_INCREMENT_MEMORY_CELL equ '+'
BRAINFUCK_DECREMENT_MEMORY_CELL equ '-'
BRAINFUCK_GO_TO_NEXT_MEMORY_CELL equ '>'
BRAINFUCK_GO_TO_PREVIOUS_MEMORY_CELL equ '<'
BRAINFUCK_PRINT_MEMORY_CELL_VALUE equ '.'
BRAINFUCK_READ_TO_MEMORY_CELL equ ','
BRAINFUCK_OPEN_BRACKET equ '['
BRAINFUCK_CLOSE_BRACKET equ ']'