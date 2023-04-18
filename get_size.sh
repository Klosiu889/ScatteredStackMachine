nasm -DN=2 -f elf64 -w+all -w+error -o core.o core.asm
size core.o
rm core.o
