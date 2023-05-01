section .data
    msg db "Aici",0
    new_line db 10,0
    space db 32,0

section .bss
    buffer: resb 256
    current_time resd 1

section .text
    extern rand
    extern srand
    extern time
    global _start

_start:
    mov byte [esp], 1

.loop:
    cmp byte [esp], 11     ; generate 10 numbers, from [1 to 11)
    je .done
    
    mov al, [esp]
    push eax
    call srand
    call rand
    
    ; the value is in eax
    mov edx, 0
    mov ebx, 54
    div ebx
    ; the remainder is store in edx
    mov eax, edx

    mov cl, [esp]
    dword_to_string eax, buffer
    print_string buffer
    print_string space

    add byte [esp], 1
    jmp .loop
    
.done:
    print_string new_line

    ; exit the program
    mov eax, 1         ; system call number for exit
    xor ebx, ebx       ; exit status (0)
    int 0x80           ; invoke the system call
