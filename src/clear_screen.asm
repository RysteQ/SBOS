clear_screen:
    mov ax, word 0x03
    int 0x10
    
    ret