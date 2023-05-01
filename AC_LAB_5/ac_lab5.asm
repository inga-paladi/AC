global _start

;------------------------------------------ section data
section .data
; Strings for the menu, input prompt, and error message
    new_line db 10,0
    greater_sign db ">",0
    less_sign db "<",0
    menu db "Choose an option from 1 to 10: ",0
    input times 16 db 0
    input_len equ $ - input

    process_one_msg db "Input a string to convert to upper case: ",0
    process_two_msg db "Input a string to convert to lower case: ",0
    process_three_msg db "Input a string to calculate the length of: ",0
    process_four_msg db "Input string to remove spaces : ",0
    process_five_msg db "Converting a Number to a String. Reading processor's timestamp counter and display it: ",0
    result_msg db "Result: ", 0
    process_six_msg db "Checking whether a number is odd or even: ",0
    input_prompt db "Enter a number: ", 0
    is_odd_msg db "The number is odd", 0
    is_even_msg db "The number is even", 0
    process_seven_msg db "Determining the larger of two numbers: ",0
    input_two_numbers_msg db "Input two numbers delimited by new line", 0
    first_number_is_greater db "The first number is greater",0
    second_number_is_greater db "The second number is greater",0
    numbers_are_equal db "Numbers are equal",0
    process_eight_msg db "sum of elements",0 ; --------------------------------------------------------------
    input_ten_numbers db "Input 10 numbers on each line: ",0
    sum_of_numbers_msg db "The sum of input numbers is: ",0
    process_nine_msg db "Finding an element in a list of numbers.",0
    input_the_nr_to_search db "Input the number to search in array: ",0
    the_number_is_at_position_msg db "The number you searched is at position: ",0
    process_zero_msg db "Removing an element from a list of numbers.",0
    input_the_index_to_remove db "Input the index to remove in array: ",0
    invalid_msg: db "Invalid input. Please try again.",0

;------------------------------------------ section bss
section .bss
; buffers

    buffer: resb BUFFER_SIZE
    second_buffer: resb BUFFER_SIZE
    int_val: resd 1

;------------------------------------------ section text
section .text

;------------------------------------------ start
_start:
menu_loop:
    ; Display the menu
    print_string menu

    ; Read user input
    read_string input, input_len

    ; Parse the input and execute the corresponding process
    cmp byte [input], '1'
    je process1
    cmp byte [input], '2'
    je process2
    cmp byte [input], '3'
    je process3
    cmp byte [input], '4'
    je process4
    cmp byte [input], '5'
    je process5
    cmp byte [input], '6'
    je process6
    cmp byte [input], '7'
    je process7
    cmp byte [input], '8'
    je process8
    cmp byte [input], '9'
    je process9
    cmp byte [input], '0'
    je process0

    ; Invalid input, display an error message
    print_string invalid_msg
    print_string new_line
    jmp menu_loop

process1:
    ; Exercise 5: Converting a string to uppercase

    print_string process_one_msg
    read_string buffer, BUFFER_SIZE

    to_upper buffer
    print_string buffer
    print_string new_line

    jmp menu_loop

process2:
    ; Converting a string to lower case

    print_string process_two_msg
    read_string buffer, BUFFER_SIZE

    to_lower buffer
    print_string buffer
    print_string new_line

    jmp menu_loop

process3:
    ; code for process 3 Calculating the length of a string

    print_string process_three_msg
    read_string buffer, BUFFER_SIZE
    string_len buffer ; result is stored in eax
    dword_to_string eax, buffer
    print_string buffer
    print_string new_line

    jmp menu_loop

process4:
    ; code for process 4 Removing spaces from a string
    print_string process_four_msg

    read_string buffer, BUFFER_SIZE
    remove_spaces buffer
    print_string buffer
    print_string new_line
    jmp menu_loop

process5:
    ; code for process 5 Converting a Number to a String    print_string process_five_msg

    print_string process_five_msg
    ; reads the value of the processor's timestamp counter (TSC)
    rdtsc ; stores timestamp counter as 64 bits in ECX and EAX
    ; value bits 63-0, ecx bits 63-32, eax bits 31-0
    dword_to_string eax, buffer
    print_string buffer
    print_string new_line

    jmp menu_loop

process6:
    ; code for process 6 Checking whether a number is odd or even

    print_string process_six_msg
    print_string input_prompt
    read_string buffer, BUFFER_SIZE
    string_to_dword buffer

    ;Call the is_odd macro to check if the number is odd or even
    is_odd eax
    cmp byte eax, 0
    je .is_even
    print_string is_odd_msg
    jmp .end
.is_even:
    print_string is_even_msg
.end:
    print_string new_line
    jmp menu_loop

process7:
    ; code for process 7 Determining the larger of two numbers

    print_string process_seven_msg
    print_string input_two_numbers_msg
    print_string new_line
    print_string greater_sign
    read_string buffer, BUFFER_SIZE
    string_to_dword buffer
    push eax
    print_string greater_sign
    read_string buffer, BUFFER_SIZE
    string_to_dword buffer
    pop ebx
    cmp ebx, eax
    jg .first_is_greater
    jl .second_is_greater
    ; else is equal
    print_string numbers_are_equal
    jmp .done

.first_is_greater:
    print_string first_number_is_greater
    jmp .done

.second_is_greater:
    print_string second_number_is_greater

.done:
    print_string new_line
    jmp menu_loop

process8:
    ; code for process 8 Sorting a list of numbers in ascending order
    print_string process_eight_msg
    print_string new_line
    print_string input_ten_numbers
    print_string new_line

    read_n_numbers buffer, dword 10
    print_list_of_numbers buffer, 10
    print_string new_line
    sum_of_numbers buffer, 10, int_val

    print_string sum_of_numbers_msg
    dword_to_string [int_val], buffer
    print_string buffer
    print_string new_line

    jmp menu_loop

process9:
    ;Finding an element in a list of numbers

    ;Nasm macro that receives a buffer of numbers, each the size of a byte, the size of this array and a number.
    ;This macro should search and write to eax the position of that number. if is found,
    ;    a value from 1 to size_of_array is written to eax, if not, 0 is written
    print_string process_nine_msg
    print_string new_line

    print_string input_ten_numbers
    print_string new_line

    read_n_numbers buffer, dword 10

    print_string input_the_nr_to_search
    print_string new_line

    read_string second_buffer, 5
    string_to_dword second_buffer
    mov [int_val], eax

    find_element_in_array buffer, 10, [int_val], int_val
    dword_to_string [int_val], buffer

    print_string the_number_is_at_position_msg
    print_string buffer
    print_string new_line

    jmp menu_loop

process0:
    ;Removing an element from a list of numbers

    print_string process_zero_msg
    print_string new_line

    print_string input_ten_numbers
    print_string new_line

    read_n_numbers buffer, byte 10

    print_string input_the_index_to_remove
    print_string new_line

    read_string second_buffer, 3
    string_to_dword second_buffer
    mov [int_val], eax

    remove_element_in_array buffer, 10, [int_val]

    print_list_of_numbers buffer, 9
    print_string new_line

    jmp menu_loop