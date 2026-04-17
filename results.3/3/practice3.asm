global _start

section .bss
    buffer resb 16

section .data
    newline db 10

section .text

_start:
    ; logic
    mov eax, 12345

    ; parse
    ; no parsing is required because the number is already in AX/EAX

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
    lea edi, [buffer + 16]

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