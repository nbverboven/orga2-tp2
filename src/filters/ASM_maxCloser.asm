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

	pasaR: dd 0xff000000, 0xff000000, 0xff000000, 0xff000000
	pasaG: dd 0x00ff0000, 0x00ff0000, 0x00ff0000, 0x00ff0000
	pasaB: dd 0x0000ff00, 0x0000ff00, 0x0000ff00, 0x0000ff00
	pasaA: dd 0x000000ff, 0x000000ff, 0x000000ff, 0x000000ff  
	pasaBGR: dd 0xffffff00, 0x00000000, 0x00000000, 0x00000000
	blanco: dd 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff

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
        add r15, r15    			;r15= srcw*srch*4. Es la cantidad de bytes de la imagen

        xorps xmm9, xmm9
        xor esi, esi
        inc esi
        cvtsi2ss xmm9, esi
        subps xmm9, xmm0			;xmm9= [---- | ---- | ---- | 1-Val]
        pshufd xmm9, xmm9, 0x00

        xor rsi, rsi
        xor r9, r9					
        xor rcx, rcx				
        xor rbx, rbx				;Indice que se mueve por la imagen entera
        xorps xmm5, xmm5
        xorps xmm6, xmm6
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

    	movdqu xmm1, xmm7
    	movdqu xmm2, xmm7
    	movdqu xmm3, xmm7
    	psrldq xmm1, 12
    	psrldq xmm2, 8
    	psrldq xmm3, 4
    	pmaxub xmm7, xmm1
    	pmaxub xmm7, xmm2
    	pmaxub xmm7, xmm3		;xmm7= [---- | ---- | ---- | maxABGR]

    	xorps xmm3, xmm3
    	punpcklbw xmm7, xmm3
    	punpcklwd xmm7, xmm3	;xmm7= [---- | maxB | maxG | maxR]
    	cvtdq2ps xmm7, xmm7
    	mulps xmm7, xmm0 		;xmm7= [---- | Val*maxB | Val*maxG | Val*maxR]

    	xorps xmm2, xmm2
    	movd xmm2, [r12+rbx]
    	xorps xmm3, xmm3
    	punpcklbw xmm2, xmm3
    	punpcklwd xmm2, xmm3	;xmm2= [A | B | G | R]
    	cvtdq2ps xmm2, xmm2
    	mulps xmm2, xmm9		;xmm2= [---- | (1-Val)*B | (1-Val)*G | (1-Val)*R]

    	addps xmm7, xmm2 		;xmm7= [---- | (1-Val)*B+Val*maxB | (1-Val)*G+Val*maxG | (1-Val)*R+Val*maxR]

    	cvtps2dq xmm7, xmm7
    	packusdw xmm7, xmm7
    	packuswb xmm7, xmm7

    	xorps xmm2, xmm2
    	movd xmm2, [r12+rbx]	;xmm2= [0000 | 0000 | 0000 | ABGR]
    	pand xmm2, [pasaA]		;xmm2= [0000 | 0000 | 0000 | A000]
    	pand xmm7, [pasaBGR] 	;xmm7= [0000 | 0000 | 0000 | 0 nuevoB nuevoG nuevoR]
    	por xmm7, xmm2 			;xmm7= [0000 | 0000 | 0000 | A nuevoB nuevoG nuevoR]

    .pintoBlanco:
    	movd [r13+rbx], xmm7

    	add rbx, tamanio_pixel
    	inc rcx
    	cmp rbx, r15
    	je .fin
    	cmp rbx, r14
    	je .actualizarFilaYColumnaGlobal

    .mirarBordes:
    	movdqu xmm7, [blanco]	
    	mov rdi, r9
    	call get_in_range 			;Miro el borde de arriba
    	cmp rax, -3
    	jg .pintoBlanco
    	push rax
    	
    	mov rdi, rcx
    	call get_in_range 			;Miro el borde izquierdo
    	cmp rax, -3
    	jg .pintoBlancoA
    	add rax, rax
    	add rax, rax
    	push rax

    	mov rdi, rcx
    	mov rsi, r11
    	call get_in_range2			;Miro el borde derecho
    	cmp rax, 0
    	jl .pintoBlancoB
    	push rax
    
    .buscoMaximo:

    	xor rax, rax
    	xorps xmm7, xmm7
    	mov rax, [rsp+16]
    	imul r8
    	add rax, [rsp+8]
    	add rax, rbx
    	movdqu xmm1, [r12+rax]	;xmm1=[kernel[1][1] | kernel[1][2] | [kernel[1][3] | kernel[1][4]]
    	sub rax, [rsp+8]			

    	add rax, [rsp]
    	movdqu xmm2, [r12+rax]	;xmm2= [kernel[1][4] | kernel[1][5] | [kernel[1][6] | kernel[1][7]] Esto puede variar
    	
    	pmaxub xmm7, xmm1
    	pmaxub xmm7, xmm2		;xmm7= [maxABGR | maxABGR |maxABGR |maxABGR]

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
    	jle .pintoBlancoC
    	jmp .buscoMaximo

    .pintoBlancoA:
    	pop rax
    	jmp .pintoBlanco

    .pintoBlancoB:
    	pop rax
    	pop rax
    	jmp .pintoBlanco

    .pintoBlancoC:
    	movdqu xmm7, [blanco]
    	pop rax
    	pop rax
    	pop rax
    	jmp .pintoBlanco

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
		inc r12
		inc r12
		inc r12

		cmp rdi, r12
		jl .borde
		dec rax
		dec rax
		dec rax
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
		inc r12
		inc r12
		inc r12
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