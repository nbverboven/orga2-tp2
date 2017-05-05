global ASM_linearZoom
extern C_linearZoom


section .data


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

	shl     rsi, 8
	shr     rsi, 8
	shl     r8, 8
	shr     r8, 8

	mov     rbx, rcx
	; xor     rcx, rcx
	; lea     rcx, [r8 - 5] ; rcx <- srch = alto de la imagen original

	; lea     r12, [1] ; índice filas
	lea     r14, [0]
	lea     r13, [4*r8]
	lea     r12, [0]
	lea          rcx, [rsi-4]

	pxor         xmm8, xmm8 ; xmm8 <- [ 0 | 0 | 0 | 0 ]

; n = número de filas de src
; .ciclo1:

; 	lea     r13, [0] ; índice columnas


.ciclo2:
	; Veo si ya terminé...

	cmp          r14, rcx
	jge          .fin 

	; lea          r15, [r12 + r13]
	lea          r15, [rdi + r13]

	; movdqu       xmm0, [rdi + offset_ARGB*(fila) + offset_ARGB*columna]   ; xmm0 <- [ src[n-1][0] | src[n-1][1] | src[n-1][2] | src[n-1][3] ]
	; movdqu       xmm1, [rdi + offset_ARGB*(fila+1) + offset_ARGB*columna] ; xmm1 <- [ src[n-2][0] | src[n-2][1] | src[n-2][2] | src[n-2][3] ]

	movdqu       xmm0, [rdi + 4*r12]   ; xmm0 <- [ src[n-1][0] | src[n-1][1] | src[n-1][2] | src[n-1][3] ]
	movdqu       xmm1, [r15 + 4*r12] ; xmm1 <- [ src[n-2][0] | src[n-2][1] | src[n-2][2] | src[n-2][3] ]


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

	lea          r8, [r8*4]
	add          rbx, r8
	movdqu       [rbx], xmm3
	add          rbx, r8
	movdqu       [rbx], xmm2
	add          rbx, r8
	movdqu       [rbx], xmm5



.fin_ciclo2:
; --------------------------------------------------------------------------------------------------------------------------------------------------
; --------------------------------------------------------------------------------------------------------------------------------------------------
	add          r14, 2
	add          r12, 2
	jmp          .ciclo2

; --------------------------------------------------------------------------------------------------------------------------------------------------
; --------------------------------------------------------------------------------------------------------------------------------------------------

; .fin_ciclo1:
; 	inc          r12

; 	jmp        .ciclo1

.fin:
	add     rsp, 8
	pop     r15
	pop     r14
	pop     r13
	pop     r12
	pop     rbx
	pop     rbp
	ret
