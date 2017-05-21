global ASM_linearZoom
extern C_linearZoom


section .rodata



section .text

%define tam_ARGB 4


ASM_linearZoom:
; RDI := uint8_t* src, RSI := uint32_t srcw, RDX := uint32_t srch, 
; RCX := uint8_t* dst, R8 := uint32_t dstw, R9 := uint32_t dsth

	push         rbp
	mov          rbp, rsp
	push         rbx
	push         r12
	push         r13
	push         r14                ; Pila alineada

	shl          rdx, 8
	shr          rdx, 8
	shl          r8, 8
	shr          r8, 8
	shl          rsi, 8
	shr          rsi, 8

	mov          rax, rsi           ; rax <- srcw
	lea          rbx, [rdx - 1]     ; rbx <- srch-1
	mul          rbx                ; rax <- srcw*(srch-1)
	lea          rax, [rdi + 4*rax] ; rax <- rdi + 4*srcw*(srch-1)

	xor          r12, r12           ; Contador de columnas de dst
	lea          r14, [r8 - 4]      ; r14 <- dstw - 4
	pxor         xmm8, xmm8

	mov          rbx, rdi           ; rbx <- &src[srch-1][0]
	lea          r13, [rcx + 8*r8]  ; r13 <- &dst[dsth-3][0]

	; Genero los pixeles que van a ir en la imagen modificada (menos los bordes)
	.ciclo:

		;Me fijo si ya recorrí toda la imagen original
		cmp          rbx, rax
		jge          .empiezo_con_los_bordes

		; Versión 2.1

		movdqu       xmm0, [rbx]         ; xmm0 <- [ src[n-1][3] | src[n-1][2] | src[n-1][1] | src[n-1][0] ]
		movdqu       xmm1, [rbx + 4*rsi] ; xmm1 <- [ src[n-2][3] | src[n-2][2] | src[n-2][1] | src[n-2][0] ]

		movdqu       xmm2, xmm0
		movdqu       xmm3, xmm1

		pslldq       xmm0, 8             ; xmm0 <- [ src[n-1][1] | src[n-1][0] |      0      |      0      ]
		pslldq       xmm1, 8             ; xmm1 <- [ src[n-2][1] | src[n-2][0] |      0      |      0      ]

		psrldq       xmm2, 4             ; xmm2 <- [      0      | src[n-1][3] | src[n-1][2] | src[n-1][1] ]
		psrldq       xmm3, 4             ; xmm3 <- [      0      | src[n-2][3] | src[n-2][2] | src[n-2][1] ]

		punpckhbw    xmm0, xmm8 
		punpckhbw    xmm1, xmm8
		punpcklbw    xmm2, xmm8
		punpcklbw    xmm3, xmm8

		; xmm0 <- [ src[n-1][1] | src[n-1][0] ]
		; xmm1 <- [ src[n-2][1] | src[n-2][0] ]
		; xmm2 <- [ src[n-1][2] | src[n-1][1] ]
		; xmm3 <- [ src[n-2][2] | src[n-2][1] ]		

		movdqu       xmm4, xmm1
		paddw        xmm4, xmm0       ; xmm4 <- [ src[n-2][1] + src[n-1][1] | src[n-2][0] + src[n-1][0] ]
		movdqu       xmm6, xmm4
		psrlw        xmm4, 1          ; xmm4 <- [ (src[n-2][1] + src[n-1][1]) / 2 | (src[n-2][0] + src[n-1][0]) / 2 ]

		movdqu       xmm5, xmm3
		paddw        xmm5, xmm2       ; xmm5 <- [ src[n-2][2] + src[n-1][2] | src[n-2][1] + src[n-1][1] ]
		paddw        xmm6, xmm5       ; xmm6 <- [ src[n-2][1] + src[n-1][1] + src[n-2][2] + src[n-1][2] | src[n-2][0] + src[n-1][0] + src[n-2][1] + src[n-1][1] ]
		psrlw        xmm5, 1          ; xmm5 <- [ (src[n-2][2] + src[n-1][2]) / 2 | (src[n-2][1] + src[n-1][1]) / 2 ]
		psrlw        xmm6, 2          ; xmm6 <- [ (src[n-2][1] + src[n-1][1] + src[n-2][2] + src[n-1][2]) / 4 | (src[n-2][0] + src[n-1][0] + src[n-2][1] + src[n-1][1]) / 4 ]

		paddw        xmm3, xmm1
		psrlw        xmm3, 1          ; xmm3 <- [ (src[n-2][2] + src[n-2][1]) / 2 | (src[n-2][1] + src[n-2][0]) / 2 ]

		packuswb     xmm1, xmm8       ; xmm1 <- [      0      |      0      |           src[n-2][1]           |           src[n-2][0]           ]
		packuswb     xmm3, xmm8       ; xmm3 <- [      0      |      0      | (src[n-2][2] + src[n-2][1]) / 2 | (src[n-2][1] + src[n-2][0]) / 2 ]
		packuswb     xmm4, xmm8       ; xmm4 <- [      0      |      0      | (src[n-2][1] + src[n-1][1]) / 2 | (src[n-2][0] + src[n-1][0]) / 2 ]
		packuswb     xmm6, xmm8       ; xmm6 <- [      0      |      0      | (src[n-2][1] + src[n-1][1] + src[n-2][2] + src[n-1][2]) / 4 | (src[n-2][0] + src[n-1][0] + src[n-2][1] + src[n-1][1]) / 4 ]

		pslldq       xmm3, 8
		por          xmm1, xmm3       ; xmm1 <- [ (src[n-2][2] + src[n-2][1]) / 2 | (src[n-2][1] + src[n-2][0]) / 2 |           src[n-2][1]           | src[n-2][0] ]
		pshufd       xmm1, xmm1, 0xD8 ; xmm1 <- [ (src[n-2][2] + src[n-2][1]) / 2 |           src[n-2][1]           | (src[n-2][1] + src[n-2][0]) / 2 | src[n-2][0] ]

		pslldq       xmm6, 8
		por          xmm4, xmm6
		pshufd       xmm4, xmm4, 0xD8

		movdqu       [r13], xmm4
		movdqu       [r13 + 4*r8], xmm1

		add          rbx, 8
		add          r13, 16
		add          r12, 4

		; Veo si llegué al final de la columna, en cuyo caso muevo r13 dos filas arriba
		cmp          r12, r14
		jl           .fin_ciclo

		xor          r12, r12
		lea          r13, [r13 + 4*r8 + 16]

		add          rbx, 8

		.fin_ciclo:
			jmp          .ciclo


	.empiezo_con_los_bordes:
		; lea          rbx, [rdi + 4*rsi - 8] ; rbx <- &src[srch-1][srcw-2]
		lea          rbx, [rdi + 4*rsi - 16] ; rbx <- &src[srch-1][srcw-4]
		lea          r13, [rcx + 8*r8 - 16]
		lea          r13, [r13 + 4*r8]      ; rcx <- &dst[dsth-3][dstw-4]


	.ciclo_borde_derecho:
		cmp          rbx, rax
		jge          .listo_borde_derecho

		; ; Versión 1.1

		; movq         xmm0, [rbx]         ; xmm0 <- [ ----- | ----- | src[n-1][m-2] | src[n-1][m-1] ]
		; movq         xmm1, [rbx + 4*rsi] ; xmm1 <- [ ----- | ----- | src[n-2][m-2] | src[n-2][m-1] ]


		; punpcklbw    xmm0, xmm8          ; xmm0 <- [ src[n-1][m-2] | src[n-1][m-1] ]
		; punpcklbw    xmm1, xmm8          ; xmm1 <- [ src[n-2][m-2] | src[n-2][m-1] ]

		; movdqu       xmm2, xmm0
		; movdqu       xmm3, xmm1

		; paddw        xmm2, xmm1          ; xmm2 <- [ src[n-2][m-2] + src[n-1][m-2] | src[n-2][m-1] + src[n-1][m-1] ]
		; movdqu       xmm4, xmm2          ; xmm4 <- [ src[n-2][m-2] + src[n-1][m-2] | src[n-2][m-1] + src[n-1][m-1] ]
		; psrldq       xmm4, 8             ; xmm4 <- [               0               | src[n-2][m-1] + src[n-1][m-1] ]
		; paddw        xmm4, xmm2          ; xmm4 <- [ ------- | src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1] ]

		; psrlw        xmm2, 1             ; xmm2 <- [ (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
		; psrlw        xmm4, 2             ; xmm4 <- [ ------- | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 ]

		; movdqu       xmm5, xmm1          ; xmm1 <- [ src[n-2][m-2] | src[n-2][m-1] ]
		; psrldq       xmm5, 8             ; xmm5 <- [       0       | src[n-2][m-2] ]
		; paddw        xmm5, xmm1
		; psrlw        xmm5, 1             ; xmm5 <- [ ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]

		; packuswb     xmm1, xmm8          ; xmm1 <- [       0       |        0       |            src[n-2][m-2]            |             src[n-2][m-1]           ] 
		; packuswb     xmm5, xmm8          ; xmm5 <- [       0       |        0       |            -------------            | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]
		; packuswb     xmm2, xmm8          ; xmm2 <- [       0       |        0       | (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
		; packuswb     xmm4, xmm8          ; xmm4 <- [       0       |        0       |            -------------            | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 ]

		; pslldq       xmm4, 8
		; por          xmm2, xmm4          ; xmm2 <- [ ------- | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 | (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
		; pshufd       xmm2, xmm2, 0x09    ; xmm2 <- [ (src[n-1][m-1] + src[n-2][m-1]) / 2 | (src[n-1][m-1] + src[n-2][m-1]) / 2 | (src[n-1][m-1] + src[n-2][m-1] + src[n-1][m-2] + src[n-2][m-2]) / 4 | (src[n-1][m-2] + src[n-2][m-2]) / 2 ]

		; pslldq       xmm5, 8
		; por          xmm5, xmm1          ; xmm5 <- [ ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 | src[n-2][m-2] | src[n-2][m-1] ]
		; pshufd       xmm5, xmm5, 0x09    ; xmm5 <- [ src[n-2][m-1] | src[n-2][m-1] | (src[n-1][m-2] + src[n-1][m-1]) / 2 | src[n-2][m-2] ]



		; Versión 1.2

		movdqu         xmm0, [rbx]         ; xmm0 <- [ src[n-1][m-1] | src[n-1][m-2] | src[n-1][m-3] | src[n-1][m-4] ]
		movdqu         xmm1, [rbx + 4*rsi] ; xmm1 <- [ src[n-2][m-1] | src[n-2][m-2] | src[n-2][m-3] | src[n-2][m-4] ]


		punpckhbw    xmm0, xmm8          ; xmm0 <- [ src[n-1][m-1] | src[n-1][m-2] ]
		punpckhbw    xmm1, xmm8          ; xmm1 <- [ src[n-2][m-1] | src[n-2][m-2] ]

		; [ 3 | 2 | 1 | 0 ] => [ 1 | 0 | 3 | 2 ] (01 00 11 10 == 0100 1110 == 0x7E)

		pshufd       xmm0, xmm0, 0x7E    ; xmm0 <- [ src[n-1][m-2] | src[n-1][m-1] ]
		pshufd       xmm1, xmm1, 0x7E    ; xmm1 <- [ src[n-2][m-2] | src[n-2][m-1] ]

		movdqu       xmm2, xmm0
		movdqu       xmm3, xmm1

		paddw        xmm2, xmm1          ; xmm2 <- [ src[n-2][m-2] + src[n-1][m-2] | src[n-2][m-1] + src[n-1][m-1] ]
		movdqu       xmm4, xmm2          ; xmm4 <- [ src[n-2][m-2] + src[n-1][m-2] | src[n-2][m-1] + src[n-1][m-1] ]
		psrldq       xmm4, 8             ; xmm4 <- [               0               | src[n-2][m-1] + src[n-1][m-1] ]
		paddw        xmm4, xmm2          ; xmm4 <- [ ------- | src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1] ]

		psrlw        xmm2, 1             ; xmm2 <- [ (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
		psrlw        xmm4, 2             ; xmm4 <- [ ------- | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 ]

		movdqu       xmm5, xmm1          ; xmm1 <- [ src[n-2][m-2] | src[n-2][m-1] ]
		psrldq       xmm5, 8             ; xmm5 <- [       0       | src[n-2][m-2] ]
		paddw        xmm5, xmm1
		psrlw        xmm5, 1             ; xmm5 <- [ ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]

		packuswb     xmm1, xmm8          ; xmm1 <- [       0       |        0       |            src[n-2][m-2]            |             src[n-2][m-1]           ] 
		packuswb     xmm5, xmm8          ; xmm5 <- [       0       |        0       |            -------------            | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]
		packuswb     xmm2, xmm8          ; xmm2 <- [       0       |        0       | (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
		packuswb     xmm4, xmm8          ; xmm4 <- [       0       |        0       |            -------------            | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 ]

		pslldq       xmm4, 8
		por          xmm2, xmm4          ; xmm2 <- [ ------- | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 | (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
		pshufd       xmm2, xmm2, 0x09    ; xmm2 <- [ (src[n-1][m-1] + src[n-2][m-1]) / 2 | (src[n-1][m-1] + src[n-2][m-1]) / 2 | (src[n-1][m-1] + src[n-2][m-1] + src[n-1][m-2] + src[n-2][m-2]) / 4 | (src[n-1][m-2] + src[n-2][m-2]) / 2 ]

		pslldq       xmm5, 8
		por          xmm5, xmm1          ; xmm5 <- [ ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 | src[n-2][m-2] | src[n-2][m-1] ]
		pshufd       xmm5, xmm5, 0x09    ; xmm5 <- [ src[n-2][m-1] | src[n-2][m-1] | (src[n-1][m-2] + src[n-1][m-1]) / 2 | src[n-2][m-2] ]



		; ; Versión 1.3

		; movq         xmm0, [rbx]         ; xmm0 <- [ ----- | ----- | src[n-1][m-2] | src[n-1][m-1] ]
		; movq         xmm1, [rbx + 4*rsi] ; xmm1 <- [ ----- | ----- | src[n-2][m-2] | src[n-2][m-1] ]


		; punpcklbw    xmm0, xmm8          ; xmm0 <- [ src[n-1][m-2] | src[n-1][m-1] ]
		; punpcklbw    xmm1, xmm8          ; xmm1 <- [ src[n-2][m-2] | src[n-2][m-1] ]

		; movdqu       xmm2, xmm0
		; movdqu       xmm3, xmm1

		; paddw        xmm2, xmm1          ; xmm2 <- [ src[n-2][m-2] + src[n-1][m-2] | src[n-2][m-1] + src[n-1][m-1] ]
		; movdqu       xmm4, xmm2          ; xmm4 <- [ src[n-2][m-2] + src[n-1][m-2] | src[n-2][m-1] + src[n-1][m-1] ]
		; psrldq       xmm4, 8             ; xmm4 <- [               0               | src[n-2][m-1] + src[n-1][m-1] ]
		; paddw        xmm4, xmm2          ; xmm4 <- [ ------- | src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1] ]

		; psrlw        xmm2, 1             ; xmm2 <- [ (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
		; psrlw        xmm4, 2             ; xmm4 <- [ ------- | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 ]

		; movdqu       xmm5, xmm1          ; xmm1 <- [ src[n-2][m-2] | src[n-2][m-1] ]
		; psrldq       xmm5, 8             ; xmm5 <- [       0       | src[n-2][m-2] ]
		; paddw        xmm5, xmm1
		; psrlw        xmm5, 1             ; xmm5 <- [ ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]

		; packuswb     xmm1, xmm8          ; xmm1 <- [       0       |        0       |            src[n-2][m-2]            |             src[n-2][m-1]           ] 
		; packuswb     xmm5, xmm8          ; xmm5 <- [       0       |        0       |            -------------            | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]
		; packuswb     xmm2, xmm8          ; xmm2 <- [       0       |        0       | (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
		; packuswb     xmm4, xmm8          ; xmm4 <- [       0       |        0       |            -------------            | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 ]

		; pslldq       xmm4, 8
		; por          xmm2, xmm4          ; xmm2 <- [ ------- | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 | (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
		; pshufd       xmm2, xmm2, 0x09    ; xmm2 <- [ (src[n-1][m-1] + src[n-2][m-1]) / 2 | (src[n-1][m-1] + src[n-2][m-1]) / 2 | (src[n-1][m-1] + src[n-2][m-1] + src[n-1][m-2] + src[n-2][m-2]) / 4 | (src[n-1][m-2] + src[n-2][m-2]) / 2 ]

		; pslldq       xmm5, 8
		; por          xmm5, xmm1          ; xmm5 <- [ ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 | src[n-2][m-2] | src[n-2][m-1] ]
		; pshufd       xmm5, xmm5, 0x09    ; xmm5 <- [ src[n-2][m-1] | src[n-2][m-1] | (src[n-1][m-2] + src[n-1][m-1]) / 2 | src[n-2][m-2] ]

		movdqu       [r13], xmm2
		movdqu       [r13 + 4*r8], xmm5

		lea          rbx, [rbx + 4*rsi]
		lea          r13, [r13 + 8*r8]

		jmp          .ciclo_borde_derecho


	.listo_borde_derecho:
		xor          r12, r12 ; Contador de columnas de src
		mov          rbx, rdi ; rbx <- &src[srch-1][0]
		mov          r13, rcx ; r13 <- &dst[dsth-1][0]


	.ciclo_borde_inferior:

		; Veo si terminé de recorrer la fila de abajo de la imagen original
		; Si es así, terminé
		cmp          r12, rsi
		jge          .fin

		movdqu       xmm0, [rbx]        ; xmm0 <- [ src[n-1][3] | src[n-1][2] | src[n-1][1] | src[n-1][0] ]
		movdqu       xmm1, xmm0         ; xmm1 <- [ src[n-1][3] | src[n-1][2] | src[n-1][1] | src[n-1][0] ]

		psrldq       xmm1, 4            ; xmm1 <- [      0      | src[n-1][3] | src[n-1][2] | src[n-1][1] ]

		punpcklbw    xmm0, xmm8         ; xmm0 <- [ src[n-1][1] | src[n-1][0] ]
		punpcklbw    xmm1, xmm8         ; xmm1 <- [ src[n-1][2] | src[n-1][1] ]

		paddw        xmm1, xmm0         ; xmm1 <- [ (src[n-1][2] + src[n-1][1]) | (src[n-1][1] + src[n-1][0]) ]
		psrlw        xmm1, 1            ; xmm1 <- [ (src[n-1][2] + src[n-1][1]) / 2 | (src[n-1][1] + src[n-1][0]) / 2 ]

		packuswb     xmm0, xmm8         ; xmm0 <- [      0      |      0      |           src[n-1][1]           |           src[n-1][0]           ]
		packuswb     xmm1, xmm8         ; xmm1 <- [      0      |      0      | (src[n-1][2] + src[n-1][1]) / 2 | (src[n-1][1] + src[n-1][0]) / 2 ]

		pslldq       xmm1, 8
		por          xmm0, xmm1         ; xmm0 <- [ (src[n-1][2] + src[n-1][1]) / 2 | (src[n-1][1] + src[n-1][0]) / 2 | src[n-1][1] | src[n-1][0] ]
		pshufd       xmm0, xmm0, 0xD8

		movdqu       [r13], xmm0
		movdqu       [r13 + 4*r8], xmm0

		add          rbx, 8
		add          r13, 16
		add          r12, 2

		jmp          .ciclo_borde_inferior


	.fin:

		lea          rbx, [rdi + 4*rsi - 8] ; rbx <- &src[srch-1][srcw-2]
		lea          r13, [rcx + 4*r8 - 16] ; r13 <- &dst[dsth-1][dstw-4]

		; movdqu       xmm0, [rbx]        ; xmm0 <- [ src[n-1][3] | src[n-1][2] | src[n-1][1] | src[n-1][0] ]
		movq         xmm0, [rbx]        ; xmm0 <- [ ----------- | ----------- | src[n-1][3] | src[n-1][2] ]

		punpcklbw    xmm0, xmm8         ; xmm0 <- [ src[n-1][3] | src[n-1][2] ]
		pshufd       xmm0, xmm0, 0x7E

		movdqu       xmm1, xmm0         ; xmm1 <- [ src[n-1][3] | src[n-1][2] ]
		psrldq       xmm1, 8            ; xmm1 <- [      0      | src[n-1][3] ]

		paddw        xmm1, xmm0         ; xmm1 <- [ ----------- | (src[n-1][3] + src[n-1][2]) ]
		psrlw        xmm1, 1            ; xmm1 <- [ ----------- | (src[n-1][3] + src[n-1][2]) / 2 ]

		packuswb     xmm0, xmm8         ; xmm0 <- [      0      |      0      | src[n-1][3] |           src[n-1][2]           ]
		packuswb     xmm1, xmm8         ; xmm1 <- [      0      |      0      | ----------- | (src[n-1][3] + src[n-1][2]) / 2 ]

		pslldq       xmm1, 8
		por          xmm0, xmm1         ; xmm0 <- [ ----------- | (src[n-1][3] + src[n-1][2]) / 2 | src[n-1][3] | src[n-1][2] ]

		; [ 3 | 2 | 1 | 0 ] => [ 1 | 0 | 3 | 2 ] (01 00 11 10 == 0100 1110 == 0x7E)

		pshufd       xmm0, xmm0, 0x09

		movdqu       [r13], xmm0
		movdqu       [r13 + 4*r8], xmm0

		pop          r14
		pop          r13
		pop          r12
		pop          rbx
		pop          rbp
		ret

