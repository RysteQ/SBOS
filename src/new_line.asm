new_line:
    pusha

    ; print a new line and the carriange return
    mov ah, byte 0x0e
    mov al, byte NEW_LINE
    int 0x10
    mov al, byte CARRIAGE_RETURN
    int 0x10

    popa
    ret