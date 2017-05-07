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

	lea     r15, [rsi - 2]     ; r15 <- srcw-2


	xor     r12, r12           ; Contador de columnas de dst
	; xor     r9, r9             ; Contador de columnas de src

	lea     r9, [r8 - 4]

	mov     rbx, rdi           ; rbx <- &src[n-1][0]

	lea     r13, [rcx + 8*r8]  ; r13 <- &dst[n-3][0]


.ciclo:

	cmp       rbx, rax
	jge       .fin

	

.genero_filas_modificadas:
	movdqu     xmm0, [rbx]
	movdqu     xmm1, [rbx + 4*rsi]


	; --------------------------------------------------------------------------------------------------------------------------------------------------

	movdqu       xmm4, xmm0 ; xmm4 == xmm0
	movdqu       xmm5, xmm0 ; xmm5 == xmm0

	psrldq       xmm4, 4    ; xmm4 <- [ 0 | src[n-1][0] | src[n-1][1] | src[n-1][2] ]
	psrldq       xmm5, 8    ; xmm5 <- [ 0 |      0      | src[n-1][0] | src[n-1][1] ]

	punpcklbw    xmm4, xmm8 ; xmm4 <- [ 0 | src[n-1][1].a | 0 | src[n-1][1].r | 0 | src[n-1][1].g | 0 | src[n-1][1].b | 0 | src[n-1][2].a | 0 | src[n-1][2].r | 0 | src[n-1][2].g | 0 | src[n-1][2].b ]
	punpcklbw    xmm5, xmm8 ; xmm5 <- [ 0 | src[n-1][0].a | 0 | src[n-1][0].r | 0 | src[n-1][0].g | 0 | src[n-1][0].b | 0 | src[n-1][1].a | 0 | src[n-1][1].r | 0 | src[n-1][1].g | 0 | src[n-1][1].b ]
	
	paddw        xmm4, xmm5 ; xmm4 <- [  src[n-1][0] + src[n-1][1]    |  src[n-1][1] + src[n-1][2]    ]
	movdqu       xmm5, xmm4 ; xmm5 == xmm4
	psrlw        xmm4, 1    ; xmm4 <- [ (src[n-1][0] + src[n-1][1])/2 | (src[n-1][1] + src[n-1][2])/2 ]

	packuswb     xmm4, xmm8 ; xmm4 <- [ 0 | 0 | (src[n-1][0] + src[n-1][1])/2 | (src[n-1][1] + src[n-1][2])/2 ]

	; --------------------------------------------------------------------------------------------------------------------------------------------------

	movdqu       xmm6, xmm1 ; xmm6 == xmm1
	movdqu       xmm7, xmm1 ; xmm7 == xmm1

	psrldq       xmm6, 4    ; xmm6 <- [ 0 | src[n-2][0] | src[n-2][1] | src[n-2][2] ]
	psrldq       xmm7, 8    ; xmm7 <- [ 0 |      0      | src[n-2][0] | src[n-2][1] ]

	punpcklbw    xmm6, xmm8 ; xmm6 <- [ 0 | src[n-2][1].a | 0 | src[n-2][1].r | 0 | src[n-2][1].g | 0 | src[n-2][1].b | 0 | src[n-2][2].a | 0 | src[n-2][2].r | 0 | src[n-2][2].g | 0 | src[n-2][2].b ]
	punpcklbw    xmm7, xmm8 ; xmm7 <- [ 0 | src[n-2][0].a | 0 | src[n-2][0].r | 0 | src[n-2][0].g | 0 | src[n-2][0].b | 0 | src[n-2][1].a | 0 | src[n-2][1].r | 0 | src[n-2][1].g | 0 | src[n-2][1].b ]
	
	paddw        xmm6, xmm7 ; xmm6 <- [  src[n-2][0] + src[n-2][1]    |  src[n-2][1] + src[n-2][2]    ]
	movdqu       xmm7, xmm6 ; xmm7 == xmm6
	psrlw        xmm6, 1    ; xmm6 <- [ (src[n-2][0] + src[n-2][1])/2 | (src[n-2][1] + src[n-2][2])/2 ]

	packuswb     xmm6, xmm8 ; xmm6 <- [ 0 | 0 | (src[n-2][0] + src[n-2][1])/2 | (src[n-2][1] + src[n-2][2])/2 ]

	; --------------------------------------------------------------------------------------------------------------------------------------------------

	movdqu       xmm2, xmm0 ; xmm2 == xmm0
	movdqu       xmm3, xmm1 ; xmm3 == xmm1

	psrldq       xmm2, 8    ; xmm2 <- [ 0 | 0 | src[n-1][0] | src[n-1][1] ]
	psrldq       xmm3, 8    ; xmm3 <- [ 0 | 0 | src[n-2][0] | src[n-2][1] ]

	punpcklbw    xmm2, xmm8 ; xmm2 <- [ 0 | src[n-1][0].a | 0 | src[n-1][0].r | 0 | src[n-1][0].g | 0 | src[n-1][0].b | 0 | src[n-1][1].a | 0 | src[n-1][1].r | 0 | src[n-1][1].g | 0 | src[n-1][1].b ]
	punpcklbw    xmm3, xmm8 ; xmm3 <- [ 0 | src[n-2][0].a | 0 | src[n-2][0].r | 0 | src[n-2][0].g | 0 | src[n-2][0].b | 0 | src[n-2][1].a | 0 | src[n-2][1].r | 0 | src[n-2][1].g | 0 | src[n-2][1].b ]

	paddw        xmm2, xmm3 ; xmm2 <- [  src[n-1][0] + src[n-2][0]    |  src[n-1][1] + src[n-2][1]    ]
	psrlw        xmm2, 1    ; xmm2 <- [ (src[n-1][0] + src[n-2][0])/2 | (src[n-1][1] + src[n-2][1])/2 ]

	packuswb     xmm2, xmm8 ; xmm2 <- [ 0 | 0 | (src[n-1][0] + src[n-2][0])/2 | (src[n-1][1] + src[n-2][1])/2 ]
	;                                                     MUCHAS COSAS LOCAS PASAN EN ESTE LUGAR...
	; --------------------------------------------------------------------------------------------------------------------------------------------------

	; xmm5 <- [ src[n-1][0] + src[n-1][1] | src[n-1][1] + src[n-1][2] ]
	; xmm7 <- [ src[n-2][0] + src[n-2][1] | src[n-2][1] + src[n-2][2] ]

	paddw        xmm5, xmm7 ; xmm5 <- [  src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1]    |  src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2]    ]
	psrlw        xmm5, 2    ; xmm5 <- [ (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]

	packuswb     xmm5, xmm8 ; xmm5 <- [ 0 | 0 | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]

	; --------------------------------------------------------------------------------------------------------------------------------------------------

	; xmm0 <- [ src[n-1][0] | src[n-1][1] |                         src[n-1][2]                       |                         src[n-1][3]                       ]
	; xmm1 <- [ src[n-2][0] | src[n-2][1] |                         src[n-2][2]                       |                         src[n-2][3]                       ]
	; xmm2 <- [      0      |      0      |               (src[n-1][0] + src[n-2][0])/2               |               (src[n-1][1] + src[n-2][1])/2               ]
	; xmm4 <- [      0      |      0      |               (src[n-1][0] + src[n-1][1])/2               |               (src[n-1][1] + src[n-1][2])/2               ]
	; xmm6 <- [      0      |      0      |               (src[n-2][0] + src[n-2][1])/2               |               (src[n-2][1] + src[n-2][2])/2               ]
	; xmm5 <- [      0      |      0      | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]


	movdqu       xmm9, xmm2 ; xmm9 == xmm2
	psrldq       xmm2, 4    ; xmm2 <- [              0                |      0      |              0                | (src[n-1][0] + src[n-2][0])/2 ]
	pslldq       xmm2, 12   ; xmm2 <- [ (src[n-1][0] + src[n-2][0])/2 |      0      |              0                |              0                ]
	pslldq       xmm9, 12   ; xmm9 <- [ (src[n-1][1] + src[n-2][1])/2 |      0      |              0                |              0                ]
	psrldq       xmm9, 8    ; xmm9 <- [              0                |      0      | (src[n-1][1] + src[n-2][1])/2 |              0                ]
	por          xmm2, xmm9 ; xmm2 <- [ (src[n-1][0] + src[n-2][0])/2 |      0      | (src[n-1][1] + src[n-2][1])/2 |              0                ]


	movdqu       xmm9, xmm5 ; xmm9 == xmm5
	psrldq       xmm5, 4    ; xmm5 <- [                            0                              |                            0                              |      0      | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 ]
	pslldq       xmm5, 8    ; xmm5 <- [                            0                              | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 |      0      |                            0                              ]
	pslldq       xmm9, 12   ; xmm9 <- [ (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 |                            0                              |      0      |                            0                              ]
	psrldq       xmm9, 12   ; xmm9 <- [                            0                              |                            0                              |      0      | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]
	por          xmm5, xmm9 ; xmm5 <- [                            0                              | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 |      0      | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]

	por          xmm2, xmm5 ; xmm2 <- [ (src[n-1][0] + src[n-2][0])/2 | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 | (src[n-1][1] + src[n-2][1])/2 | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]




	movdqu       xmm9, xmm4 ; xmm9 == xmm4
	psrldq       xmm4, 4    ; xmm4 <- [              0                |              0                |      0      | (src[n-1][0] + src[n-1][1])/2 ]
	pslldq       xmm4, 8    ; xmm4 <- [              0                | (src[n-1][0] + src[n-1][1])/2 |      0      |              0                ]
	pslldq       xmm9, 12   ; xmm9 <- [ (src[n-1][1] + src[n-1][2])/2 |              0                |      0      |              0                ]
	psrldq       xmm9, 12   ; xmm9 <- [              0                |              0                |      0      | (src[n-1][1] + src[n-1][2])/2 ]
	por          xmm4, xmm9 ; xmm4 <- [              0                | (src[n-1][0] + src[n-1][1])/2 |      0      | (src[n-1][1] + src[n-1][2])/2 ]




	movdqu       xmm9, xmm6 ; xmm9 == xmm6
	psrldq       xmm6, 4    ; xmm6 <- [              0                |              0                |      0      | (src[n-2][0] + src[n-2][1])/2 ]
	pslldq       xmm6, 8    ; xmm6 <- [              0                | (src[n-2][0] + src[n-2][1])/2 |      0      |              0                ]
	pslldq       xmm9, 12   ; xmm9 <- [ (src[n-2][1] + src[n-2][2])/2 |              0                |      0      |              0                ]
	psrldq       xmm9, 12   ; xmm9 <- [              0                |              0                |      0      | (src[n-2][1] + src[n-2][2])/2 ]
	por          xmm6, xmm9 ; xmm6 <- [              0                | (src[n-2][0] + src[n-2][1])/2 |      0      | (src[n-2][1] + src[n-2][2])/2 ]






	movdqu       xmm3, xmm0 ; xmm3 == xmm0
	psrldq       xmm3, 8    ; xmm3 <- [      0      |      0      | src[n-1][0] | src[n-1][1] ]
	movdqu       xmm9, xmm3 ; xmm9 == xmm3
	psrldq       xmm3, 4    ; xmm3 <- [      0      |      0      |      0      | src[n-1][0] ]
	pslldq       xmm3, 12   ; xmm3 <- [ src[n-1][0] |      0      |      0      |      0      ]
	pslldq       xmm9, 12   ; xmm9 <- [ src[n-1][1] |      0      |      0      |      0      ]
	psrldq       xmm9, 8    ; xmm9 <- [      0      |      0      | src[n-1][1] |      0      ]
	por          xmm3, xmm9 ; xmm3 <- [ src[n-1][0] |      0      | src[n-1][1] |      0      ]

	por          xmm3, xmm4 ; xmm3 <- [ src[n-1][0] | (src[n-1][0] + src[n-1][1])/2 | src[n-1][1] | (src[n-1][1] + src[n-1][2])/2 ]


	movdqu       xmm5, xmm1 ; xmm5 == xmm1
	psrldq       xmm5, 8    ; xmm5 <- [      0      |      0      | src[n-2][0] | src[n-2][1] ]
	movdqu       xmm9, xmm5 ; xmm9 == xmm5
	psrldq       xmm5, 4    ; xmm5 <- [      0      |      0      |      0      | src[n-2][0] ]
	pslldq       xmm5, 12   ; xmm5 <- [ src[n-2][0] |      0      |      0      |      0      ]
	pslldq       xmm9, 12   ; xmm9 <- [ src[n-2][1] |      0      |      0      |      0      ]
	psrldq       xmm9, 8    ; xmm9 <- [      0      |      0      | src[n-2][1] |      0      ]
	por          xmm5, xmm9 ; xmm5 <- [ src[n-2][0] |      0      | src[n-2][1] |      0      ]

	por          xmm5, xmm6 ; xmm5 <- [ src[n-2][0] | (src[n-2][0] + src[n-2][1])/2 | src[n-2][1] | (src[n-2][1] + src[n-2][2])/2 ]


; --------------------------------------------------------------------------------------------------------------------------------------------------
	; xmm5 <- [ src[n-2][0] | (src[n-2][0] + src[n-2][1])/2 | src[n-2][1] | (src[n-2][1] + src[n-2][2])/2 ]
	; xmm2 <- [ (src[n-1][0] + src[n-2][0])/2 | (src[n-1][0] + src[n-1][1] + src[n-2][0] + src[n-2][1])/4 | (src[n-1][1] + src[n-2][1])/2 | (src[n-1][1] + src[n-1][2] + src[n-2][1] + src[n-2][2])/4 ]
	; xmm3 <- [ src[n-1][0] | (src[n-1][0] + src[n-1][1])/2 | src[n-1][1] | (src[n-1][1] + src[n-1][2])/2 ]

	movdqu    [r13], xmm2
	movdqu    [r13 + 4*r8], xmm5


	add       rbx, 8
	add       r13, 16

	add       r12, 4
	; add       r9, 2

	; cmp       r9, rsi
	; jne       .asd

	; xor       r9, r9

.asd:
	cmp       r12, r9
	jne       .fin_ciclo

	xor       r12, r12
	lea       r13, [r13 + 4*r8 + 16]

	add       rbx, 8

.fin_ciclo:
	jmp       .ciclo


.fin:
	add     rsp, 8
	pop     r15
	pop     r14
	pop     r13
	pop     r12
	pop     rbx
	pop     rbp
	ret


