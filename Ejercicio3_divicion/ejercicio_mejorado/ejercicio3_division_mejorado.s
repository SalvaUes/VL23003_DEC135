; archivo: ejercicio3_division_mejorado.s

section .data
    msg_bienvenida db "division de dos numeros", 0Ah, 0
    len_bienvenida equ $ - msg_bienvenida

    msg_dividendo db "ingrese dividendo: ", 0
    len_dividendo equ $ - msg_dividendo

    msg_divisor db "ingrese divisor: ", 0
    len_divisor equ $ - msg_divisor

    msg_cociente db "cociente: ", 0
    len_cociente equ $ - msg_cociente
    
    msg_residuo db ", residuo: ", 0
    len_residuo equ $ - msg_residuo

    msg_err_div_cero db "error: division por cero no permitida.", 0Ah, 0
    len_err_div_cero equ $ - msg_err_div_cero

section .bss
    buffer_num resb 12       ; buffer entrada
    buffer_resultado resb 12 ; buffer salida







section .text
    global _start        ; inicio


;--- convierte cadena a int32 ---

; rsi: buffer entrada
; eax: resultado (numero 32b)
; Clobbers: eax, ecx, edx, rsi, r10d, r11d
string_to_int32:
    xor eax, eax         ; eax = 0 (acumulador)
    mov ecx, 0           ; ecx = sign_flag
    mov r10d, 10         ; r10d = 10 (base)
    xor r11d, r11d       ; r11d para el digito

    cmp byte [rsi], '-'  ; negativo?
    jne .s2i32_digit_loop
    mov ecx, 1           ; si, marcar neg
    inc rsi              ; saltar '-'

.s2i32_digit_loop:
    movzx r11d, byte [rsi] ; r11d tiene char
    inc rsi
    cmp r11b, 0Ah        ; enter? (para comparar el byte)
    je .s2i32_apply_sign
    cmp r11b, '0'
    jl .s2i32_apply_sign ; no digito
    cmp r11b, '9'
    jg .s2i32_apply_sign ; no digito
    sub r11b, '0'        ; r11b es digito numerico

    ; eax = eax * 10 + r11b
    push rdx             ; mul r32 usa edx:eax
                         ; eax ya tiene el acumulador
    mul r10d             ; edx:eax = eax * r10d (eax * 10)
                         ; para numeros de 32b
    pop rdx
    add eax, r11d        ; eax = (eax*10) + digito
    jmp .s2i32_digit_loop

.s2i32_apply_sign:
    cmp ecx, 1           ; fue neg?
    jne .s2i32_fin
    neg eax              ; aplicar signo
.s2i32_fin:
    ret                  ; eax tiene num






;--- convierte int32 a cadena ---

; eax: numero (32b)
; rdi: buffer salida
; rdx: longitud (salida)
int32_to_string:
    push rbp
    mov rbp, rsp
    sub rsp, 16          ; temp local

    lea rsi, [rbp - 8]
    mov byte [rsi], 0
    dec rsi

    mov ebx, 10
    xor ecx, ecx
    mov r10d, 0          ; flag signo

    test eax, eax
    jns .positive_num_i2s32
    mov r10d, 1
    neg eax

.positive_num_i2s32:
    cmp eax, 0
    jne .conversion_loop_i2s32
    mov byte [rsi], '0'
    dec rsi
    inc ecx
    jmp .check_sign_i2s32

.conversion_loop_i2s32:
    cmp eax, 0
    je .check_sign_i2s32
    xor edx, edx
    div ebx
    add dl, '0'
    mov [rsi], dl
    dec rsi
    inc ecx
    jmp .conversion_loop_i2s32

.check_sign_i2s32:
    cmp r10d, 1
    jne .copy_to_output_i2s32
    mov byte [rsi], '-'
    dec rsi
    inc ecx

.copy_to_output_i2s32:
    inc rsi
    mov edx, ecx
    
.copy_char_loop_i2s32:
    cmp edx, 0
    je .done_copy_i2s32
    mov al, [rsi] ; usa al temporalmente
    mov [rdi], al
    inc rsi
    inc rdi
    dec edx
    jmp .copy_char_loop_i2s32

.done_copy_i2s32:
    mov byte [rdi], 0
    mov edx, ecx

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





    ; --- pedir/leer dividendo (32 bits) ---


    mov rax, 1
    mov rdi, 1
    mov rsi, msg_dividendo
    mov rdx, len_dividendo
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer_num
    mov rdx, 11
    syscall
    mov rsi, buffer_num
    call string_to_int32 ; res en eax
    mov r12d, eax        ; r12d = dividendo

    ; --- pedir/leer divisor (32 bits) ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_divisor
    mov rdx, len_divisor
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer_num
    mov rdx, 11
    syscall
    mov rsi, buffer_num
    call string_to_int32 ; res en eax
    mov r13d, eax        ; r13d = divisor




    ; --- division (32 bits) ---

    cmp r13d, 0          ; divisor es cero?
    je .division_por_cero

    mov eax, r12d        ; eax = dividendo
    mov ebx, r13d        ; ebx = divisor
    cdq                  ; extender eax a edx:eax
    idiv ebx             ; eax = coc, edx = res
    
    mov r14d, eax        ; r14d = cociente
    mov r15d, edx        ; r15d = residuo
    jmp .mostrar_resultados

.division_por_cero:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_err_div_cero
    mov rdx, len_err_div_cero
    syscall
    jmp .terminar_programa_final ; ir a salida comun






.mostrar_resultados:

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_cociente
    mov rdx, len_cociente
    syscall

    mov eax, r14d
    mov rdi, buffer_resultado
    call int32_to_string
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer_resultado
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_residuo
    mov rdx, len_residuo
    syscall

    mov eax, r15d
    mov rdi, buffer_resultado
    call int32_to_string
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer_resultado
    syscall

    mov rax, 1
    mov rdi, 1
    mov byte [buffer_num], 0Ah
    mov rsi, buffer_num
    mov rdx, 1
    syscall





.terminar_programa_final: ; y para salir
    mov rax, 60
    xor rdi, rdi
    syscall