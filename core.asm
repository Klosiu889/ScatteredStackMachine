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
    push        r15
    push        rbp
    mov         rbp, rsp
    mov         r12, rdi
    mov         r13, rsi
    xor         rbx, rbx
.main_loop:
    mov         r14b, byte [r13 + rbx + 0]
    inc         rbx

    cmp         r12, 0x0
    jnz         .continue
    mov         rdx, [rsp]
    mov         rdi, r12
    mov         rsi, r14
    call        print_register
.continue:

    cmp         r14b, 0x0
    je          .end
    cmp         r14b, '+'
    je          .operation_plus
    cmp         r14b, '*'
    je          .operation_times
    cmp         r14b, '-'
    je          .operation_minus
    cmp         r14b, 'n'
    je          .operation_n
    cmp         r14b, 'B'
    je          .operation_B
    cmp         r14b, 'C'
    je          .operation_C
    cmp         r14b, 'D'
    je          .operation_D
    cmp         r14b, 'E'
    je          .operation_E
    cmp         r14b, 'G'
    je          .operation_G
    cmp         r14b, 'P'
    je          .operation_P
    cmp         r14b, 'S'
    je          .operation_S
    jmp         .operation_number
.operation_number:
    sub         r14b, '0'
    push        r14
    jmp         .main_loop
.operation_plus:
    pop         r14
    add         [rsp], r14
    jmp         .main_loop
.operation_times:
    pop         r14
    pop         r15
    imul        r14, r15
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
    pop         r15
    jmp         .main_loop
.operation_D:
    pop         r14
    push        r14
    push        r14
    jmp         .main_loop
.operation_E:
    pop         r14
    pop         r15
    push        r14
    push        r15
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
    pop         r14
    pop         r15
    push        0x1C
    jmp         .main_loop
    pop         r14
    pop         r15
    lea         rdi, [rel values]
    lea         rsi, [rel receivers]
    mov         [rdi + r12 * 8], r15
    mov         [rsi + r12 * 8], r14
.spin_lock_value:
    cmp         [rsi + r14 * 8], r12
    jne         .spin_lock_value
    mov         r15, [rdi + r14 * 8]
    mov         qword [rsi + r14 * 8], N
.spin_lock_receiver:
    cmp         qword [rsi + r12 * 8], N
    jne         .spin_lock_receiver
    push        r15
    jmp         .main_loop
.end:
    pop         rax
    mov         rsp, rbp
    pop         rbp
    pop         r15
    pop         r14
    pop         r13
    pop         r12
    pop         rbx
    ret