section .data
    msg db "Enter h: "
    msg_len equ $ - msg

section .bss
    input resb 16
    line resb 64
    h resd 1
    row resd 1

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
    cmp eax, 5
    jge check_max
    mov eax, 5

check_max:
    cmp eax, 25
    jle save_h
    mov eax, 25

save_h:
; memory
    mov [h], eax
    mov dword [row], 0

; loops
main_loop:
    mov eax, [row]
    cmp eax, [h]
    jge exit

; math
    mov eax, [h]
    sub eax, [row]
    dec eax
    mov ecx, eax

    mov edi, line

spaces_loop:
    cmp ecx, 0
    je stars_prepare

    mov byte [edi], ' '
    inc edi
    dec ecx
    jmp spaces_loop

stars_prepare:
; math
    mov eax, [row]
    shl eax, 1
    inc eax
    mov ecx, eax

stars_loop:
    cmp ecx, 0
    je finish_line

    mov byte [edi], '*'
    inc edi
    dec ecx
    jmp stars_loop

finish_line:
; memory
    mov byte [edi], 10
    inc edi

    mov edx, edi
    sub edx, line
    mov ecx, line
    call print_line

    inc dword [row]
    jmp main_loop

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_line:
; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret