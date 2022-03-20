[org 0x7c00]
[bits 16]

mov ah, byte 0x02
mov al, byte SECTORS_TO_READ
mov cx, word 0x0002
mov dh, 0

xor bx, bx
mov es, bx
mov bx, word 0x7e00
int 0x13

; jump to the actual part of the OS
jmp 0x7e00

; padding and the magic number
times 510 - ($ - $$) db 0
dw 0xaa55

SECTORS_TO_READ equ 19