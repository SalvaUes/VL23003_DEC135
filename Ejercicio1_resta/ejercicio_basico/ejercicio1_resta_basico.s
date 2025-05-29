; archivo: ejercicio1_resta_basico.s

section .text
    global _start       ; inicio

_start:
    ; numeros (ejemplos)
    mov ax, 30          ; num1 (16b)
    mov bx, 10          ; num2 (16b)
    mov cx, 5           ; num3 (16b)

    ; resta
    sub ax, bx          ; ax = ax - bx
    sub ax, cx          ; ax = ax - cx
                        ; resultado en ax

    ; terminar
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; salida ok
    syscall             ; ejecutar