global _start

section .bss
    buf resb 16
    arr resd 50
    outbuf resb 16
    n resd 1
    minv resd 1
    maxv resd 1
    mini resd 1
    maxi resd 1

section .data
    space db ' '
    nl db 10

    min_txt db 'min ',0
    min_len equ $ - min_txt

    max_txt db 'max ',0
    max_len equ $ - max_txt

    idx_txt db ' index ',0
    idx_len equ $ - idx_txt

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

    ; fill array
    xor ecx, ecx
fill_loop:
    cmp ecx, [n]
    jge find_minmax

    ; math: x = i*i + 3 - i
    mov eax, ecx
    imul eax, eax
    add eax, 3
    sub eax, ecx

    mov [arr + ecx*4], eax

    inc ecx
    jmp fill_loop

find_minmax:
    mov eax, [arr]
    mov [minv], eax
    mov [maxv], eax
    mov dword [mini], 0
    mov dword [maxi], 0

    xor ecx, ecx
check_loop:
    cmp ecx, [n]
    jge print_arr

    mov eax, [arr + ecx*4]

    ; min
    cmp eax, [minv]
    jge chk_max
    mov [minv], eax
    mov [mini], ecx

chk_max:
    ; max
    cmp eax, [maxv]
    jle next
    mov [maxv], eax
    mov [maxi], ecx

next:
    inc ecx
    jmp check_loop

print_arr:
    xor ecx, ecx
print_loop:
    cmp ecx, [n]
    jge print_min

    mov eax, [arr + ecx*4]
    push ecx
    call print_num
    call print_space
    pop ecx

    inc ecx
    jmp print_loop

print_min:
    call print_nl

    mov ecx, min_txt
    mov edx, min_len
    call print

    mov eax, [minv]
    call print_num

    mov ecx, idx_txt
    mov edx, idx_len
    call print

    mov eax, [mini]
    call print_num
    call print_nl

    mov ecx, max_txt
    mov edx, max_len
    call print

    mov eax, [maxv]
    call print_num

    mov ecx, idx_txt
    mov edx, idx_len
    call print

    mov eax, [maxi]
    call print_num
    call print_nl

    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    xor eax, eax
atoi_loop:
    mov bl, [esi]
    cmp bl, '0'
    jl atoi_done
    cmp bl, '9'
    jg atoi_done

    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx

    inc esi
    jmp atoi_loop
atoi_done:
    ret

print_num:
    mov edi, outbuf + 16

    cmp eax, 0
    jne pn_loop

    dec edi
    mov byte [edi], '0'
    jmp pn_write

pn_loop:
    xor edx, edx
    mov ebx, 10
    div ebx

    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz pn_loop

pn_write:
    mov ecx, edi
    mov edx, outbuf + 16
    sub edx, edi
    call print
    ret

print:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

print_space:
    mov ecx, space
    mov edx, 1
    call print
    ret

print_nl:
    mov ecx, nl
    mov edx, 1
    call print
    ret