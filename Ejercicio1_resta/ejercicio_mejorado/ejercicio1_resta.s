
; archivo: ejercicio1_resta.s
; Ing Girola a este codigo le he agregado algunas cosas extras para que sea mas interactivo con el buffer_usuario_ini



section .data
    msg_bienvenida db "bienvenido al programa de resta de tres numeros", 0Ah, 0
    len_bienvenida equ $ - msg_bienvenida

    msg_num1 db "ingrese el primer numero (entero): ", 0
    len_msg_num1 equ $ - msg_num1

    msg_num2 db "ingrese el segundo numero (entero): ", 0
    len_msg_num2 equ $ - msg_num2

    msg_num3 db "ingrese el tercer numero (entero): ", 0
    len_msg_num3 equ $ - msg_num3

    msg_final_resultado db "el resultado del primer - el segundo - el tercer numero es: ", 0
    len_final_resultado equ $ - msg_final_resultado

section .bss
    buffer_num resb 8        ; buffer entrada
    buffer_resultado resb 8  ; buffer salida num





section .text
    global _start        ; inicio

;--- convierte cadena a int16 ---
; rsi: buffer entrada
; ax: resultado (numero 16b)
string_to_int16:
    mov ax, 0            ; res
    mov rbx, 10          ; base ; 
.loop:
    movzx dx, byte [rsi] ; leer char
    inc rsi              ; sig char
    cmp dl, 0Ah          ; es enter?
    je .done             ; si, fin
    cmp dl, '0'
    jl .done             ; no digito, fin
    cmp dl, '9'
    jg .done             ; no digito, fin
    sub dl, '0'          ; char a num
    push ax
    mov al, dl
    cbw
    mov dx, ax
    pop ax
    imul ax, bx          ; ax *= 10 (usa rbx)
    add ax, dx           ; ax += digito
    jmp .loop
.done:
    ret                  ; ax tiene num






;--- convierte int16 a cadena (revisado) ---

; ax: numero (16b)
; rdi: buffer salida
; rdx: longitud (salida)
int16_to_string:
    push rbp
    mov rbp, rsp
    sub rsp, 16          ; espacio local temp

    mov r8, rdi          ; r8 = buffer_usuario_ini
    lea r9, [rbp - 9]
    mov byte [r9], 0     ; null al final de temp
    dec r9               ; r9 apunta donde va ultimo digito

    mov r10, 10          ; divisor
    mov r11, 0           ; r11=0 (pos), r11=1 (neg)

    test ax, ax
    jns .make_positive
    mov r11, 1
    neg ax

.make_positive:
    cmp ax, 0
    jne .convert_loop
    mov byte [r9], '0'   ; num es 0
    dec r9
    jmp .copy_to_user_buffer

.convert_loop:
    cmp ax, 0
    je .done_converting
    xor dx, dx
    div r10
    add dl, '0'
    mov [r9], dl
    dec r9
    jmp .convert_loop

.done_converting:
    cmp r11, 1
    jne .copy_to_user_buffer
    mov byte [r9], '-'
    dec r9

.copy_to_user_buffer:
    inc r9
    mov rcx, 0
.copy_loop:
    mov dl, [r9]
    mov [r8], dl
    inc r9
    inc r8
    inc rcx
    cmp dl, 0
    jne .copy_loop
    dec rcx
    mov rdx, rcx

    mov rsp, rbp
    pop rbp
    ret





_start:
    ; --- mensaje bienvenida ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_bienvenida
    mov rdx, len_bienvenida
    syscall





    ; --- pedir/leer num1 ---

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_num1
    mov rdx, len_msg_num1
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer_num
    mov rdx, 7
    syscall
    mov rsi, buffer_num
    call string_to_int16
    mov bp, ax           ; bp = num1



    ; --- pedir/leer num2 ---

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_num2
    mov rdx, len_msg_num2
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer_num
    mov rdx, 7
    syscall
    mov rsi, buffer_num
    call string_to_int16
    mov bx, ax           ; bx = num2




    ; --- pedir/leer num3 ---

    push bx                 ; <<<< ---- GUARDAR BX (num2) ANTES DE QUE string_to_int16 LO CAMBIE
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_num3
    mov rdx, len_msg_num3
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer_num
    mov rdx, 7
    syscall
    mov rsi, buffer_num
    call string_to_int16
    mov cx, ax           ; cx = num3
    pop bx                  ; <<<< ---- RESTAURAR BX (num2)
    


    ; --- resta (16 bits) ---

    mov ax, bp           ; ax = num1
    sub ax, bx           ; ax -= num2
    sub ax, cx           ; ax -= num3
                         ; res en ax




    ; --- mostrar resultado ---

    push ax              ; guardar res
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_final_resultado ; nuevo mensaje
    mov rdx, len_final_resultado
    syscall
    pop ax               ; restaurar res

    mov rdi, buffer_resultado
    call int16_to_string ; convertir ax a cadena
                         ; rdx tiene long
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