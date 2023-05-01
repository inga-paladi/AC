%define STDIN 0
%define STDOUT 1
%define STDERR 2

; sys calls for 32bit
%define SYS_READ 3
%define SYS_WRITE 4

%define BUFFER_SIZE 256

section .bss
    input_buffer resb 4

section .text
;------------------------------------------ macros

;------------------------------------------ macro read_string
%macro read_string 2
    ; reads string until newline
    ; %1 = buffer, %2 = buffer size
    pusha           ; save registers

    mem_write %1, %2, 0 ; clear buffer

    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, %1
    mov edx, %2
    int 0x80

    remove_new_line %1

    remove_new_line %1

    popa            ; restore registers
%endmacro

;------------------------------------------ macro remove_new_line
%macro remove_new_line 1
    pusha

    mov eax, %1
%%.loop:
    mov ebx, [eax]    ; get character at current position
    cmp ebx, 0        ; check if character is null terminator
    je %%.done        ; if so, exit loop
    cmp ebx, 10       ; check if char is new line
    jne %%.next       ; if not, go to next
    mov byte [eax], 0      ; replace new line with 0
    jmp %%.done
%%.next:
    inc eax              ; increment counter
    jmp %%.loop            ; jump back to beginning of loop

%%.done:
    popa
%endmacro

; ----------------------------------------- macro print_string
%macro print_string 1
    pusha           ; save registers

    string_len %1   ; get the string length in eax register
    mov edx, eax
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, %1     ; pointer to string
    int 0x80

    popa            ; restore registers
%endmacro

; ----------------------------------------- macro string_len
%macro string_len 1 ; eax will be overriden and hold the length
    ; save registers
    push ebx
    push ecx
    push edx
    mov eax, 0      ; initialize character count
    mov ecx, %1     ; pointer to string
%%.loop:
    mov bl, [ecx]   ; get character at current position
    cmp bl, 0       ; check if character is null terminator
    je %%.done        ; if so, exit loop
    inc ecx         ; move to next character in string
    inc eax         ; increment character count
    jmp %%.loop       ; jump back to beginning of loop
%%.done:
    ; restore registers
    pop edx
    pop ecx
    pop ebx
%endmacro

; ----------------------------------------- macro to_upper
%macro to_upper 1
    pusha

    mov eax, %1
%%.loop:
    mov ebx, [eax]    ; get character at current position
    cmp ebx, 0        ; check if character is null terminator
    je %%.done        ; if so, exit loop
    cmp ebx, 0x61
    ;jl %%.next        ; if value is less than 0x61 ('a'), then is not a lower case letter
    cmp ebx, 0x7A
    ;jg %%.next        ; if value is greater than 'z', then is not a lower case letter
    sub ebx, 32       ; convert character to uppercase
    mov [eax], ebx    ; store uppercase character back in string
%%.next:
    inc eax              ; increment counter
    jmp %%.loop            ; jump back to beginning of loop

%%.done:
    popa
%endmacro

; ----------------------------------------- macro to_lower
%macro to_lower 1
    pusha

    mov eax, %1
%%.loop:
    mov ebx, [eax]    ; get character at current position
    cmp ebx, 0        ; check if character is null terminator
    je %%.done        ; if so, exit loop
    cmp ebx, 0x61
    ;jl %%.next        ; if value is less than 0x61 ('a'), then is not a lower case letter
    cmp ebx, 0x7A
    ;jg %%.next        ; if value is greater than 'z', then is not a lower case letter
    add ebx, 32       ; convert character to uppercase
    mov [eax], ebx    ; store uppercase character back in string
%%.next:
    inc eax              ; increment counter
    jmp %%.loop            ; jump back to beginning of loop

%%.done:
    popa
%endmacro

; ----------------------------------------- macro mem_write
%macro mem_write 3
    ; %1 - buffer, %2 - len, %3 - val to write
    pusha
    
    mov eax, 0        ; init counter
%%.loop:
    cmp eax, %2
    je %%.done
    mov byte [%1 + eax], %3
    inc eax
    jmp %%.loop

%%.done:
    popa
%endmacro

; ----------------------------------------- macro dword_to_string
%macro dword_to_string 2
    ; %1 - dword value, %2 - string buffer
    pusha

    mov ebx, %2
    mov byte [ebx], 0

    ; Convert the number to a string
    mov eax, %1
    mov ecx, 10  ; Base 10
    %%.loop:
        xor edx, edx
        div ecx
        add edx, '0'
        mov byte [ebx], dl
        inc ebx
        cmp eax, 0
        jne %%.loop

    ; Add the null terminator
    mov byte [ebx], 0

    string_len %2
    mov ebx, %2
    add ebx, eax
    reverse_string %2, ebx

    popa
%endmacro

;------------------------------------------ macro reverse string
%macro reverse_string 2 ; expects two arguments: the start address of the string and the end address
    pusha

    mov eax, %1 ; move start address to eax
    mov ebx, %2 ; move end address to ebx
    sub ebx, 1 ; adjust end address to point to last character
    %%.loop_start:
        cmp eax, ebx ; check if start address has reached or passed end address
        jge %%.loop_end
        mov cl, [eax] ; load character at start address into cl
        mov dl, [ebx] ; load character at end address into dl
        mov [eax], dl ; swap characters
        mov [ebx], cl
        inc eax ; move start address forward
        dec ebx ; move end address backward
        jmp %%.loop_start ; repeat loop
    %%.loop_end:
        popa
%endmacro

; ----------------------------------------- macro remove_spaces
%macro remove_spaces 1
    pusha

    mov eax, %1
    mov ebx, eax     ; move pointer to start of string
%%.loop:
    mov cl, [eax]    ; get character at current position
    cmp cl, 0        ; check if character is null terminator
    je %%.done       ; if so, exit loop
    cmp cl, 0x20     ; check if character is a space
    je %%.remove     ; if so, remove space and shift rest of string
%%.next:
    inc eax          ; increment counter
    jmp %%.loop      ; jump back to beginning of loop

%%.remove:
    mov edx, eax
%%.shift:
    mov cl, [eax + 1] ; get next character
    mov [eax], cl    ; shift character left
    inc eax          ; increment counter
    cmp cl, 0        ; check if character is null terminator
    jne %%.shift     ; if not, keep shifting
    mov byte [eax], 0 ; terminate string
    jmp %%.next      ; jump to next character

%%.done:
    popa
%endmacro

; ----------------------------------------- macro is_odd
%macro is_odd 1
    push ebx
    push ecx
    push edx
    push %1

    pop eax
    and eax, 1       ; bitwise AND with 1 to check if it's odd
    jz %%.even         ; if result is 0, it's even
    mov eax, 1       ; if result is 1, it's odd
    jmp %%.done

%%.even:
    xor eax, eax     ; set eax to 0 for even numbers

%%.done
    pop edx
    pop ecx
    pop ebx
%endmacro

; ----------------------------------------- macro string_to_dword
%macro string_to_dword 1
    push ebx
    push ecx
    push edx

    xor eax, eax   ; Clear the value of eax
    mov edx, %1    ; our string

%%.loop:
    movzx ecx, byte [edx] ; get a character
    inc edx ; ready for next one
    cmp ecx, '0'
    jb %%.done
    cmp ecx, '9'
    ja %%.done
    sub ecx, '0' ; "convert" character to number
    imul eax, 10 ; multiply "result so far" by ten
    add eax, ecx ; add in current digit
    jmp %%.loop

%%.done:
    pop edx
    pop ecx
    pop ebx
%endmacro

; ----------------------------------------- macro read_n_numbers
%macro read_n_numbers 2
    ; %1 - buffer, %2 - number of elements
    pusha

    mov ebx, %1 ; address of the buffer
    mov ecx, 0  ; counter
    %%.read_loop:
        read_string input_buffer, 3
        string_to_dword input_buffer
        mov [ebx+ecx], al
        inc ecx
        cmp ecx, %2
        jne %%.read_loop

    popa
%endmacro

; ----------------------------------------- macro print_list_of_numbers
%macro print_list_of_numbers 2
    ; %1 - buffer, %2 - number of elements
    pusha

    mov ebx, %1 ; address of the buffer
    mov ecx, 0  ; counter
    %%.loop:
        mov byte al, [ebx+ecx]
        dword_to_string eax, input_buffer
        print_string input_buffer
        mov byte [input_buffer], ','
        mov byte [input_buffer+1], 0
        print_string input_buffer
        add ecx, 1
        cmp byte ecx, %2
        jne %%.loop

    popa
%endmacro

; ----------------------------------------- macro sum_of_numbers
%macro sum_of_numbers 3
    ; %1 - buffer, %2 - size of array, %3 - sum result
    pusha

    mov eax, 0 ; the sum
    mov ebx, %1 ; address of the buffer
    mov ecx, 0  ; counter
    %%.loop:
        mov byte dl, [ebx+ecx] ; copy array value
        add eax, edx
        add ecx, 1
        cmp byte ecx, %2 ; size of array
        jne %%.loop
    mov [%3], eax

    popa
%endmacro

; ----------------------------------------- macro find_element_in_array
%macro find_element_in_array 4
    ; %1 - buffer
    ; %2 - nr of elements
    ; %3 - the element to search for
    ; %4 - value to store the result
    pusha

    mov eax, 0
    mov ebx, %1 ; address of the buffer
    mov ecx, 0  ; counter
    %%.loop:
        mov byte dl, [ebx+ecx] ; copy array value
        cmp edx, %3 ; is this the value
        je %%.found
        add ecx, 1
        cmp byte ecx, %2 ; size of array
        jne %%.loop
        jmp %%.done

    %%.found:
        add ecx, 1
        mov [%4], ecx

    %%.done:
        popa
%endmacro

; ----------------------------------------- macro remove_element_in_array
%macro remove_element_in_array 3
    ; %1 - buffer
    ; %2 - size of array
    ; %3 - index
    pusha

    mov ebx, %1 ; array name
    mov eax, 0 ; loop counter, element index

%%.loop_start:
    cmp eax, %3 ; the index i'm removing
    je %%.move_left
    inc eax ; increment counter
    inc ebx ; increment buffer pos
    jmp %%.loop_start

%%.move_left:
    mov edx, %2
    dec edx      ; %2-1 is the last index
    cmp eax, %2-1 ; 3 is the last index
    je %%.loop_end
    mov dl, [ebx+1] ; get the next element
    mov byte[ebx], dl ; write the next element to current address
    inc eax      ; increment counter
    inc ebx      ; increment arrat pos
    jmp %%.move_left ; go to next element

%%.loop_end:
    popa
%endmacro