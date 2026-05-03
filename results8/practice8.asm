global _start

section .bss
    buf resb 512
    arr resd 100
    outbuf resb 16
    n resd 1
    target resd 1
    first resd 1
    count resd 1

section .data
    space db ' '
    nl db 10

section .text

_start:
    ; I/O
    mov eax, 3
    xor ebx, ebx
    mov ecx, buf
    mov edx, 512
    int 0x80

    ; parse
    mov esi, buf
    call atoi
    mov [n], eax

    ; loops
    xor ecx, ecx

read_loop:
    cmp ecx, [n]
    jge read_target

    ; parse
    call skip
    call atoi

    ; memory
    mov [arr + ecx * 4], eax

    ; logic
    inc ecx
    jmp read_loop

read_target:
    ; parse
    call skip
    call atoi
    mov [target], eax

    ; memory
    mov dword [first], -1
    mov dword [count], 0

    ; loops
    xor ecx, ecx

search_loop:
    cmp ecx, [n]
    jge print_result

    ; memory
    mov eax, [arr + ecx * 4]

    ; logic
    cmp eax, [target]
    jne next_item

    mov eax, [count]
    cmp eax, 0
    jne add_count
    mov [first], ecx

add_count:
    ; math
    inc dword [count]

next_item:
    inc ecx
    jmp search_loop

print_result:
    ; I/O
    mov eax, [first]
    call print_num
    call print_nl

    mov eax, [count]
    call print_num
    call print_nl

    ; loops
    xor ecx, ecx

print_indexes:
    cmp ecx, [n]
    jge finish

    ; memory
    mov eax, [arr + ecx * 4]

    ; logic
    cmp eax, [target]
    jne next_print

    push ecx
    mov eax, ecx
    call print_num
    call print_space
    pop ecx

next_print:
    inc ecx
    jmp print_indexes

finish:
    call print_nl

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    ; memory
    xor eax, eax
    xor edi, edi

    ; logic
    cmp byte [esi], '-'
    jne atoi_loop
    mov edi, 1
    inc esi

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
    cmp edi, 0
    je atoi_ret
    neg eax

atoi_ret:
    ret

skip:
    ; loops
    mov bl, [esi]
    cmp bl, ' '
    je skip_next
    cmp bl, 10
    je skip_next
    cmp bl, 13
    je skip_next
    cmp bl, 9
    je skip_next
    ret

skip_next:
    ; logic
    inc esi
    jmp skip

print_num:
    ; memory
    mov edi, outbuf + 16
    xor esi, esi

    ; logic
    cmp eax, 0
    jge pn_loop
    neg eax
    mov esi, 1

pn_loop:
    ; loops
    xor edx, edx
    mov ebx, 10
    div ebx

    ; math
    add dl, '0'
    dec edi
    mov [edi], dl

    ; logic
    test eax, eax
    jnz pn_loop

    cmp esi, 0
    je pn_write
    dec edi
    mov byte [edi], '-'

pn_write:
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

print_space:
    ; I/O
    mov ecx, space
    mov edx, 1
    call print
    ret

print_nl:
    ; I/O
    mov ecx, nl
    mov edx, 1
    call print
    ret