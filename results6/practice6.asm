global _start

section .bss
    buf resb 64
    outbuf resb 16
    a resd 1
    b resd 1

section .data
    sl db "SIGNED: a < b",10
    slen equ $-sl
    se db "SIGNED: a = b",10
    seen equ $-se
    sg db "SIGNED: a > b",10
    sglen equ $-sg

    ul db "UNSIGNED: a < b",10
    ulen equ $-ul
    ue db "UNSIGNED: a = b",10
    ueen equ $-ue
    ug db "UNSIGNED: a > b",10
    uglen equ $-ug

    nl db 10

section .text

_start:
    ; I/O
    mov eax, 3
    xor ebx, ebx
    mov ecx, buf
    mov edx, 64
    int 0x80

    ; parse
    mov esi, buf
    call atoi
    mov [a], eax
    call skip
    call atoi
    mov [b], eax

    ; logic
    mov eax, [a]
    cmp eax, [b]
    jl s_l
    jg s_g
    mov ecx, se
    mov edx, seen
    jmp s_p
s_l:
    mov ecx, sl
    mov edx, slen
    jmp s_p
s_g:
    mov ecx, sg
    mov edx, sglen
s_p:
    call print

    ; logic
    mov eax, [a]
    cmp eax, [b]
    jb u_l
    ja u_g
    mov ecx, ue
    mov edx, ueen
    jmp u_p
u_l:
    mov ecx, ul
    mov edx, ulen
    jmp u_p
u_g:
    mov ecx, ug
    mov edx, uglen
u_p:
    call print

    ; logic
    mov eax, [a]
    cmp eax, [b]
    jg ps_a
    mov eax, [b]
ps_a:
    call print_num
    call print_nl

    ; logic
    mov eax, [a]
    cmp eax, [b]
    ja pu_a
    mov eax, [b]
pu_a:
    call print_num
    call print_nl

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    ; memory
    xor eax, eax
    xor edi, edi
    cmp byte [esi], '-'
    jne a_loop
    mov edi, 1
    inc esi
a_loop:
    ; loops
    mov bl, [esi]
    cmp bl, '0'
    jl a_end
    cmp bl, '9'
    jg a_end

    ; math
    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx

    ; logic
    inc esi
    jmp a_loop
a_end:
    ; logic
    cmp edi, 0
    je a_ret
    neg eax
a_ret:
    ret

skip:
    ; loops
    cmp byte [esi], ' '
    jne sk_ret
    inc esi
    jmp skip
sk_ret:
    ret

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

print_nl:
    ; I/O
    mov ecx, nl
    mov edx, 1
    call print
    ret