global _start

section .bss
    buf resb 16
    outbuf resb 16
    freq resd 10
    n resd 1
    seed resd 1

section .data
    colon db ': '
    colon_len equ $ - colon
    hash db '#'
    space db ' '
    nl db 10

section .text

_start:
    ; I/O
    mov eax, 3
    xor ebx, ebx
    mov ecx, buf
    mov edx, 16
    int 0x80

    ; parse
    mov esi, buf
    call atoi
    mov [n], eax

    ; memory
    mov dword [seed], 1

    ; loops
    xor ecx, ecx

gen_loop:
    cmp ecx, [n]
    jge print_hist

    ; math
    mov eax, [seed]
    mov ebx, 1103515245
    mul ebx
    add eax, 12345
    and eax, 0x7fffffff
    mov [seed], eax

    ; math
    xor edx, edx
    mov ebx, 10
    div ebx

    ; memory
    inc dword [freq + edx * 4]

    ; logic
    inc ecx
    jmp gen_loop

print_hist:
    ; loops
    xor ecx, ecx

row_loop:
    cmp ecx, 10
    jge exit

    ; I/O
    mov eax, ecx
    push ecx
    call print_num

    mov ecx, colon
    mov edx, colon_len
    call print

    pop ecx
    push ecx

    ; memory
    mov ebx, [freq + ecx * 4]

hash_loop:
    ; loops
    cmp ebx, 0
    jle print_count

    ; I/O
    push ebx
    mov ecx, hash
    mov edx, 1
    call print
    pop ebx

    ; logic
    dec ebx
    jmp hash_loop

print_count:
    ; I/O
    mov ecx, space
    mov edx, 1
    call print

    pop ecx
    push ecx

    mov eax, [freq + ecx * 4]
    call print_num
    call print_nl

    pop ecx
    inc ecx
    jmp row_loop

exit:
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

print_num:
    ; memory
    mov edi, outbuf + 16

    ; logic
    cmp eax, 0
    jne num_loop

    dec edi
    mov byte [edi], '0'
    jmp num_write

num_loop:
    ; loops
    xor edx, edx
    mov ebx, 10

    ; math
    div ebx
    add dl, '0'

    ; memory
    dec edi
    mov [edi], dl

    ; logic
    cmp eax, 0
    jne num_loop

num_write:
    ; I/O
    mov ecx, edi
    mov edx, outbuf + 16
    sub edx, edi
    call print
    ret

print:
    ; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

print_nl:
    ; I/O
    mov ecx, nl
    mov edx, 1
    call print
    ret