bf_interpreter:
    pusha

    mov ax, word BF_MEMORY_SIZE
    xor cx, cx
    mov di, bf_memory

    bf_interpreter_clear_memory:
        dec ax
        mov [di], byte 0

        cmp ax, byte 0
        jne bf_interpreter_clear_memory
        jmp bf_interpreter_run

    bf_interpreter_run:
        cmp [si], byte NULL_TERMINATOR
        je bf_interpreter_exit

        mov al, byte [si]
        inc si
        inc cx

        cmp al, byte BF_INCREMENT
        je bf_increment_memory_cell

        cmp al, byte BF_DECREMENT
        je bf_decrement_memory_cell
        
        cmp al, byte BF_PRINT
        je bf_print_memory_cell
        
        cmp al, byte BF_READ
        je bf_read_to_memory_cell
        
        cmp al, byte BF_NEXT
        je bf_next_memory_cell
        
        cmp al, byte BF_PREVIOUS
        je bf_previous_memory_cell
        
        cmp al, byte BF_OPENING_BRACKET
        je bf_opening_bracket
        
        cmp al, byte BF_CLOSING_BRACKET
        je bf_closing_bracket

        cmp al, byte NULL_TERMINATOR
        jmp bf_interpreter_exit

    bf_increment_memory_cell:
        inc byte [di]
        jmp bf_interpreter_run

    bf_decrement_memory_cell:
        dec byte [di]
        jmp bf_interpreter_run

    bf_print_memory_cell:
        mov ah, byte 0x0e
        mov al, byte [di]
        int 0x10

        jmp bf_interpreter_run

    bf_read_to_memory_cell:
        mov ah, byte 0x00
        int 0x16

        mov [di], byte al

        jmp bf_interpreter_run

    bf_next_memory_cell:
        inc di
        jmp bf_interpreter_run

    bf_previous_memory_cell:
        dec di
        jmp bf_interpreter_run

    bf_opening_bracket:
        cmp [di], byte 0
        jne bf_interpreter_run

        bf_opening_bracket_find_closing_bracket:
            cmp [si], byte BF_CLOSING_BRACKET
            je found_closing_bracket
            cmp cx, word BF_MEMORY_SIZE
            je bf_interpreter_exit

            inc cx
            inc si

            jmp bf_opening_bracket_find_closing_bracket

        found_closing_bracket:
            inc si
            jmp bf_interpreter_run

    bf_closing_bracket:
        cmp [di], byte 0
        je bf_interpreter_run

        dec si

        bf_closing_bracket_find_opening_bracket:
            cmp [si], byte BF_OPENING_BRACKET
            je bf_interpreter_run
            cmp cx, word 0
            je bf_interpreter_exit

            dec cx
            dec si

            jmp bf_closing_bracket_find_opening_bracket

    bf_interpreter_exit:
        popa
        ret

bf_memory: times 1024 db 0

BF_MEMORY_SIZE equ 1024

BF_INCREMENT equ '+'
BF_DECREMENT equ '-'
BF_PRINT equ '.'
BF_READ equ ','
BF_NEXT equ '>'
BF_PREVIOUS equ '<'
BF_OPENING_BRACKET equ '['
BF_CLOSING_BRACKET equ ']'