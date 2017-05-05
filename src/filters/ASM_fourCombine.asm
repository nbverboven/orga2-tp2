%define offset_ARGB 4

global ASM_fourCombine
extern C_fourCombine

;         ********    ATENCION!!     ********
;    Esta funcion esta siendo desarrollada por Federico.
;    En otras palbras, la modificas y te cago a trompadas.
;    Puto el que lee

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

        xor rdx, rdx
        xor rdi, rdi
        mov eax, rsi  	;eax= srcw
        mov edi, rdx  	;edi= srch
        mul edi         ;rax= srcw*srch
        mov rdi, rax	;rdi= srcw*srch
        add rdi, rdi
        mov ebx, offset_ARGB
        mul ebx         ;rax= srcw*srch*4
        mov r15, rax    ;r15= srcw*srch*4. Es la cantidad de bytes de la imagen

        xor rbx, rbx
        xor r9, r9

	.ciclo:
		cmp rbx, r15
		je .fin
		cmp rbx, r14
		je .actualizarRBX

		movdqu xmm2, [r12+rbx] 			; xmm2 = [pixel[1][1] | pixel[1][2] | pixel[1][3] | pixel[1][4]]
		movdqu xmm1, [r12+rbx+16]		; xmm1 = [pixel[1][5] | pixel[1][6] | pixel[1][7] | pixel[1][8]]
		movdqu xmm0, xmm1				; xmm0 = [pixel[1][5] | pixel[1][6] | pixel[1][7] | pixel[1][8]]

		shufps xmm0, xmm2, 0xDD			; xmm0 = [pixel[1][1] | pixel[1][3] | pixel[1][5] | pixel[1][7]]
		shufps xmm1, xmm2, 0x88			; xmm1 = [pixel[1][2] | pixel[1][4] | pixel[1][6] | pixel[1][8]]

		movdqu xmm4, [r12+rbx+4*r8] 	; xmm4 = [pixel[2][1] | pixel[2][2] | pixel[2][3] | pixel[2][4]]
		movdqu xmm3, [r12+rbx+4*r8+16] 	; xmm3 = [pixel[2][5] | pixel[2][6] | pixel[2][7] | pixel[2][8]]
		movdqu xmm2, xmm3				; xmm2 = [pixel[2][5] | pixel[2][6] | pixel[2][7] | pixel[2][8]]

		shufps xmm2, xmm4, 0xDD			; xmm2 = [pixel[2][1] | pixel[2][3] | pixel[2][5] | pixel[2][7]]
		shufps xmm3, xmm4, 0x88			; xmm3 = [pixel[2][2] | pixel[2][4] | pixel[2][6] | pixel[2][8]]

		movdqu [r13+r9], xmm0
		movdqu [r13+r9+(2*r8)], xmm1
		movdqu [r13+r9+rdi], xmm2
		movdqu [r13+r9+rdi+(2*r8)], xmm3

		add rbx, 32
		add r9, 16
		jmp .ciclo

	.actualizarRBX:
		add rbx, rsi 	; Me salteo una fila porque en el ciclo avanzo de a dos
		add r14, rbx 
		add r9, rsi
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