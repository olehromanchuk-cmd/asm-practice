global _start

section .bss
    input_buffer resb 32
    output_buffer resb 16

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
    xor eax, eax

parse_loop:
    ; loops
    mov bl, [esi]
    cmp bl, 10
    je parse_done
    cmp bl, 0
    je parse_done
    cmp bl, '0'
    jl parse_done
    cmp bl, '9'
    jg parse_done

    ; math
    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx

    ; logic
    inc esi
    jmp parse_loop

parse_done:
    ; memory
    mov ax, ax

    call print_number

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_number:
    ; memory
    lea edi, [output_buffer + 16]

    ; logic
    cmp eax, 0
    jne convert_loop

    dec edi
    mov byte [edi], '0'
    mov ecx, edi
    mov edx, 1
    jmp write_result

convert_loop:
    ; loops
    xor esi, esi

digit_loop:
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
    jnz digit_loop

    ; memory
    mov ecx, edi
    mov edx, esi

write_result:
    ; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80

    ret