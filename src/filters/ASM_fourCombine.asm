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
	push       rbp
	mov        rbp, rsp
	push       rbx
	push       r12
	push       r13
	push       r14
	push       r15               ; Pila alineada

	mov        rsi, rsi
	mov        rdx, rdx           ; Limpio a parte alta de ambos registros

	lea        r8, [2*rsi]        ; r8 <- (4*srcw)/2 (la mitad del ancho de la imagen)
	lea        r9, [2*rdx]        ; r9 <- (4*srch)/2 (la mitad del alto de la imagen)

	mov        r12, rcx           ; Puntero a la última fila de la imagen nueva
	lea        r13, [r12 + r8]    ; Puntero a la mitad de la última fila de la imagen nueva

	mov        r10, rdx           ; Guardo rdx porque el valor va a ser pisado por la parte alta del resultado de mul
	mov        rax, r9
	mul        rsi
	mov        rdx, r10

	lea        r14, [r12 + rax]   ; Puntero al comienzo de la fila del medio de la imagen nueva
	lea        r15, [r13 + rax]   ; Puntero a la mitad de la fila del medio de la imagen nueva

	mov        r10, rdi           ; r10 <- &src[n-1][0]
	lea        r11, [rdi + 4*rsi] ; r11 <- &src[n-2][0]

	lea        rax, [4*rsi]
	mul        rdx                ; rax <- 4*srcw*srch
	lea        rax, [rdi + rax]

	xor        rbx, rbx           ; Contador de columnas de src. Inicia en 0


	.ciclo:
		cmp        r11, rax
		jge        .fin

		movdqu     xmm0, [r10] ; [ src[n-1][3] | src[n-1][2] | src[n-1][1] | src[n-1][0] ]
		movdqu     xmm1, [r11] ; [ src[n-2][3] | src[n-2][2] | src[n-2][1] | src[n-2][0] ]

		; [ 3 | 2 | 1 | 0 ] => [ - | - | 2 | 0 ] (-- -- 10 00 == ---- 1000 == 0x-8)
		; [ 3 | 2 | 1 | 0 ] => [ - | - | 3 | 1 ] (-- -- 11 01 == ---- 1101 == 0x-D)

		pshufd     xmm2, xmm0, 0x08 ; [ ----------- | ----------- | src[n-1][2] | src[n-1][0] ]
		pshufd     xmm3, xmm0, 0x0D ; [ ----------- | ----------- | src[n-1][3] | src[n-1][1] ]
		pshufd     xmm4, xmm1, 0x08 ; [ ----------- | ----------- | src[n-2][2] | src[n-2][0] ]
		pshufd     xmm5, xmm1, 0x0D ; [ ----------- | ----------- | src[n-2][3] | src[n-2][1] ]

		movq       [r12], xmm2
		movq       [r13], xmm3
		movq       [r14], xmm4
		movq       [r15], xmm5

		add        r12, 8
		add        r13, 8
		add        r14, 8
		add        r15, 8
		add        r10, 16
		add        r11, 16

		add        rbx, 4

		cmp        rbx, rsi
		jl         .fin_ciclo

		xor        rbx, rbx

		lea        r12, [r12 + r8]
		lea        r13, [r13 + r8]
		lea        r14, [r14 + r8]
		lea        r15, [r15 + r8]
		lea        r10, [r10 + 4*rsi]
		lea        r11, [r11 + 4*rsi]


		.fin_ciclo:
			jmp        .ciclo


	.fin:
		pop        r15
		pop        r14
		pop        r13
		pop        r12
		pop        rbx
		pop        rbp
		ret