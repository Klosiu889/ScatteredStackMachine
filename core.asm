extern get_value
extern put_value

section .data
    values: times N dq N                    ; tablica to przekazywania wartości w operacji S
    receivers: times N dq N                 ; tablica to przekazywania odbiorców i synchronizacji w operacji S

section .text

global core

core:
    push        rbx                         ; zapisanie rejestrów, które muszą pozostać zachowane
    push        r12
    push        r13
    push        r14
    push        rbp
    mov         rbp, rsp                    ; zapisanie ważnych danych do niezmiennych rejestrów
    mov         r12, rdi
    mov         r13, rsi
    xor         rbx, rbx                    ; zerowanie licznika pętli
.main_loop:
    xor         rax, rax                    ; zerowanie akumulatora na kolejny znak
    mov         al, byte [r13 + rbx + 0]    ; wczytanie kolejnego znaku
    inc         rbx
    cmp         al, 0x0                     ; sprawdzenie czy znakiem jest null i należy zakończyć obliczenie
    je          .end
    cmp         al, '+'                     ; rozpatrywanie kolejnych operacji
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
    cmp         al, 'S'
    je          .operation_S
    jmp         .operation_number
.operation_number:
    sub         al, '0'                     ; konwersja znaku na liczbę
    push        rax
    jmp         .main_loop
.operation_plus:
    pop         rax
    add         [rsp], rax                  ; dodanie wartości do aktualnego wierzchołka stosu
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
    push        r12                         ; w r12 jest numer procesu
    jmp         .main_loop
.operation_B:
    pop         rax
    cmp         qword [rsp], 0x0            ; sprawdzenie czy wartość na stosie jest zerem
    jz          .main_loop
    add         rbx, rax                    ; przesunięcie wskaźnika operacji jeśli na stosie nie ma zera
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
    mov         rdi, r12                    ; przygotowanie argumentu funkcji get_value
    mov         r14, rsp                    ; zapisanie wierzchołka stosu
    and         rsp, -16                    ; wierzchołek stosu jest podzielny przez 16 przed wywołaniem funkcji
    call        get_value
    mov         rsp, r14                    ; przywrócenie wierzchołka stosu
    push        rax                         ; zapisanie wyniku funkcji na stosie
    jmp         .main_loop
.operation_P:
    pop         rsi
    mov         rdi, r12                    ; przygotowanie argumentów funkcji put_value
    mov         r14, rsp
    and         rsp, -16                    ; wierzchołek stosu jest podzielny przez 16 przed wywołaniem funkcji
    call        put_value
    mov         rsp, r14                    ; przywrócenie wierzchołka stosu
    jmp         .main_loop
.operation_S:
    pop         rax                         ; zdejmujemy numer procesu do wymiany i wartość do przekazania
    pop         rcx
    lea         rdi, [rel values]           ; zapisanie adresów tablic do rejestrów
    lea         rsi, [rel receivers]
    mov         [rdi + r12 * 8], rcx        ; zapisanie wartości do tablicy
    mov         [rsi + r12 * 8], rax        ; zapisanie numeru odbiorcy do tablicy
.spin_lock_value:
    cmp         [rsi + rax * 8], r12        ; sprawdzenie czy mogę odebrać wartość
    jne         .spin_lock_value            ; jeśli nie to czekam
    mov         rcx, [rdi + rax * 8]        ; odbieram wartość
    mov         qword [rsi + rax * 8], N    ; zaznaczam, że odebrałem wartość
.spin_lock_receiver:
    cmp         qword [rsi + r12 * 8], N    ; sprawdzenie czy odbiorca odebrał wartość
    jne         .spin_lock_receiver         ; jeśli nie to czekam
    push        rcx                         ; włożenie odebranej wartość na stos
    jmp         .main_loop
.end:
    pop         rax                         ; zdejmowanie wyniku ze stosu
    mov         rsp, rbp                    ; przywrócenie wskaźnika na początek stosu po zachowaniu rejestrów
    pop         rbp                         ; przywrócenie rejestrów niezmiennych
    pop         r14
    pop         r13
    pop         r12
    pop         rbx
    ret