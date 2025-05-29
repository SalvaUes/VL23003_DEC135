; archivo: ejercicio2_multiplicacion_basico.s

section .text
    global _start       ; inicio

_start:
    ; numeros (8 bits)
    mov al, 7           ; primer factor
    mov bl, 6           ; segundo factor

    ; multiplicacion
    mul bl              ; ax = al * bl (7 * 6 = 42)
                        ; resultado 16b en ax

    ; terminar
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; salida ok
    syscall             ; ejecutar