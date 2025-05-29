; archivo: ejercicio2_multiplicacion_mejorado.s

section .data
    msg_bienvenida db "bienvenido al programa de multiplicacion de dos numeros (8 bits)", 0Ah, 0
    len_bienvenida equ $ - msg_bienvenida

    msg_num1 db "ingrese primer numero: ", 0
    len_msg_num1 equ $ - msg_num1

    msg_num2 db "ingrese segundo numero: ", 0
    len_msg_num2 equ $ - msg_num2

    msg_resultado_final db "el resultado de la multiplicacion es: ", 0
    len_resultado_final equ $ - msg_resultado_final

section .bss
    buffer_num resb 5        ; buffer entrada
    buffer_resultado resb 7  ; buffer salida num





section .text
    global _start        ; inicio


;--- convierte cadena a int8 ---

; rsi: buffer entrada
; al: resultado (numero 8b)
; Clobbers: ax, cx, dx (usa movzx cx, ...), rsi
string_to_int8:
    xor ax, ax           ; al=0 (acumulador)
    mov r10, 10          ; r10 para base 10
.loop_s2i8:
    movzx cx, byte [rsi] ; leer char en cl
    inc rsi              ; sig char
    cmp cl, 0Ah          ; es enter?
    je .done_s2i8        ; si, fin
    cmp cl, '0'
    jl .done_s2i8        ; no digito
    cmp cl, '9'
    jg .done_s2i8        ; no digito
    sub cl, '0'          ; char a num (cl)
    
    ; al = al*10 + cl
    push rdx             ; guardar rdx
    mov dl, al           ; dl = acumulador_actual
    push r10             ; guardar r10 (base)
    mov al, dl           ; al = acumulador_actual (para mul)
    mov dl, r10b         ; dl = 10 (parte baja de r10)
    mul dl               ; ax = al * dl (acum_actual * 10). resultado en ax.
    pop r10              ; restaurar r10
    pop rdx              ; restaurar rdx
    add al, cl           ; al = (acum_actual * 10) + nuevo_digito
    
    jmp .loop_s2i8
.done_s2i8:
    ret                  ; al tiene num



    

;--- convierte int16 a cadena (revisado v2) ---
; ax: numero (16b)
; rdi: buffer salida
; rdx: longitud (salida)
int16_to_string:
    push rbp
    mov rbp, rsp
    sub rsp, 16          ; temp local

    lea rsi, [rbp - 8]
    mov byte [rsi], 0
    dec rsi

    mov rbx, 10
    mov rcx, 0
    mov r10, 0           ; flag signo

    test ax, ax
    jns .positive_num_i2s
    mov r10, 1
    neg ax

.positive_num_i2s:
    cmp ax, 0
    jne .conversion_loop_i2s
    mov byte [rsi], '0'
    dec rsi
    inc rcx
    jmp .check_sign_i2s

.conversion_loop_i2s:
    cmp ax, 0
    je .check_sign_i2s
    xor dx, dx
    div rbx
    add dl, '0'
    mov [rsi], dl
    dec rsi
    inc rcx
    jmp .conversion_loop_i2s

.check_sign_i2s:
    cmp r10, 1
    jne .copy_to_output_i2s
    mov byte [rsi], '-'
    dec rsi
    inc rcx

.copy_to_output_i2s:
    inc rsi
    mov rdx, rcx
    
.copy_char_loop_i2s:
    cmp rdx, 0
    je .done_copy_i2s
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rdx
    jmp .copy_char_loop_i2s

.done_copy_i2s:
    mov byte [rdi], 0
    mov rdx, rcx

    mov rsp, rbp
    pop rbp
    ret





_start:
    ; --- bienvenida ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_bienvenida
    mov rdx, len_bienvenida
    syscall

    ; --- pedir/leer num1 (8 bits) ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_num1
    mov rdx, len_msg_num1
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer_num
    mov rdx, 4
    syscall
    mov rsi, buffer_num
    call string_to_int8  ; res en al
    mov cl, al           ; cl = num1



    ; --- pedir/leer num2 (8 bits) ---

    push rcx             ; <<<< GUARDAR num1 (cl)
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_num2
    mov rdx, len_msg_num2
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer_num
    mov rdx, 4
    syscall
    mov rsi, buffer_num
    call string_to_int8  ; res en al 
    mov bl, al           ; bl = num2
    pop rcx              ; <<<< RESTAURAR num1 
    
    ; --- multiplicacion (8 bits * 8 bits -> 16 bits) ---
    mov al, cl           ; al = num1 
    mul bl               ; ax = al * bl 




                         
    ; --- mostrar resultado ---

    push ax              ; guardar res
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_resultado_final
    mov rdx, len_resultado_final
    syscall
    pop ax               ; restaurar res

    mov rdi, buffer_resultado
    call int16_to_string ; convertir ax a cadena
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer_resultado
    syscall              ; imprimir num

    mov rax, 1           ; imprimir LF
    mov rdi, 1
    mov byte [buffer_num], 0Ah
    mov rsi, buffer_num
    mov rdx, 1
    syscall








    ; --- terminar ---
    mov rax, 60          ; sys_exit
    xor rdi, rdi         ; ok
    syscall