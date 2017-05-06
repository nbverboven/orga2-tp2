%define siguiente_pixel 4
%define tamanio_kernel 196

global ASM_maxCloser
extern C_maxCloser

;         ********    ATENCION!!     ********
;    Esta funcion esta siendo desarrollada por Federico.
;    En otras palbras, la modificas y te cago a trompadas.
;    Puto el que lee

; rdi 	-> puntero src    	(uint8_t)
; rsi 	-> srcw   			(uint32_t)
; rdx 	-> srch   			(uint32_t)
; rcx 	-> puntero dst    	(uint8_t)
; r8  	-> dstw    			(uint32_t)
; r9  	-> dsth    			(uint32_t)
; xmm0 	-> val				(float)

ASM_maxCloser:

		push rbx
        push r12
        push r13
        push r14
        push r15
        ; Pila alineada

        mov r12, rdi    ;r12= puntero src
        mov r13, rcx    ;r13= puntero dst
        mov r14, rsi	
        add r14, r14
        add r14, r14	;r14= srcw*4. Es la cantidad de bytes de una fila
        add r8, r8
        add r8, r8		;r8= dstw*4
        push rdx	

        xor rdi, rdi
        xor rax, rax

        mov eax, esi  	
        mov edi, edx  
        mul edi         
        add rax, rax	
        mov r15, rax
        add r15, r15    ;r15= srcw*srch*4. Es la cantidad de bytes de la imagen

        xor rsi, rsi
        movq rdx, xmm0 	;rsi= val 

        xor r9, r9		;Indice de fila
        xor rcx, rcx	;Indice de columna
        xor rbx, rbx	;Indice que se mueve por la imagen entera
        xorps xmm0, xmm0
        xorps xmm5, xmm5
        xorps xmm6, xmm6
        xorps xmm7, xmm7

    ;-----------------------------------------------------------;
    ; rdi: Se usa en buscoMaximo para llamar a get_in_range 	;
    ; rsi: Se usa en buscoMaximo para llamar a get_in_range		;
    ; rdx: Val													;
    ; rcx: Indice de columna global 							;
    ; r8: Tamanio de la fila en bytes							;
    ; r9: Indice de fila global									;
    ; r12: Puntero a src										;
    ; r13: Puntero a dst										;
    ; r14: Marca el final de la fila 							;
    ; rsp: Resultado de get_in_range columna 					;
    ; rsp+8: Resultado de get_in_range fila						;
    ; rsp+16: srch												;
    ; xmm0: Guarda los 4 pixeles mas grandes de un kernel		;
    ;-----------------------------------------------------------;

        jmp .buscoMaximo

    .ciclo:
    	add rbx, siguiente_pixel
    	inc rcx
    	mov xmm1, xmm0
    	mov xmm2, xmm0
    	mov xmm3, xmm0
    	;aca me tengo que quedar con el maximo de los maximos y almacenarlo en algun registro
    	;aca va la transformacion lineal
    	cmp rbx, r15
    	je .fin
    	cmp rbx, r14
    	je .actualizarFilaYColumnaGlobal
    	mov rdi, r9
    	call get_in_range 					;Miro el borde de arriba
    	push rax
    	mov rdi, rcx
    	call get_in_range 					;Miro el borde izquierdo
    	push rax
    
    .buscoMaximo:

    	mov rax, [rsp+8]
    	mul r8
    	add rax, [rsp]
    	movdqu xmm1, [r12+rbx+rax]	;xmm1=[kernel[1][1] | kernel[1][2] | [kernel[1][3] | kernel[1][4]]
    	sub rax, [rsp]			
    	push rax

    	mov rsi, r14
    	call get_in_range2			;Miro el borde derecho
    	add rax, [rsp]
    	movdqu xmm2, [r12+rbx+rax]	;xmm2=[kernel[1][4] | kernel[1][5] | [kernel[1][6] | kernel[1][7]] Esto puede variar
    	
    	movdqu xmm3, xmm1
    	movdqu xmm4, xmm2
    	pand xmm3, mascara que deja pasar solo R
    	pand xmm4, mascara que deja pasar solo R
    	maxps xmm5, xmm3
    	maxps xmm5, xmm4

    	movdqu xmm3, xmm1
    	movdqu xmm4, xmm2
    	pand xmm3, mascara que deja pasar solo G
    	pand xmm4, mascara que deja pasar solo G
    	maxps xmm6, xmm3
    	maxps xmm6, xmm4

    	movdqu xmm3, xmm1
    	movdqu xmm4, xmm2
    	pand xmm3, mascara que deja pasar solo B
    	pand xmm4, mascara que deja pasar solo B
    	maxps xmm7, xmm3
    	maxps xmm7, xmm4

    	pand xmm1, mascara que deja pasar solo A

    	por xmm1, xmm5
    	por xmm1, xmm6
    	por xmm1, xmm7								;Vuelvo a armar los pixeles

    	maxps xmm0, xmm1							;Me quedo con el maximo entre esta fila y la anterior
    	pop rax

    	cmp [rsp+8], 0
    	jge .actualizarFila
    	inc [rsp+8]
    	jmp .buscoMaximo

    .actualizarFilaYColumnaGlobal:
    	add r14, r8
    	inc r9
    	xor rcx, rcx
    	jmp .buscoMaximo

    .actualizarFila:
    	cmp [rsp+8], 3
    	je .ciclo
    	inc [rsp+8]
    	mov rax, [rsp+16]
    	sub rax, [rsp+8]
    	sub rax, r9
    	cmp rax, 0
    	jl .ciclo
    	jmp .buscoMaximo

    .fin:
        ; Desencolo
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx

ret

get_in_range:

Devuelve cuantas filas hacia arriba se puede empezar el kernel. Ej: Si estoy en la fila 7 devolveria -3, mientras que si estoy en la fila 0 devolveria 0, o si estoy en la 1 devolveria -1.
Pasa exactamente lo mismo con las columnas. Se fija que tan a la izquierda puede ir.

ret

get_in_range2:

Me dice que tan a la derecha puedo ir. Devuelve un numero tal que si estoy al final de la fila no se carguen valores de la siguiente fila en el xmm. Ej: si el ancho de la imagen es 16 y estoy en el pixel 11 devolveria cero, ya que puedo cargar el actual y los tres que siguen. Si en cambio estoy en el pixel 15 (que es el ultimo ya que empiezo a contar desde cero), devolveria -3 y de esta manera volveria a cargar las posiciones -3, -2, -1 y 0 en el registro xmm. Si estuviese en el pixel 14 devolveria -2, etc.

ret