section .data
    msg db "Enter n and numbers: "
    msg_len equ $ - msg

    before_msg db "Before: "
    before_len equ $ - before_msg

    after_msg db 10, "After: "
    after_len equ $ - after_msg

    median_msg db 10, "Median: "
    median_len equ $ - median_msg

    space db " "
    nl db 10

section .bss
    input resb 1024
    arr resd 100
    buf resb 16
    n resd 1
    i resd 1
    j resd 1
    min_idx resd 1

section .text
    global _start

_start:
; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, msg_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 1024
    int 0x80

; parse
    mov esi, input
    call next_number

; logic
    cmp eax, 10
    jge check_max
    mov eax, 10

check_max:
    cmp eax, 100
    jle save_n
    mov eax, 100

save_n:
; memory
    mov [n], eax
    xor edi, edi

read_loop:
; loops
    cmp edi, [n]
    jge print_before

    call next_number
    mov [arr + edi * 4], eax

    inc edi
    jmp read_loop

print_before:
; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, before_msg
    mov edx, before_len
    int 0x80

    mov esi, arr
    mov ecx, [n]
    call print_array

; memory
    mov dword [i], 0

sort_outer:
; loops
    mov eax, [n]
    dec eax
    cmp [i], eax
    jge print_after

    mov eax, [i]
    mov [min_idx], eax

; math
    mov eax, [i]
    inc eax
    mov [j], eax

sort_inner:
; loops
    mov eax, [j]
    cmp eax, [n]
    jge swap_values

; logic
    mov eax, [j]
    mov ebx, [arr + eax * 4]

    mov eax, [min_idx]
    cmp ebx, [arr + eax * 4]
    jge next_j

    mov eax, [j]
    mov [min_idx], eax

next_j:
    inc dword [j]
    jmp sort_inner

swap_values:
; logic
    mov eax, [min_idx]
    cmp eax, [i]
    je next_i

; memory
    mov eax, [i]
    mov ebx, [arr + eax * 4]

    mov eax, [min_idx]
    mov edx, [arr + eax * 4]

    mov eax, [i]
    mov [arr + eax * 4], edx

    mov eax, [min_idx]
    mov [arr + eax * 4], ebx

next_i:
    inc dword [i]
    jmp sort_outer

print_after:
; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, after_msg
    mov edx, after_len
    int 0x80

    mov esi, arr
    mov ecx, [n]
    call print_array

; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, median_msg
    mov edx, median_len
    int 0x80

; math
    mov eax, [n]
    dec eax
    shr eax, 1
    mov eax, [arr + eax * 4]
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

next_number:
; loops
skip_spaces:
    mov bl, [esi]
    cmp bl, ' '
    je skip_one
    cmp bl, 10
    je skip_one
    cmp bl, 9
    je skip_one
    jmp parse_num

skip_one:
    inc esi
    jmp skip_spaces

parse_num:
; parse
    xor eax, eax

num_loop:
    mov bl, [esi]
    cmp bl, '0'
    jl num_done
    cmp bl, '9'
    jg num_done

; math
    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx

    inc esi
    jmp num_loop

num_done:
    ret

print_array:
; loops
array_loop:
    cmp ecx, 0
    je array_done

    mov eax, [esi]
    call print_number

    push ecx
    push esi

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    pop esi
    pop ecx

    add esi, 4
    dec ecx
    jmp array_loop

array_done:
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
    jne convert_loop

    dec edi
    mov byte [edi], '0'
    mov ecx, 1
    jmp write_number

convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    cmp eax, 0
    jne convert_loop

write_number:
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