[org 0x7c00]
[bits 16]

mov ah, byte 0x02
mov al, SECTORS_TO_READ
mov cx, word 0x0002
mov dh, byte 0

xor bx, bx
mov es, bx
mov bx, word 0x7e00
int 0x13

jmp 0x7e00

times 510 - ($ - $$) db 0
dw 0xaa55

SECTORS_TO_READ equ 14