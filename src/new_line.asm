new_line:
    mov ah, 0x0e
    mov al, byte 10
    int 0x10
    mov al, byte 13
    int 0x10
    ret