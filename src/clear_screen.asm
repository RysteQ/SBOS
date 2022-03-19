clear_screen:
    pusha
    
    mov ah, byte 0x00
    mov al, byte 0x03
    int 0x10
    
    popa
    ret