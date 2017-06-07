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

; ASM_maxCloser:

; section .rodata

; 	pasaR: dd 0xff000000, 0xff000000, 0xff000000, 0xff000000
; 	pasaG: dd 0x00ff0000, 0x00ff0000, 0x00ff0000, 0x00ff0000
; 	pasaB: dd 0x0000ff00, 0x0000ff00, 0x0000ff00, 0x0000ff00
; 	pasaA: dd 0x000000ff, 0x000000ff, 0x000000ff, 0x000000ff  
; 	pasaBGR: dd 0xffffff00, 0x00000000, 0x00000000, 0x00000000
; 	blanco: dd 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff

; section .text

; 		push rbx
;         push r12
;         push r13
;         push r14
;         push r15
;         ; Pila alineada

;         mov r12, rdi    ;r12= puntero src
;         mov r13, rcx    ;r13= puntero dst
;         mov r14, rsi	
;         add r14, r14
;         add r14, r14	;r14= srcw*4. Es la cantidad de bytes de una fila
;         add r8, r8
;         add r8, r8		;r8= dstw*4
;         push rdx	
;         mov r11, rsi
;         pshufd xmm0, xmm0, 0x00

;         xor rdi, rdi
;         xor rax, rax

;         mov eax, esi  	
;         mov edi, edx  
;         mul edi         
;         add rax, rax	
;         mov r15, rax
;         add r15, r15    			;r15= srcw*srch*4. Es la cantidad de bytes de la imagen

;         xorps xmm9, xmm9
;         xor esi, esi
;         inc esi
;         cvtsi2ss xmm9, esi
;         subps xmm9, xmm0			;xmm9= [---- | ---- | ---- | 1-Val]
;         pshufd xmm9, xmm9, 0x00

;         xor rsi, rsi
;         xor r9, r9					
;         xor rcx, rcx				
;         xor rbx, rbx				;Indice que se mueve por la imagen entera
;         xorps xmm5, xmm5
;         xorps xmm6, xmm6
;         xorps xmm8, xmm8

;     ;-----------------------------------------------------------;
;     ; rdi: Se usa en buscoMaximo para llamar a get_in_range 	;
;     ; rsi: Se usa en buscoMaximo para llamar a get_in_range2	;													
;     ; rcx: Indice de columna global 							;
;     ; r8: Tamanio de la fila en bytes							;
;     ; r9: Indice de fila global									;
;     ; r11: srcw													;
;     ; r12: Puntero a src										;
;     ; r13: Puntero a dst										;
;     ; r14: Marca el final de la fila 							;
;     ; rsp: srch													;
;     ; xmm8: Guarda los 4 pixeles mas grandes de un kernel		;
;     ;-----------------------------------------------------------;

;     	mov rax, -3
;     	push rax

;         jmp .mirarBordes

;     .ciclo:

;     	pop rax

;     	movdqu xmm1, xmm7
;     	movdqu xmm2, xmm7
;     	movdqu xmm3, xmm7
;     	psrldq xmm1, 12
;     	psrldq xmm2, 8
;     	psrldq xmm3, 4
;     	pmaxub xmm7, xmm1
;     	pmaxub xmm7, xmm2
;     	pmaxub xmm7, xmm3		;xmm7= [---- | ---- | ---- | maxABGR]

;     	xorps xmm3, xmm3
;     	punpcklbw xmm7, xmm3
;     	punpcklwd xmm7, xmm3	;xmm7= [---- | maxB | maxG | maxR]
;     	cvtdq2ps xmm7, xmm7
;     	mulps xmm7, xmm0 		;xmm7= [---- | Val*maxB | Val*maxG | Val*maxR]

;     	xorps xmm2, xmm2
;     	movd xmm2, [r12+rbx]
;     	punpcklbw xmm2, xmm3
;     	punpcklwd xmm2, xmm3	;xmm2= [A | B | G | R]
;     	cvtdq2ps xmm2, xmm2
;     	mulps xmm2, xmm9		;xmm2= [---- | (1-Val)*B | (1-Val)*G | (1-Val)*R]

;     	addps xmm7, xmm2 		;xmm7= [---- | (1-Val)*B+Val*maxB | (1-Val)*G+Val*maxG | (1-Val)*R+Val*maxR]

;     	cvtps2dq xmm7, xmm7
;     	packusdw xmm7, xmm3
;     	packuswb xmm7, xmm3

;     	movd xmm2, [r12+rbx]	;xmm2= [0000 | 0000 | 0000 | ABGR]
;     	pand xmm2, [pasaA]		;xmm2= [0000 | 0000 | 0000 | A000]
;     	pand xmm7, [pasaBGR] 	;xmm7= [0000 | 0000 | 0000 | 0 nuevoB nuevoG nuevoR]
;     	por xmm7, xmm2 			;xmm7= [0000 | 0000 | 0000 | A nuevoB nuevoG nuevoR]

;     .pintoBlanco:
;     	movd [r13+rbx], xmm7

;     	add rbx, tamanio_pixel
;     	inc rcx
;     	cmp rbx, r15
;     	je .fin
;     	cmp rbx, r14
;     	je .actualizarFilaYColumnaGlobal

;     .mirarBordes:
;     	movdqu xmm7, [blanco]	
;     	mov rdi, r9
;     	call in_range 			;Miro el borde de arriba
;     	cmp rax, 0
;     	je .pintoBlanco
    	
;     	mov rdi, rcx
;     	call in_range 			;Miro el borde izquierdo
;     	cmp rax, 0
;     	je .pintoBlanco

;     	mov rdi, rcx
;     	mov rsi, r11
;     	call in_range2			;Miro el borde derecho
;     	cmp rax, 0
;     	je .pintoBlanco

;     	mov rdi, r9					;Miro el borde de abajo
;     	mov rsi, [rsp]
;     	call in_range2
;     	cmp rax, 0
;     	je .pintoBlanco

;     	mov rax, -3
;     	push rax
    
;     .buscoMaximo:

;     	xorps xmm7, xmm7

;     	mov rax, [rsp]
;     	imul r8
;     	sub rax, 12
;     	add rax, rbx
;     	movdqu xmm1, [r12+rax]	;xmm1=[kernel[1][1] | kernel[1][2] | [kernel[1][3] | kernel[1][4]]			

;     	add rax, 12
;     	movdqu xmm2, [r12+rax]	;xmm2= [kernel[1][4] | kernel[1][5] | [kernel[1][6] | kernel[1][7]]
    	
;     	pmaxub xmm7, xmm1
;     	pmaxub xmm7, xmm2		;xmm7= [maxABGR | maxABGR |maxABGR |maxABGR]

;     	cmp qword[rsp], 3
;     	je .ciclo
;     	inc qword[rsp]
;     	jmp .buscoMaximo

;     .actualizarFilaYColumnaGlobal:
;     	add r14, r8
;     	inc r9
;     	xor rcx, rcx
;     	jmp .mirarBordes

;     .fin:
;     	pop rax
;         ; Desencolo
;         pop r15
;         pop r14
;         pop r13
;         pop r12
;         pop rbx

; ret

; global in_range
; in_range:

; 		push r12

; 		xor r12, r12
; 		xor rax, rax
; 		add r12, 3

; 		cmp rdi, r12
; 		jl .borde
; 		mov rax, 1
; 		jmp .fin

; 	.borde:
; 		mov rax, 0

; 	.fin:
; 		pop r12

; ret

; global in_range2
; in_range2:

; 		push r12

; 		xor r12, r12
; 		add r12, 3
; 		sub rsi, rdi
; 		cmp rsi, r12
; 		jle .borde
; 		mov rax, 1
; 		jmp .fin

; 	.borde:		
; 		mov rax, 0

; 	.fin:
; 		pop r12 

; ret

; rdi   -> puntero src      (uint8_t)
; rsi   -> srcw             (uint32_t)
; rdx   -> srch             (uint32_t)
; rcx   -> puntero dst      (uint8_t)
; r8    -> dstw             (uint32_t)
; r9    -> dsth             (uint32_t)
; xmm0  -> val              (float)

    section .rodata

    blanco: dd 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff

    section .text

ASM_maxCloser:

        push rbx
        push r12
        push r13
        push r14
        push r15
        ; Pila alineada

        mov r12, rdi    ;r12 -> puntero imagen src 
        mov r13, rdx    ;r13 -> srch  
        mov r9, 4 

        mov rax, r13
        mul rsi
        mul r9
        mov r14, rax     ;r14 -> 4*srcw*srch 

        mov rax, rsi
        mul r9
        mov r8, rax     ;r8 -> 4*srcw

        xorps xmm15, xmm15
        xor r15, r15
        inc r15
        cvtsi2ss xmm15, r15
        subps xmm15, xmm0            
        pshufd xmm15, xmm15, 0x00  ;xmm15 -> [1-Val | 1-Val | 1-Val | 1-Val] 

        movdqu xmm14, xmm0          
        pshufd xmm14, xmm14, 0x00   ;xmm14 -> [Val | Val | Val | Val]

        xor rbx, rbx    ;rbx -> contador posicion global

    .ciclo:
        cmp rbx, r14
        jge .fin

        mov rdi, rbx
        mov rdx, r13
        call in_range       ;Me fijo si estoy en el margen de 3 pixeles
        cmp rax, 0
        je .pintarBlanco    ;Si estoy en el margen pinto el pixel de blanco
        mov rax, -3             
        mul r8              ;rax -> -3*srcw*4 Esquina inferior izquierda del kernel de 7x7

    .buscoMaximo:
        add rax, rbx         ;r8 -> posicion columna
        sub rax, 12
        movdqu xmm0, [r12+rax]      ;xmm0 -> [kernel[0][3] | kernel[0][2] | kernel[0][1] | kernel[0][0]]
        movdqu xmm1, [r12+rax+12]   ;xmm1 -> [kernel[0][6] | kernel[0][5] | kernel[0][4] | kernel[0][3]]

        add rax, r8                    ;rax -> -2*srcw
        movdqu xmm2, [r12+rax]      ;xmm2 -> [kernel[1][3] | kernel[1][2] | kernel[1][1] | kernel[1][0]]
        movdqu xmm3, [r12+rax+12]   ;xmm3 -> [kernel[1][6] | kernel[1][5] | kernel[1][4] | kernel[1][3]]

        add rax, r8                    ;rax -> -1*srcw
        movdqu xmm4, [r12+rax]      ;xmm4 -> [kernel[2][3] | kernel[2][2] | kernel[2][1] | kernel[2][0]]
        movdqu xmm5, [r12+rax+12]   ;xmm5 -> [kernel[2][6] | kernel[2][5] | kernel[2][4] | kernel[2][3]]

        add rax, r8                    ;rax -> 0*srcw
        movdqu xmm6, [r12+rax]      ;xmm6 -> [kernel[3][3] | kernel[3][2] | kernel[3][1] | kernel[3][0]]
        movdqu xmm7, [r12+rax+12]   ;xmm7 -> [kernel[3][6] | kernel[3][5] | kernel[3][4] | kernel[3][3]]

        add rax, r8                    ;rax -> 1*srcw
        movdqu xmm8, [r12+rax]      ;xmm8 -> [kernel[4][3] | kernel[4][2] | kernel[4][1] | kernel[4][0]]
        movdqu xmm9, [r12+rax+12]   ;xmm9 -> [kernel[4][6] | kernel[4][5] | kernel[4][4] | kernel[4][3]]

        add rax, r8                    ;rax -> 2*srcw
        movdqu xmm10, [r12+rax]     ;xmm10 -> [kernel[5][3] | kernel[5][2] | kernel[5][1] | kernel[5][0]]
        movdqu xmm11, [r12+rax+12]  ;xmm11 -> [kernel[5][6] | kernel[5][5] | kernel[5][4] | kernel[5][3]]

        add rax, r8                    ;rax -> 3*srcw
        movdqu xmm12, [r12+rax]     ;xmm12 -> [kernel[6][3] | kernel[6][2] | kernel[6][1] | kernel[6][0]]
        movdqu xmm13, [r12+rax+12]  ;xmm13 -> [kernel[6][6] | kernel[6][5] | kernel[6][4] | kernel[6][3]]

        pmaxub xmm0, xmm1
        pmaxub xmm0, xmm2
        pmaxub xmm0, xmm3
        pmaxub xmm0, xmm4
        pmaxub xmm0, xmm5
        pmaxub xmm0, xmm6
        pmaxub xmm0, xmm7
        pmaxub xmm0, xmm8
        pmaxub xmm0, xmm9
        pmaxub xmm0, xmm10
        pmaxub xmm0, xmm11
        pmaxub xmm0, xmm12
        pmaxub xmm0, xmm13

        movdqu xmm1, xmm0
        movdqu xmm2, xmm0
        movdqu xmm3, xmm0
        psrldq xmm1, 4
        psrldq xmm2, 8
        psrldq xmm3, 12
        pmaxub xmm0, xmm1
        pmaxub xmm0, xmm2
        pmaxub xmm0, xmm3       ;xmm0 -> [---- | ---- | ---- | maxRGBA]

        xorps xmm1, xmm1
        punpcklbw xmm0, xmm1
        punpcklwd xmm0, xmm1    ;xmm0= [maxR | maxG | maxB | ----]
        cvtdq2ps xmm0, xmm0
        mulps xmm0, xmm14        ;xmm0= [Val*maxR | Val*maxG | Val*maxB | ----]

        xorps xmm2, xmm2
        movd xmm2, [r12+rbx]
        punpcklbw xmm2, xmm1
        punpcklwd xmm2, xmm1    ;xmm2= [R | G | B | A]
        cvtdq2ps xmm2, xmm2
        mulps xmm2, xmm15        ;xmm2= [(1-Val)*R | (1-Val)*G | (1-Val)*B | ----]

        addps xmm0, xmm2        ;xmm0= [(1-Val)*R+Val*maxR | (1-Val)*G+Val*maxG | (1-Val)*B+Val*maxB | ----]

        cvtps2dq xmm0, xmm0
        packusdw xmm0, xmm1
        packuswb xmm0, xmm1

        movd [rcx+rbx], xmm0    ;Paso el pixel modificado a la nueva imagen

        add rbx, 4
        jmp .ciclo

    .pintarBlanco:
        movd xmm0, [blanco]
        movd [rcx+rbx], xmm0
        add rbx, 4
        jmp .ciclo


    .fin:
        ; Desencolo
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx

ret

global in_range
in_range:
        push r12
        push r13
        push r14
        push r15

        push rcx

        mov r14, rsi    ;r14 -> srcw
        mov rcx, 4
        mov r15, rdx    ;r15 -> srch

        xor rdx, rdx
        xor rax, rax

        mov rax, rdi    ;rdi -> posicion en la imagen*4
        div rcx
                        ;rax = rbx/4 -> pixel actual 

        div r14
        mov r12, rax    ;r12 = (rbx/4)/srcw -> fila en la que estoy parado
        mov r13, rdx    ;r13 -> columna actual

        cmp r12, 3
        jl .esBorde     ;Me fijo si estoy en el borde de arriba

        cmp r13, 3
        jl .esBorde     ;Me fijo si estoy en el borde izquierdo

        sub r15, r12
        cmp r15, 3
        jl .esBorde     ;Me fijo si estoy en el borde de abajo

        sub r14, rdx    
        cmp r14, 3
        jl .esBorde     ;Me fijo si estoy en el borde de la derecha

        mov rax, 1
        jmp .fin        

    .esBorde:
        mov rax, 0

    .fin:
        pop rcx
        pop r15
        pop r14
        pop r13
        pop r12
ret
