%define offset_ARGB 4

global ASM_fourCombine
extern C_fourCombine

; rdi -> puntero src    (uint8_t)
; rsi -> srcw   		(uint32_t)
; rdx -> srch   		(uint32_t)
; rcx -> puntero dst    (uint8_t)
; r8  -> dstw    		(uint32_t)
; r9  -> dsth    		(uint32_t)

ASM_fourCombine:

        push rbx
        push r12
        push r13
        push r14
        push r15
        ; Pila alineada

        mov r12, rdi    ;r12= puntero src
        mov r13, rcx    ;r13= puntero dst
        mov r14, rsi	;r14= srcw
        add r14, r14
        add r14, r14	;r14= srcw*4. Es la cantidad de bytes de una fila

        xor rdi, rdi
        xor rax, rax

        mov eax, esi  	;eax= srcw
        mov edi, edx  	;edi= srch
        mul edi         ;rax= srcw*srch
        mov edi, eax	;rdi= srcw*srch
        add rdi, rdi	;rdi= srcw*srch*2. Es la mitad de la cantidad total de bytes de la imagen
        mov r15, rdi
        add r15, r15    ;r15= srcw*srch*4. Es la cantidad de bytes de la imagen

        xor rbx, rbx
        xor r9, r9
        add rsi, rsi	;rsi= srcw*2. Es la mitad de pixeles de la fila

	.ciclo:
		cmp rbx, r15
		je .fin
		cmp rbx, r14
		je .actualizarRBX

		movdqu xmm2, [r12+rbx] 			; xmm2 = [pixel[1][1] | pixel[1][2] | pixel[1][3] | pixel[1][4]]
		movdqu xmm0, xmm2				; xmm0 = [pixel[1][1] | pixel[1][2] | pixel[1][3] | pixel[1][4]]
		xorps xmm1, xmm1

		shufps xmm0, xmm2, 0xDD			; xmm0 = [---- | ---- | pixel[1][1] | pixel[1][3]]
		shufps xmm2, xmm1, 0x88			; xmm2 = [---- | ---- | pixel[1][2] | pixel[1][4]]

		xor rcx, rcx
		mov rcx, rsi
		add rcx, rcx
		add rcx, rbx
		movdqu xmm4, [r12+rcx] 			; xmm4 = [pixel[2][1] | pixel[2][2] | pixel[2][3] | pixel[2][4]]
		movdqu xmm1, xmm4				; xmm1 = [pixel[2][1] | pixel[2][2] | pixel[2][3] | pixel[2][4]]

		shufps xmm1, xmm4, 0xDD			; xmm1 = [---- | ---- | pixel[2][1] | pixel[2][3]]
		shufps xmm4, xmm4, 0x88			; xmm4 = [---- | ---- | pixel[2][2] | pixel[2][4]]

		xor rcx, rcx
		mov rcx, r9
		add rcx, rdi
		movq [r13+r9], xmm0
		movq [r13+rcx], xmm1

		xor rcx, rcx
		mov rcx, rsi
		add rcx, r9
		movq [r13+rcx], xmm2

		add rcx, rdi
		movq [r13+rcx], xmm4

		add rbx, 16
		add r9, 8
		jmp .ciclo

	.actualizarRBX:
		add rbx, rsi 
		add rbx, rsi	; Me salteo una fila porque en el ciclo avanzo de a dos
		add r14, rbx 
		add r9, rsi	
		jmp .ciclo

        .fin:
        ; Desencolo
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx

ret