extern get_value
extern put_value
extern print_register

section .data
    values: times N dq N
    receivers: times N dq N

section .text

global core

core:
    push        rbx
    push        r12
    push        r13
    push        rbp
    mov         rbp, rsp
    mov         r12, rdi
    mov         r13, rsi
    xor         rbx, rbx
.main_loop:
    mov         al, byte [r13 + rbx + 0]
    inc         rbx
    cmp         al, 0x0
    je          .end
    cmp         al, '+'
    je          .operation_plus
    cmp         al, '*'
    je          .operation_times
    cmp         al, '-'
    je          .operation_minus
    cmp         al, 'n'
    je          .operation_n
    cmp         al, 'B'
    je          .operation_B
    cmp         al, 'C'
    je          .operation_C
    cmp         al, 'D'
    je          .operation_D
    cmp         al, 'E'
    je          .operation_E
    cmp         al, 'G'
    je          .operation_G
    cmp         al, 'P'
    je          .operation_P
    jmp         .operation_number
.operation_number:
    sub         al, '0'
    push        rax
    jmp         .main_loop
.operation_plus:
    pop         rax
    add         [rsp], rax
    jmp         .main_loop
.operation_times:
    pop         rax
    pop         rcx
    imul        rax, rcx
    push        rax
    jmp         .main_loop
.operation_minus:
    neg         qword [rsp]
    jmp         .main_loop
.operation_n:
    push        r12
    jmp         .main_loop
.operation_B:
    pop         rax
    cmp         qword [rsp], 0x0
    jz          .main_loop
    add         rbx, rax
    dec         rbx
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
.operation_G:
    mov         rdi, r12
    call        get_value
    push        rax
    jmp         .main_loop
.operation_P:
    pop         rsi
    mov         rdi, r12
    call        put_value
    jmp         .main_loop
.operation_S:
    pop         rax
    pop         rcx
    mov         rdi, rax
    mov         rsi, rcx
    xchg        [values + r12 * 8], rsi
    xchg        [receivers + r12 * 8], rdi
.spinlock_receive:
    cmp         qword [receivers + rdi * 8], N
    je          .spinlock_receive
    xchg        rsi, [values + rdi * 8]
    xchg        [receivers + rdi * 8], N
.spinlock_let_receive:
    cmp         qword [receivers + r12 * 8], N
    je          .spinlock_let_receive
    push        rsi
    jmp         .main_loop
.end:
    pop         rax
    mov         rsp, rbp
    pop         rbp
    pop         r13
    pop         r12
    pop         rbx
    ret