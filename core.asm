global core

section .text

core:
    mov         r8, [rsp]
    xor         rdx, rdx
.main_loop:
    mov         al, byte [rsi + rdx + 0]
    inc         rdx
    cmp         al, 0x0
    je          .end
    cmp         al, '0'
    jl          .not_number
    cmp         al, '9'
    jg          .not_number
    jmp         .operation_number
.not_number:
    cmp         al, 'E'
    je          .operation_E
    cmp         al, 'D'
    je          .operation_D
    cmp         al, 'E'
    je          .operation_E
    jmp         .main_loop
.operation_number:
    sub         al, '0'
    push        rax
    jmp         .main_loop
.operation_C:
    pop         rcx
    jmp         .main_loop
.operation_D:
    pop         rax
    push        rax
    push        rax
    jmp         .main_loop
.operation_E:
    pop         rax
    pop         rcx
    push        rax
    push        rcx
    jmp         .main_loop
.end:
    pop         rax
    push        r8
    ret