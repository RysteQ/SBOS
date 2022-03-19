clear && rm *.bin

nasm -fbin bootloader.asm -o bootloader.bin
nasm -fbin main.asm -o main.bin

cat bootloader.bin main.bin > pack.bin

qemu-system-x86_64 pack.bin