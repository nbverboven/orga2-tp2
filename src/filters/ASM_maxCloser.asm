%define tamanio_pixel 4

global ASM_maxCloser
extern C_maxCloser

; rdi 	-> puntero src    	(uint8_t)
; rsi 	-> srcw   			(uint32_t)
; rdx 	-> srch   			(uint32_t)
; rcx 	-> puntero dst    	(uint8_t)
; r8  	-> dstw    			(uint32_t)
; r9  	-> dsth    			(uint32_t)
; xmm0 	-> val				(float)

ASM_maxCloser:

section .rodata

	pasaR: db 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff 
	pasaG: db 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00
	pasaB: db 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00
	pasaA: db 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00

	soloRGB: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff
	soloA: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00

section .text

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
        mov r11, rsi
        pshufd xmm0, xmm0, 0x00

        xor rdi, rdi
        xor rax, rax

        mov eax, esi  	
        mov edi, edx  
        mul edi         
        add rax, rax	
        mov r15, rax
        add r15, r15    ;r15= srcw*srch*4. Es la cantidad de bytes de la imagen

        xorps xmm9, xmm9
        xor eax, eax
        inc eax
        cvtsi2ss xmm9, eax
        subps xmm9, xmm0	;xmm9= [---- | ---- | ---- | 1-Val]
        pshufd xmm9, xmm9, 0x00

        xor rsi, rsi
        xor r9, r9		;Indice de fila
        xor rcx, rcx	;Indice de columna
        xor rbx, rbx	;Indice que se mueve por la imagen entera
        xorps xmm5, xmm5
        xorps xmm6, xmm6
        xorps xmm7, xmm7
        xorps xmm8, xmm8

    ;-----------------------------------------------------------;
    ; rdi: Se usa en buscoMaximo para llamar a get_in_range 	;
    ; rsi: Se usa en buscoMaximo para llamar a get_in_range2	;													
    ; rcx: Indice de columna global 							;
    ; r8: Tamanio de la fila en bytes							;
    ; r9: Indice de fila global									;
    ; r11: Tamanio fila en pixeles								;
    ; r12: Puntero a src										;
    ; r13: Puntero a dst										;
    ; r14: Marca el final de la fila 							;
    ; rsp: Resultado de get_in_range2							;
    ; rsp+8: Resultado de get_in_range columna 					;
    ; rsp+16: Resultado de get_in_range fila					;
    ; rsp+24: srch												;
    ; xmm8: Guarda los 4 pixeles mas grandes de un kernel		;
    ;-----------------------------------------------------------;
    	push r9
    	push r9
    	push r9
        jmp .buscoMaximo

    .ciclo:
    	pop rax
    	pop rax
    	pop rax

    	movdqu xmm1, xmm8
    	movdqu xmm2, xmm8
    	movdqu xmm3, xmm8
    	psrldq xmm1, 12
    	psrldq xmm2, 8
    	psrldq xmm3, 4
    	maxps xmm1, xmm8
    	maxps xmm1, xmm2
    	maxps xmm1, xmm3 		;xmm1= [---- | ---- | ---- | maxPixelKernel]
    	
    	punpcklbw xmm1, xmm1
    	punpcklwd xmm1, xmm1	;xmm1= [A | B | G | R]
    	cvtdq2ps xmm1, xmm1
    	mulps xmm1, xmm0 		;xmm1= [---- | Val*maxB | Val*maxG | Val*maxR]

    	xorps xmm2, xmm2
    	movd xmm2, [r12+rbx]
    	punpcklbw xmm2, xmm2
    	punpcklwd xmm2, xmm2	;xmm2= [A | B | G | R]
    	cvtdq2ps xmm2, xmm2
    	mulps xmm2, xmm9		;xmm2= [---- | (1-Val)*B | (1-Val)*G | (1-Val)*R]

    	addps xmm1, xmm2 		;xmm1= [---- | (1-Val)*B+Val*maxB | (1-Val)*G+Val*maxG | (1-Val)*R+Val*maxR]

    	cvtps2dq xmm1, xmm1
    	packusdw xmm1, xmm1
    	packuswb xmm1, xmm1

    	xorps xmm2, xmm2
    	movd xmm2, [r12+rbx]
    	pand xmm2, [soloA]
    	pand xmm1, [soloRGB]
    	por xmm1, xmm2 			;Le agrego al pixel obtenido la componente A que se mantiene siempre igual
    	movd [r13+rbx], xmm1

    	add rbx, tamanio_pixel
    	inc rcx
    	cmp rbx, r15
    	je .fin
    	cmp rbx, r14
    	je .actualizarFilaYColumnaGlobal

    .mirarBordes:	
    	mov rdi, r9
    	call get_in_range 			;Miro el borde de arriba
    	push rax
    	
    	mov rdi, rcx
    	call get_in_range 			;Miro el borde izquierdo
    	add rax, rax
    	add rax, rax
    	push rax

    	mov rdi, rcx
    	mov rsi, r11
    	call get_in_range2			;Miro el borde derecho
    	push rax
    
    .buscoMaximo:

    	xor rax, rax
    	mov rax, [rsp+16]
    	mul r8
    	add rax, [rsp+8]
    	add rax, rbx
    	movdqu xmm1, [r12+rax]	;xmm1=[kernel[1][1] | kernel[1][2] | [kernel[1][3] | kernel[1][4]]
    	sub rax, [rsp+8]			

    	add rax, [rsp]
    	movdqu xmm2, [r12+rax]	;xmm2= [kernel[1][4] | kernel[1][5] | [kernel[1][6] | kernel[1][7]] Esto puede variar
    	
    	movdqu xmm3, xmm1
    	movdqu xmm4, xmm2
    	pand xmm3, [pasaR]	
    	pand xmm4, [pasaR] 	
    	maxps xmm5, xmm3
    	maxps xmm5, xmm4							;xmm5= [maxFila_R | maxFila_R | maxFila_R | maxFila_R]

    	movdqu xmm3, xmm1
    	movdqu xmm4, xmm2
    	pand xmm3, [pasaG]
    	pand xmm4, [pasaG]
    	maxps xmm6, xmm3
    	maxps xmm6, xmm4							;xmm6= [maxFila_G | maxFila_G | maxFila_G | maxFila_G]

    	movdqu xmm3, xmm1
    	movdqu xmm4, xmm2
    	pand xmm3, [pasaB]
    	pand xmm4, [pasaB]
    	maxps xmm7, xmm3
    	maxps xmm7, xmm4							;xmm7= [maxFila_B | maxFila_B | maxFila_B | maxFila_B]

    	por xmm5, xmm6
    	por xmm5, xmm7								;Vuelvo a armar los pixeles (sin la componente A)

    	maxps xmm8, xmm5							;[maxKernel | maxKernel | maxKernel | maxKernel]

    	cmp qword[rsp+16], 0
    	jge .actualizarFila
    	inc qword[rsp+16]
    	jmp .buscoMaximo

    .actualizarFilaYColumnaGlobal:
    	add r14, r8
    	inc r9
    	xor rcx, rcx
    	jmp .mirarBordes

    .actualizarFila:
    	cmp qword[rsp+16], 3
    	je .ciclo				;Si llegue a 3 termine de recorrer todas las filas del kernel y vuelvo al ciclo
    	inc qword[rsp+16]
    	mov rax, [rsp+24]
    	sub rax, [rsp+16]
    	sub rax, r9
    	cmp rax, 0
    	jle .ciclo
    	jmp .buscoMaximo

    .fin:
    	pop rax
        ; Desencolo
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx

ret

global get_in_range
get_in_range:

		push r12

		xor r12, r12
		xor rax, rax
		add r12, 3

		cmp rdi, r12
		jl .borde
		mov rax, -3
		jmp .fin

	.borde:
		mov rax, rdi
		sub rax, rdi
		sub rax, rdi

	.fin:
		pop r12

;Devuelve cuantas filas hacia arriba se puede empezar el kernel. Ej: Si estoy en la fila 7 devolveria -3, mientras que si estoy en la fila 0 devolveria 0, o si estoy en la 1 devolveria -1.
;Pasa exactamente lo mismo con las columnas. Se fija que tan a la izquierda puede ir.

ret

global get_in_range2
get_in_range2:

		push r12

		xor r12, r12
		add r12, 3
		sub rsi, rdi
		cmp rsi, r12
		jle .borde
		mov rax, 0
		jmp .fin

	.borde:		
		sub rsi, 4
		add rsi, rsi
		add rsi, rsi
		mov rax, rsi

	.fin:
		pop r12 

;Me dice que tan a la derecha puedo ir. Devuelve un numero tal que si estoy al final de la fila no se carguen valores de la siguiente fila (fila global) en el xmm. Ej: si el ancho de la imagen es 16 y estoy en el pixel 11 devolveria 0, ya que puedo cargar el actual y los tres que siguen. Si en cambio estoy en el pixel 15 (que es el ultimo ya que empiezo a contar desde cero), devolveria -3*4 y de esta manera volveria a cargar las posiciones -3, -2, -1 y 0 en el registro xmm. Si estuviese en el pixel 14 devolveria -2*4, etc.

ret