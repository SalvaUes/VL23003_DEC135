; archivo: ejercicio3_division_basico.s

section .text
    global _start       ; inicio

_start:
    ; numeros (32 bits)
    ; dividendo edx:eax
    ; divisor en un registro o memoria
    mov eax, 40         ; parte baja del dividendo (ej. 40)
    xor edx, edx        ; parte alta del dividendo = 0 (para num positivo)
                        ; si fuera negativo o > 2^31-1, edx seria diferente



    
    mov ebx, 5          ; divisor (ej. 5)

    ; division
    div ebx             ; eax = (edx:eax) / ebx
                        ; edx = residuo





    ; resultado: cociente en eax, residuo en edx
    ; (ej. eax = 8, edx = 0)






    ; terminar
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; salida ok
    syscall             ; ejecutar