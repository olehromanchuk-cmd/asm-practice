global _start

section .bss
    input_buffer resb 32
    output_buffer resb 16
    sum_value resd 1
    len_value resd 1

section .data
    newline db 10

section .text

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 32
    int 0x80

    ; parse
    mov esi, input_buffer
    call atoi

    ; logic
    mov ebx, eax
    xor ecx, ecx
    xor esi, esi

sum_loop:
    ; loops
    cmp ebx, 0
    je save_results

    ; math
    mov eax, ebx
    xor edx, edx
    mov edi, 10
    div edi

    add esi, edx
    inc ecx
    mov ebx, eax
    jmp sum_loop

save_results:
    ; memory
    mov [sum_value], esi
    mov [len_value], ecx

    ; memory
    mov eax, [sum_value]
    call itoa_print

    ; I/O
    call print_newline

    ; memory
    mov eax, [len_value]
    call itoa_print

    ; I/O
    call print_newline

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    ; memory
    xor eax, eax

atoi_loop:
    ; loops
    mov bl, [esi]
    cmp bl, 10
    je atoi_done
    cmp bl, 0
    je atoi_done
    cmp bl, '0'
    jl atoi_done
    cmp bl, '9'
    jg atoi_done

    ; math
    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx

    ; logic
    inc esi
    jmp atoi_loop

atoi_done:
    ret

itoa_print:
    ; memory
    lea edi, [output_buffer + 16]

    ; logic
    cmp eax, 0
    jne itoa_loop_start

    dec edi
    mov byte [edi], '0'
    mov ecx, edi
    mov edx, 1
    jmp write_number

itoa_loop_start:
    ; loops
    xor esi, esi

itoa_loop:
    ; math
    xor edx, edx
    mov ebx, 10
    div ebx

    add dl, '0'
    dec edi
    mov [edi], dl
    inc esi

    ; logic
    test eax, eax
    jnz itoa_loop

    ; memory
    mov ecx, edi
    mov edx, esi

write_number:
    ; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

print_newline:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret