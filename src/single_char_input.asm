get_single_char:
    pusha

    ; get the character
    mov ah, byte 0x00
    int 0x16

    ; display it back to the user
    mov ah, byte 0x0e
    int 0x10

    ; save it for future use
    mov [single_character_input], byte al

    ; create a new line
    call new_line

    ; return to the caller routine
    popa
    ret

single_character_input: db 0