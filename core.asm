extern get_value
extern put_value
extern print_register

section .data
    align 4
    values: times N dq N
    receivers: times N dq N

section .text

global core

core:
    push        rbx
    push        r12
    push        r13
    push        r14
    push        rbp
    mov         rbp, rsp
    mov         r12, rdi
    mov         r13, rsi
    xor         rbx, rbx
.main_loop:
    mov         r14d, byte [r13 + rbx + 0]
    inc         rbx

    cmp         r12, 0x0
    jnz         .continue
    mov         rdx, [rsp]
    push        r14
    mov         rdi, r12
    mov         rsi, r14
    call        print_register
    pop         r14

.continue:
    cmp         r14d, 0x0
    je          .end
    cmp         r14d, '+'
    je          .operation_plus
    cmp         r14d, '*'
    je          .operation_times
    cmp         r14d, '-'
    je          .operation_minus
    cmp         r14d, 'n'
    je          .operation_n
    cmp         r14d, 'B'
    je          .operation_B
    cmp         r14d, 'C'
    je          .operation_C
    cmp         r14d, 'D'
    je          .operation_D
    cmp         r14d, 'E'
    je          .operation_E
    cmp         r14d, 'G'
    je          .operation_G
    cmp         r14d, 'P'
    je          .operation_P
    cmp         r14d, 'S'
    je          .operation_S
    jmp         .operation_number
.operation_number:
    mov         rdi, 0x45
    mov         rdx, r14
    sub         r14d, '0'
    push        r14

    call        print_register

    jmp         .main_loop
.operation_plus:
    pop         r14
    add         [rsp], r14
    jmp         .main_loop
.operation_times:
    pop         r14
    pop         rcx
    imul        r14, rcx
    push        r14
    jmp         .main_loop
.operation_minus:
    neg         qword [rsp]
    jmp         .main_loop
.operation_n:
    push        r12
    jmp         .main_loop
.operation_B:
    pop         r14
    cmp         qword [rsp], 0x0
    jz          .main_loop
    add         rbx, r14
    jmp         .main_loop
.operation_C:
    pop         rcx
    jmp         .main_loop
.operation_D:
    pop         r14
    push        r14
    push        r14
    jmp         .main_loop
.operation_E:
    pop         r14
    pop         rcx
    push        r14
    push        rcx
    jmp         .main_loop
.operation_G:
    mov         rdi, r12
    call        get_value
    push        r14
    jmp         .main_loop
.operation_P:
    pop         rsi
    mov         rdi, r12
    call        put_value
    jmp         .main_loop
.operation_S:
    pop         r14
    pop         rcx
    push        0x1C
    jmp         .main_loop
    pop         r14
    pop         rcx
    lea         rdi, [rel values]
    lea         rsi, [rel receivers]
    mov         [rdi + r12 * 8], rcx
    mov         [rsi + r12 * 8], r14
.spin_lock_value:
    cmp         [rsi + r14 * 8], r12
    jne         .spin_lock_value
    mov         rcx, [rdi + r14 * 8]
    mov         qword [rsi + r14 * 8], N
.spin_lock_receiver:
    cmp         qword [rsi + r12 * 8], N
    jne         .spin_lock_receiver
    push        rcx
    jmp         .main_loop
.end:
    pop         r14
    mov         rsp, rbp
    pop         rbp
    pop         r14
    pop         r13
    pop         r12
    pop         rbx
    ret