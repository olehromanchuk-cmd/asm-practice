section .data
    msg db "Enter x: "
    msg_len equ $ - msg

    bin_msg db "binary: "
    bin_len equ $ - bin_msg

    pop_msg db 10, "popcount: "
    pop_len equ $ - pop_msg

    mod_msg db 10, "modified: "
    mod_len equ $ - mod_msg

    nl db 10
    space db " "

    p dd 1
    q dd 3
    r dd 2

section .bss
    input resb 32
    buf resb 16
    x resd 1
    bit_count resd 1
    modx resd 1

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
    mov edx, 32
    int 0x80

; parse
    mov esi, input
    xor eax, eax

parse_loop:
    mov bl, [esi]
    cmp bl, '0'
    jl parse_done
    cmp bl, '9'
    jg parse_done

    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx

    inc esi
    jmp parse_loop

parse_done:
; memory
    mov [x], eax
    mov dword [bit_count], 0

; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, bin_msg
    mov edx, bin_len
    int 0x80

; loops
    mov eax, [x]
    mov ecx, 32

print_binary:
    shl eax, 1
    jc print_one

print_zero:
    mov byte [buf], '0'
    jmp print_bit

print_one:
    mov byte [buf], '1'

print_bit:
    push eax
    push ecx

    mov eax, 4
    mov ebx, 1
    mov ecx, buf
    mov edx, 1
    int 0x80

    pop ecx
    pop eax

    dec ecx
    cmp ecx, 0
    je binary_done

; logic
    mov edx, ecx
    and edx, 3
    cmp edx, 0
    jne print_binary

    push eax
    push ecx

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    pop ecx
    pop eax
    jmp print_binary

binary_done:
; loops
    mov eax, [x]
    mov ecx, 32

pop_loop:
; logic
    mov edx, eax
    and edx, 1
    add [bit_count], edx
    shr eax, 1
    loop pop_loop

; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, pop_msg
    mov edx, pop_len
    int 0x80

    mov eax, [bit_count]
    call print_number

; math
    mov eax, [x]

    mov ecx, [p]
    mov ebx, 1
    shl ebx, cl
    or eax, ebx

    mov ecx, [q]
    mov ebx, 1
    shl ebx, cl
    or eax, ebx

    mov ecx, [r]
    mov ebx, 1
    shl ebx, cl
    not ebx
    and eax, ebx

    mov [modx], eax

; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, mod_msg
    mov edx, mod_len
    int 0x80

    mov eax, [modx]
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

print_number:
    push ebx
    push ecx
    push edx
    push edi

    mov edi, buf + 15
    mov ebx, 10
    xor ecx, ecx

num_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    cmp eax, 0
    jne num_loop

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