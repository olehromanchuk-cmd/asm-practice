section .data
    msg db "Enter n and numbers: "
    msg_len equ $ - msg

    orig_msg db "Original: "
    orig_len equ $ - orig_msg

    rev_msg db 10, "Reversed: "
    rev_len equ $ - rev_msg

    pal_yes db 10, "PALINDROME: YES", 10
    pal_yes_len equ $ - pal_yes

    pal_no db 10, "PALINDROME: NO", 10
    pal_no_len equ $ - pal_no

    space db " "

section .bss
    input resb 2048
    arr resd 200
    rev resd 200
    buf resb 16
    n resd 1
    is_pal resd 1

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
    mov edx, 2048
    int 0x80

; parse
    mov esi, input
    call next_number

; logic
    cmp eax, 5
    jge check_max
    mov eax, 5

check_max:
    cmp eax, 200
    jle save_n
    mov eax, 200

save_n:
; memory
    mov [n], eax
    xor edi, edi

read_loop:
; loops
    cmp edi, [n]
    jge make_reverse

    call next_number
    mov [arr + edi * 4], eax

    inc edi
    jmp read_loop

make_reverse:
; loops
    xor edi, edi

reverse_loop:
    cmp edi, [n]
    jge check_palindrome

; math
    mov eax, [n]
    dec eax
    sub eax, edi

; memory
    mov ebx, [arr + eax * 4]
    mov [rev + edi * 4], ebx

    inc edi
    jmp reverse_loop

check_palindrome:
; memory
    mov dword [is_pal], 1

; loops
    xor edi, edi

pal_loop:
    mov eax, [n]
    shr eax, 1
    cmp edi, eax
    jge print_original

; logic
    mov eax, [arr + edi * 4]

    mov ebx, [n]
    dec ebx
    sub ebx, edi

    cmp eax, [arr + ebx * 4]
    jne not_palindrome

    inc edi
    jmp pal_loop

not_palindrome:
    mov dword [is_pal], 0

print_original:
; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, orig_msg
    mov edx, orig_len
    int 0x80

    mov esi, arr
    mov ecx, [n]
    call print_array

; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, rev_msg
    mov edx, rev_len
    int 0x80

    mov esi, rev
    mov ecx, [n]
    call print_array

; logic
    cmp dword [is_pal], 1
    je print_yes

print_no:
; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, pal_no
    mov edx, pal_no_len
    int 0x80
    jmp exit

print_yes:
; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, pal_yes
    mov edx, pal_yes_len
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
    push ecx
    push esi

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
    pop esi
    pop ecx
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