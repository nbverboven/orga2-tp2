global ASM_linearZoom
extern C_linearZoom


section .rodata



section .text

%define tam_ARGB 4


ASM_linearZoom:
; RDI := uint8_t* src, RSI := uint32_t srcw, RDX := uint32_t srch, 
; RCX := uint8_t* dst, R8 := uint32_t dstw, R9 := uint32_t dsth

	push    rbp
	mov     rbp, rsp
	push    rbx
	push    r12
	push    r13
	push    r14
	push    r15
	sub     rsp, 8

	shl     rdx, 8
	shr     rdx, 8
	shl     r8, 8
	shr     r8, 8
	shl     rsi, 8
	shr     rsi, 8

	mov     rax, rsi           ; rax <- srcw
	lea     rbx, [rdx - 1]     ; rbx <- srch-1
	mul     rbx                ; rax <- srcw*(srch-1)
	lea     rax, [rdi + 4*rax] ; rax <- rdi + 4*srcw*(srch-1)

	xor     r12, r12           ; Contador de columnas de dst

	lea     r9, [r8 - 4]

	mov     rbx, rdi           ; rbx <- &src[n-1][0]

	lea     r13, [rcx + 8*r8]  ; r13 <- &dst[n-3][0]

	pxor    xmm8, xmm8


.ciclo:

	cmp       rbx, rax
	; jge       .fin
	jge       .finn_ciclo

	.genero_filas_modificadas:

		movdqu     xmm0, [rbx]         ; xmm0 <- [ src[n-1][0] | src[n-1][1] | src[n-1][2] | src[n-1][3] ]
		movdqu     xmm1, [rbx + 4*rsi] ; xmm1 <- [ src[n-2][0] | src[n-2][1] | src[n-2][2] | src[n-2][3] ]

		; Versión 2.0

		psrldq    xmm0, 4 ; xmm0 <- [      0      | src[n-1][0] | src[n-1][1] | src[n-1][2] ]
		psrldq    xmm1, 4 ; xmm1 <- [      0      | src[n-2][0] | src[n-2][1] | src[n-2][2] ]

		movdqu    xmm2, xmm0
		movdqu    xmm3, xmm1

		psrldq    xmm2, 4 ; xmm2 <- [      0      |      0      | src[n-1][0] | src[n-1][1] ]
		psrldq    xmm3, 4 ; xmm3 <- [      0      |      0      | src[n-2][0] | src[n-2][1] ]

		punpcklbw  xmm0, xmm8 
		punpcklbw  xmm1, xmm8
		punpcklbw  xmm2, xmm8
		punpcklbw  xmm3, xmm8
		
		; xmm0 <- [ src[n-1][1] | src[n-1][2] ]
		; xmm1 <- [ src[n-2][1] | src[n-2][2] ]
		; xmm2 <- [ src[n-1][0] | src[n-1][1] ]
		; xmm3 <- [ src[n-2][0] | src[n-2][1] ]		

		movdqu      xmm4, xmm1
		paddw       xmm4, xmm0 ; xmm4 <- [ src[n-2][1] + src[n-1][1] | src[n-2][2] + src[n-1][2] ]
		movdqu      xmm6, xmm4
		psrlw       xmm4, 1    ; xmm4 <- [ (src[n-2][1] + src[n-1][1]) / 2 | (src[n-2][2] + src[n-1][2]) / 2 ]

		movdqu      xmm5, xmm3
		paddw       xmm5, xmm2 ; xmm5 <- [ src[n-2][0] + src[n-1][0] | src[n-2][1] + src[n-1][1] ]
		paddw       xmm6, xmm5 ; xmm6 <- [ src[n-2][0] + src[n-1][0] + src[n-2][1] + src[n-1][1] | src[n-2][1] + src[n-1][1] + src[n-2][2] + src[n-1][2] ]
		psrlw       xmm5, 1    ; xmm5 <- [ (src[n-2][0] + src[n-1][0]) / 2 | (src[n-2][1] + src[n-1][1]) / 2 ]
		psrlw       xmm6, 2    ; xmm6 <- [ (src[n-2][0] + src[n-1][0] + src[n-2][1] + src[n-1][1]) / 4 | (src[n-2][1] + src[n-1][1] + src[n-2][2] + src[n-1][2]) / 4 ]

		paddw       xmm1, xmm3
		psrlw       xmm1, 1    ; xmm1 <- [ (src[n-2][1] + src[n-2][0]) / 2 | (src[n-2][2] + src[n-2][1]) / 2 ]

		packuswb    xmm1, xmm8 ; xmm1 <- [      0      |      0      | (src[n-2][1] + src[n-2][0]) / 2 | (src[n-2][2] + src[n-2][1]) / 2 ]
		packuswb    xmm3, xmm8 ; xmm3 <- [      0      |      0      |           src[n-2][0]           |           src[n-2][1]           ]
		packuswb    xmm5, xmm8 ; xmm5 <- [      0      |      0      | (src[n-2][0] + src[n-1][0]) / 2 | (src[n-2][1] + src[n-1][1]) / 2 ]
		packuswb    xmm6, xmm8 ; xmm6 <- [      0      |      0      | (src[n-2][0] + src[n-1][0] + src[n-2][1] + src[n-1][1]) / 4 | (src[n-2][1] + src[n-1][1] + src[n-2][2] + src[n-1][2]) / 4 ]

		pslldq     xmm3, 8
		por        xmm1, xmm3       ; xmm1 <- [ src[n-2][0] |           src[n-2][1]           | (src[n-2][1] + src[n-2][0]) / 2 | (src[n-2][2] + src[n-2][1]) / 2 ]
		pshufd     xmm1, xmm1, 0xD8 ; xmm1 <- [ src[n-2][0] | (src[n-2][1] + src[n-2][0]) / 2 |           src[n-2][1]           | (src[n-2][2] + src[n-2][1]) / 2 ]

		pslldq     xmm5, 8
		por        xmm6, xmm5
		pshufd     xmm6, xmm6, 0xD8


	; --------------------------------------------------------------------------------------------------------------------------------------------------



	movdqu    [r13], xmm6
	movdqu    [r13 + 4*r8], xmm1

	; mov       r10, r13
	; lea       r11, [4*r8]
	; sub       r10, r11
	; movdqu    [r10], xmm0


	add       rbx, 8
	add       r13, 16

	add       r12, 4

	.asd:
		cmp       r12, r9
		jl        .fin_ciclo

		xor       r12, r12
		lea       r13, [r13 + 4*r8 + 16]

		add       rbx, 8

	.fin_ciclo:
		jmp       .ciclo


.finn_ciclo:

	; lea     rbx, [rdi + 4*rsi - 8]
	; lea     r13, [rcx + 8*r8 - 16]
	; lea     r13, [r13 + 4*r8]

	; pxor    xmm0, xmm0
	; pxor    xmm1, xmm1


; .ciclo2:
	
; 	cmp     rbx, rax
; 	jge     .fin

; 	.genero_borde:
; 		movq     xmm0, [rbx]         ; xmm0 <- [ ----- | ----- | src[n-1][m-2] | src[n-1][m-1] ]
; 		movq     xmm1, [rbx + 4*rsi] ; xmm1 <- [ ----- | ----- | src[n-2][m-2] | src[n-2][m-1] ]

; 		movq     xmm2, xmm0
; 		movq     xmm3, xmm1

; 		punpcklbw    xmm2, xmm8
; 		punpcklbw    xmm3, xmm8

; 		paddw    xmm2, xmm3  ; xmm2 <- [ src[n-1][m-2] + src[n-2][m-2] | src[n-1][m-1] + src[n-2][m-1] ]
; 		movdqu   xmm4, xmm2
; 		psrldq   xmm4, 8
; 		paddw    xmm4, xmm2

; 		psrlw    xmm4, 2     ; xmm4 <- [ ------- | (src[n-1][m-1] + src[n-2][m-1] + src[n-1][m-2] + src[n-2][m-2]) / 4 ]
; 		psrlw    xmm2, 1     ; xmm2 <- [ (src[n-1][m-2] + src[n-2][m-2]) / 2 | (src[n-1][m-1] + src[n-2][m-1]) / 2 ]

; 		packuswb    xmm4, xmm8 ; xmm4 <- [    0    |    0    | ------- | (src[n-1][m-1] + src[n-2][m-1] + src[n-1][m-2] + src[n-2][m-2]) / 4 ]
; 		packuswb    xmm2, xmm8 ; xmm2 <- [    0    |    0    | (src[n-1][m-2] + src[n-2][m-2]) / 2 | (src[n-1][m-1] + src[n-2][m-1]) / 2 ]

; 		pslldq      xmm4, 8
; 		pblendw     xmm2, xmm4, 0x30 ; xmm2 <- [    0    | (src[n-1][m-1] + src[n-2][m-1] + src[n-1][m-2] + src[n-2][m-2]) / 4 | (src[n-1][m-2] + src[n-2][m-2]) / 2 | (src[n-1][m-1] + src[n-2][m-1]) / 2 ]

; 		pshufd      xmm2, xmm2, 0x60 ; xmm2 <- [ (src[n-1][m-2] + src[n-2][m-2]) / 2 | (src[n-1][m-1] + src[n-2][m-1] + src[n-1][m-2] + src[n-2][m-2]) / 4 | (src[n-1][m-2] + src[n-2][m-2]) / 2 | (src[n-1][m-2] + src[n-2][m-2]) / 2 ]
; 		; Esto de arriba hay que chequearlo...

; 		; punpckhbw   xmm0, xmm8 ; xmm0 <- [ src[n-1][m-2] | src[n-1][m-1] ]
; 		; movdqu      xmm4, xmm0

; 		; psrldq      xmm4, 4    ; xmm4 <- [       0       | src[n-1][m-2] ]

; 		; paddw       xmm4, xmm0
; 		; psrlw       xmm4, 1    ; xmm4 <- [ ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]

; 		; packuswb    xmm0, xmm8 ; xmm0 <- [       0       |        0       | src[n-1][m-2] |            src[n-1][m-1]            ] 
; 		; packuswb    xmm4, xmm8 ; xmm4 <- [       0       |        0       | ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]

; 		; pslldq      xmm4, 12
; 		; paddw       xmm4, xmm0 ; xmm4 <- [ (src[n-1][m-2] + src[n-1][m-1]) / 2 |        0       | src[n-1][m-2] | src[n-1][m-1] ]

; 		; pshufd      xmm0, xmm4, 0x70 ; xmm0 <- [ src[n-1][m-2] | (src[n-1][m-2] + src[n-1][m-1]) / 2 | src[n-1][m-1] | src[n-1][m-1] ]

; 		punpckhbw   xmm1, xmm8 ; xmm1 <- [ src[n-1][m-2] | src[n-1][m-1] ]
; 		movdqu      xmm5, xmm1

; 		psrldq      xmm5, 4    ; xmm5 <- [       0       | src[n-1][m-2] ]

; 		paddw       xmm5, xmm1
; 		psrlw       xmm5, 1    ; xmm5 <- [ ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]

; 		packuswb    xmm1, xmm8 ; xmm1 <- [       0       |        0       | src[n-1][m-2] |            src[n-1][m-1]            ] 
; 		packuswb    xmm5, xmm8 ; xmm5 <- [       0       |        0       | ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]

; 		pslldq      xmm5, 12
; 		paddw       xmm5, xmm1 ; xmm5 <- [ (src[n-1][m-2] + src[n-1][m-1]) / 2 |        0       | src[n-1][m-2] | src[n-1][m-1] ]

; 		pshufd      xmm1, xmm5, 0x70 ; xmm1 <- [ src[n-1][m-2] | (src[n-1][m-2] + src[n-1][m-1]) / 2 | src[n-1][m-1] | src[n-1][m-1] ]
; 		; Nuevamente, chequear esto

; 	movdqu   [r13], xmm2
; 	movdqu   [r13 + 4*r8], xmm1


; 	lea     rbx, [rbx + 4*rsi]
; 	lea     r13, [r13 + 8*r8]

; 	jmp     .ciclo2

.fin:
	add     rsp, 8
	pop     r15
	pop     r14
	pop     r13
	pop     r12
	pop     rbx
	pop     rbp
	ret

































; ; --------------------------------------------------------------------------------------------------------------------------------------------------

; 		movdqu       xmm4, xmm0 ; xmm4 == xmm0
; 		movdqu       xmm5, xmm0 ; xmm5 == xmm0

; 		psrldq       xmm4, 4    ; xmm4 <- [ 0 | src[n-1][0] | src[n-1][1] | src[n-1][2] ]
; 		psrldq       xmm5, 8    ; xmm5 <- [ 0 |      0      | src[n-1][0] | src[n-1][1] ]

; 		punpcklbw    xmm4, xmm8 ; xmm4 <- [ 0 | src[n-1][1].a | 0 | src[n-1][1].r | 0 | src[n-1][1].g | 0 | src[n-1][1].b | 0 | src[n-1][2].a | 0 | src[n-1][2].r | 0 | src[n-1][2].g | 0 | src[n-1][2].b ]
; 		punpcklbw    xmm5, xmm8 ; xmm5 <- [ 0 | src[n-1][0].a | 0 | src[n-1][0].r | 0 | src[n-1][0].g | 0 | src[n-1][0].b | 0 | src[n-1][1].a | 0 | src[n-1][1].r | 0 | src[n-1][1].g | 0 | src[n-1][1].b ]
		
; 		paddw        xmm4, xmm5 ; xmm4 <- [  src[n-1][0] + src[n-1][1]    |  src[n-1][1] + src[n-1][2]    ]
; 		movdqu       xmm5, xmm4 ; xmm5 == xmm4
; 		psrlw        xmm4, 1    ; xmm4 <- [ (src[n-1][0] + src[n-1][1])/2 | (src[n-1][1] + src[n-1][2])/2 ]

; 		packuswb     xmm4, xmm8 ; xmm4 <- [ 0 | 0 | (src[n-1][0] + src[n-1][1])/2 | (src[n-1][1] + src[n-1][2])/2 ]

; 		; --------------------------------------------------------------------------------------------------------------------------------------------------

; 		movdqu       xmm6, xmm1 ; xmm6 == xmm1
; 		movdqu       xmm7, xmm1 ; xmm7 == xmm1

; 		psrldq       xmm6, 4    ; xmm6 <- [ 0 | src[n-2][0] | src[n-2][1] | src[n-2][2] ]
; 		psrldq       xmm7, 8    ; xmm7 <- [ 0 |      0      | src[n-2][0] | src[n-2][1] ]

; 		punpcklbw    xmm6, xmm8 ; xmm6 <- [ 0 | src[n-2][1].a | 0 | src[n-2][1].r | 0 | src[n-2][1].g | 0 | src[n-2][1].b | 0 | src[n-2][2].a | 0 | src[n-2][2].r | 0 | src[n-2][2].g | 0 | src[n-2][2].b ]
; 		punpcklbw    xmm7, xmm8 ; xmm7 <- [ 0 | src[n-2][0].a | 0 | src[n-2][0].r | 0 | src[n-2][0].g | 0 | src[n-2][0].b | 0 | src[n-2][1].a | 0 | src[n-2][1].r | 0 | src[n-2][1].g | 0 | src[n-2][1].b ]
		
; 		paddw        xmm6, xmm7 ; xmm6 <- [  src[n-2][0] + src[n-2][1]    |  src[n-2][1] + src[n-2][2]    ]
; 		movdqu       xmm7, xmm6 ; xmm7 == xmm6
; 		psrlw        xmm6, 1    ; xmm6 <- [ (src[n-2][0] + src[n-2][1])/2 | (src[n-2][1] + src[n-2][2])/2 ]

; 		packuswb     xmm6, xmm8 ; xmm6 <- [ 0 | 0 | (src[n-2][0] + src[n-2][1])/2 | (src[n-2][1] + src[n-2][2])/2 ]

; 		; --------------------------------------------------------------------------------------------------------------------------------------------------

; 		movdqu       xmm2, xmm0 ; xmm2 == xmm0
; 		movdqu       xmm3, xmm1 ; xmm3 == xmm1

; 		psrldq       xmm2, 8    ; xmm2 <- [ 0 | 0 | src[n-1][0] | src[n-1][1] ]
; 		psrldq       xmm3, 8    ; xmm3 <- [ 0 | 0 | src[n-2][0] | src[n-2][1] ]

; 		punpcklbw    xmm2, xmm8 ; xmm2 <- [ 0 | src[n-1][0].a | 0 | src[n-1][0].r | 0 | src[n-1][0].g | 0 | src[n-1][0].b | 0 | src[n-1][1].a | 0 | src[n-1][1].r | 0 | src[n-1][1].g | 0 | src[n-1][1].b ]
; 		punpcklbw    xmm3, xmm8 ; xmm3 <- [ 0 | src[n-2][0].a | 0 | src[n-2][0].r | 0 | src[n-2][0].g | 0 | src[n-2][0].b | 0 | src[n-2][1].a | 0 | src[n-2][1].r | 0 | src[n-2][1].g | 0 | src[n-2][1].b ]

; 		paddw        xmm2, xmm3 ; xmm2 <- [  src[n-1][0] + src[n-2][0]    |  src[n-1][1] + src[n-2][1]    ]
; 		psrlw        xmm2, 1    ; xmm2 <- [ (src[n-1][0] + src[n-2][0])/2 | (src[n-1][1] + src[n-2][1])/2 ]

; 		packuswb     xmm2, xmm8 ; xmm2 <- [ 0 | 0 | (src[n-1][0] + src[n-2][0])/2 | (src[n-1][1] + src[n-2][1])/2 ]

; 		; --------------------------------------------------------------------------------------------------------------------------------------------------

; 		; xmm5 <- [ src[n-1][0] + src[n-1][1] | src[n-1][1] + src[n-1][2] ]
; 		; xmm7 <- [ src[n-2][0] + src[n-2][1] | src[n-2][1] + src[n-2][2] ]

; 		paddw        xmm5, xmm7 ; xmm5 <- [  src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1]    |  src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2]    ]
; 		psrlw        xmm5, 2    ; xmm5 <- [ (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]

; 		packuswb     xmm5, xmm8 ; xmm5 <- [ 0 | 0 | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]

; 		; --------------------------------------------------------------------------------------------------------------------------------------------------

; 		; xmm0 <- [ src[n-1][0] | src[n-1][1] |                         src[n-1][2]                       |                         src[n-1][3]                       ]
; 		; xmm1 <- [ src[n-2][0] | src[n-2][1] |                         src[n-2][2]                       |                         src[n-2][3]                       ]
; 		; xmm2 <- [      0      |      0      |               (src[n-1][0] + src[n-2][0])/2               |               (src[n-1][1] + src[n-2][1])/2               ]
; 		; xmm4 <- [      0      |      0      |               (src[n-1][0] + src[n-1][1])/2               |               (src[n-1][1] + src[n-1][2])/2               ]
; 		; xmm6 <- [      0      |      0      |               (src[n-2][0] + src[n-2][1])/2               |               (src[n-2][1] + src[n-2][2])/2               ]
; 		; xmm5 <- [      0      |      0      | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]


; 		movdqu       xmm9, xmm2 ; xmm9 == xmm2
; 		psrldq       xmm2, 4    ; xmm2 <- [              0                |      0      |              0                | (src[n-1][0] + src[n-2][0])/2 ]
; 		pslldq       xmm2, 12   ; xmm2 <- [ (src[n-1][0] + src[n-2][0])/2 |      0      |              0                |              0                ]
; 		pslldq       xmm9, 12   ; xmm9 <- [ (src[n-1][1] + src[n-2][1])/2 |      0      |              0                |              0                ]
; 		psrldq       xmm9, 8    ; xmm9 <- [              0                |      0      | (src[n-1][1] + src[n-2][1])/2 |              0                ]
; 		por          xmm2, xmm9 ; xmm2 <- [ (src[n-1][0] + src[n-2][0])/2 |      0      | (src[n-1][1] + src[n-2][1])/2 |              0                ]


; 		movdqu       xmm9, xmm5 ; xmm9 == xmm5
; 		psrldq       xmm5, 4    ; xmm5 <- [                            0                              |                            0                              |      0      | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 ]
; 		pslldq       xmm5, 8    ; xmm5 <- [                            0                              | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 |      0      |                            0                              ]
; 		pslldq       xmm9, 12   ; xmm9 <- [ (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 |                            0                              |      0      |                            0                              ]
; 		psrldq       xmm9, 12   ; xmm9 <- [                            0                              |                            0                              |      0      | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]
; 		por          xmm5, xmm9 ; xmm5 <- [                            0                              | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 |      0      | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]

; 		por          xmm2, xmm5 ; xmm2 <- [ (src[n-1][0] + src[n-2][0])/2 | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 | (src[n-1][1] + src[n-2][1])/2 | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]




; 		movdqu       xmm9, xmm4 ; xmm9 == xmm4
; 		psrldq       xmm4, 4    ; xmm4 <- [              0                |              0                |      0      | (src[n-1][0] + src[n-1][1])/2 ]
; 		pslldq       xmm4, 8    ; xmm4 <- [              0                | (src[n-1][0] + src[n-1][1])/2 |      0      |              0                ]
; 		pslldq       xmm9, 12   ; xmm9 <- [ (src[n-1][1] + src[n-1][2])/2 |              0                |      0      |              0                ]
; 		psrldq       xmm9, 12   ; xmm9 <- [              0                |              0                |      0      | (src[n-1][1] + src[n-1][2])/2 ]
; 		por          xmm4, xmm9 ; xmm4 <- [              0                | (src[n-1][0] + src[n-1][1])/2 |      0      | (src[n-1][1] + src[n-1][2])/2 ]




; 		movdqu       xmm9, xmm6 ; xmm9 == xmm6
; 		psrldq       xmm6, 4    ; xmm6 <- [              0                |              0                |      0      | (src[n-2][0] + src[n-2][1])/2 ]
; 		pslldq       xmm6, 8    ; xmm6 <- [              0                | (src[n-2][0] + src[n-2][1])/2 |      0      |              0                ]
; 		pslldq       xmm9, 12   ; xmm9 <- [ (src[n-2][1] + src[n-2][2])/2 |              0                |      0      |              0                ]
; 		psrldq       xmm9, 12   ; xmm9 <- [              0                |              0                |      0      | (src[n-2][1] + src[n-2][2])/2 ]
; 		por          xmm6, xmm9 ; xmm6 <- [              0                | (src[n-2][0] + src[n-2][1])/2 |      0      | (src[n-2][1] + src[n-2][2])/2 ]






; 		movdqu       xmm3, xmm0 ; xmm3 == xmm0
; 		psrldq       xmm3, 8    ; xmm3 <- [      0      |      0      | src[n-1][0] | src[n-1][1] ]
; 		movdqu       xmm9, xmm3 ; xmm9 == xmm3
; 		psrldq       xmm3, 4    ; xmm3 <- [      0      |      0      |      0      | src[n-1][0] ]
; 		pslldq       xmm3, 12   ; xmm3 <- [ src[n-1][0] |      0      |      0      |      0      ]
; 		pslldq       xmm9, 12   ; xmm9 <- [ src[n-1][1] |      0      |      0      |      0      ]
; 		psrldq       xmm9, 8    ; xmm9 <- [      0      |      0      | src[n-1][1] |      0      ]
; 		por          xmm3, xmm9 ; xmm3 <- [ src[n-1][0] |      0      | src[n-1][1] |      0      ]

; 		por          xmm3, xmm4 ; xmm3 <- [ src[n-1][0] | (src[n-1][0] + src[n-1][1])/2 | src[n-1][1] | (src[n-1][1] + src[n-1][2])/2 ]


; 		movdqu       xmm5, xmm1 ; xmm5 == xmm1
; 		psrldq       xmm5, 8    ; xmm5 <- [      0      |      0      | src[n-2][0] | src[n-2][1] ]
; 		movdqu       xmm9, xmm5 ; xmm9 == xmm5
; 		psrldq       xmm5, 4    ; xmm5 <- [      0      |      0      |      0      | src[n-2][0] ]
; 		pslldq       xmm5, 12   ; xmm5 <- [ src[n-2][0] |      0      |      0      |      0      ]
; 		pslldq       xmm9, 12   ; xmm9 <- [ src[n-2][1] |      0      |      0      |      0      ]
; 		psrldq       xmm9, 8    ; xmm9 <- [      0      |      0      | src[n-2][1] |      0      ]
; 		por          xmm5, xmm9 ; xmm5 <- [ src[n-2][0] |      0      | src[n-2][1] |      0      ]

; 		por          xmm5, xmm6 ; xmm5 <- [ src[n-2][0] | (src[n-2][0] + src[n-2][1])/2 | src[n-2][1] | (src[n-2][1] + src[n-2][2])/2 ]