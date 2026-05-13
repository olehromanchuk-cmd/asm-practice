section .data
    msg db "Enter n: "
    msg_len equ $ - msg

    fact_msg db "fact: "
    fact_len equ $ - fact_msg

    calls_msg db 10, "calls: "
    calls_len equ $ - calls_msg

    nl db 10

section .bss
    input resb 16
    buf resb 16
    n resd 1
    calls resd 1

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
    mov edx, 16
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
; logic
    cmp eax, 0
    jge check_max
    mov eax, 0

check_max:
    cmp eax, 12
    jle save_n
    mov eax, 12

save_n:
; memory
    mov [n], eax
    mov dword [calls], 0

; math
    mov eax, [n]
    call fact

    push eax

; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, fact_msg
    mov edx, fact_len
    int 0x80

    pop eax
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, calls_msg
    mov edx, calls_len
    int 0x80

    mov eax, [calls]
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

fact:
; memory
    push ebp
    mov ebp, esp
    push ebx

; logic
    inc dword [calls]
    cmp eax, 1
    jg recursive_case

    mov eax, 1
    jmp fact_done

recursive_case:
; math
    mov ebx, eax
    dec eax
    call fact
    imul eax, ebx

fact_done:
    pop ebx
    mov esp, ebp
    pop ebp
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
; loops
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