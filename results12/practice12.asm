section .data
    msg1 db "Enter text: "
    msg1_len equ $ - msg1

    msg2 db "Enter pattern: "
    msg2_len equ $ - msg2

    pos_msg db "position: "
    pos_len equ $ - pos_msg

    count_msg db 10, "count: "
    count_len equ $ - count_msg

    nl db 10
    minus db "-"

section .bss
    text resb 201
    pattern resb 51
    buf resb 16
    text_len resd 1
    pattern_len resd 1
    first_pos resd 1
    count resd 1
    i resd 1

section .text
    global _start

_start:
; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, msg1_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, text
    mov edx, 200
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, msg2_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, pattern
    mov edx, 50
    int 0x80

; parse
    mov esi, text
    call strlen
    mov [text_len], eax

    mov esi, pattern
    call strlen
    mov [pattern_len], eax

; memory
    mov dword [first_pos], -1
    mov dword [count], 0
    mov dword [i], 0

; logic
    cmp dword [pattern_len], 0
    je print_result

    mov eax, [pattern_len]
    cmp eax, [text_len]
    jg print_result

; loops
search_loop:
    mov eax, [i]
    mov ebx, [text_len]
    sub ebx, [pattern_len]
    cmp eax, ebx
    jg print_result

    xor ecx, ecx

compare_loop:
    mov eax, [i]
    add eax, ecx

    mov dl, [text + eax]
    mov bl, [pattern + ecx]

    cmp dl, bl
    jne no_match

    inc ecx
    cmp ecx, [pattern_len]
    jl compare_loop

; logic
    cmp dword [first_pos], -1
    jne skip_first
    mov eax, [i]
    mov [first_pos], eax

skip_first:
    inc dword [count]

; math
    mov eax, [pattern_len]
    add [i], eax
    jmp search_loop

no_match:
    inc dword [i]
    jmp search_loop

print_result:
; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, pos_msg
    mov edx, pos_len
    int 0x80

    mov eax, [first_pos]
    cmp eax, -1
    jne print_pos_num

    mov eax, 4
    mov ebx, 1
    mov ecx, minus
    mov edx, 1
    int 0x80

    mov eax, 1
    call print_number
    jmp print_count

print_pos_num:
    call print_number

print_count:
    mov eax, 4
    mov ebx, 1
    mov ecx, count_msg
    mov edx, count_len
    int 0x80

    mov eax, [count]
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, nl
    mov edx, 1
    int 0x80

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

strlen:
; loops
    xor eax, eax

strlen_loop:
    mov bl, [esi + eax]
    cmp bl, 10
    je strlen_done
    cmp bl, 0
    je strlen_done
    inc eax
    jmp strlen_loop

strlen_done:
    mov byte [esi + eax], 0
    ret

print_number:
; I/O
    push ebx
    push ecx
    push edx
    push edi

    mov edi, buf + 15
    mov ebx, 10
    xor ecx, ecx

    cmp eax, 0
    jne num_loop

    dec edi
    mov byte [edi], '0'
    mov ecx, 1
    jmp write_num

num_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    cmp eax, 0
    jne num_loop

write_num:
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    mov ecx, edi
    int 0x80

    pop edi
    pop edx
    pop ecx
    pop ebx
    ret