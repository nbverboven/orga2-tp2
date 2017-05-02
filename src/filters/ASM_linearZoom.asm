global ASM_linearZoom
extern C_linearZoom


section .data


section .text

%define saturacion_max 255
%define saturacion_min 0
%define offset_ARGB 4
%define offset_ARGB_A 0
%define offset_ARGB_R 3
%define offset_ARGB_G 2
%define offset_ARGB_B 1


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



	mov     rbx, rcx
	xor     rcx, rcx
	lea     rcx, [rsi * rdx]

; n = número de filas de src
.ciclo:
	; Veo si termino...

	movdqu       xmm0, [rdi + offset_ARGB*(fila) + offset_ARGB*columna]   ; xmm0 <- [ src[n-1][0] | src[n-1][1] | src[n-1][2] | src[n-1][3] ]
	movdqu       xmm1, [rdi + offset_ARGB*(fila+1) + offset_ARGB*columna] ; xmm1 <- [ src[n-2][0] | src[n-2][1] | src[n-2][2] | src[n-2][3] ]

	pxor         xmm8, xmm8 ; xmm8 <- [ 0 | 0 | 0 | 0 ]

; --------------------------------------------------------------------------------------------------------------------------------------------------

	movdqu       xmm4, xmm0 ; xmm4 == xmm0
	movdqu       xmm5, xmm0 ; xmm5 == xmm0

	psrldq       xmm4, 4 ; xmm4 <- [ 0 | src[n-1][0] | src[n-1][1] | src[n-1][2] ]
	psrldq       xmm5, 8 ; xmm5 <- [ 0 |      0      | src[n-1][0] | src[n-1][1] ]

	punpcklbw    xmm4, xmm8 ; xmm4 <- [ 0 | src[n-1][1].a | 0 | src[n-1][1].r | 0 | src[n-1][1].g | 0 | src[n-1][1].b | 0 | src[n-1][2].a | 0 | src[n-1][2].r | 0 | src[n-1][2].g | 0 | src[n-1][2].b ]
	punpcklbw    xmm5, xmm8 ; xmm5 <- [ 0 | src[n-1][0].a | 0 | src[n-1][0].r | 0 | src[n-1][0].g | 0 | src[n-1][0].b | 0 | src[n-1][1].a | 0 | src[n-1][1].r | 0 | src[n-1][1].g | 0 | src[n-1][1].b ]
	
	paddw        xmm4, xmm5 ; xmm4 <- [  src[n-1][0] + src[n-1][1]    |  src[n-1][1] + src[n-1][2]    ]
	movdqu       xmm5, xmm4 ; xmm5 == xmm4
	psrlw        xmm4, 1    ; xmm4 <- [ (src[n-1][0] + src[n-1][1])/2 | (src[n-1][1] + src[n-1][2])/2 ]

	packuswb     xmm4, xmm8 ; xmm4 <- [ 0 | 0 | (src[n-1][0] + src[n-1][1])/2 | (src[n-1][1] + src[n-1][2])/2 ]

; --------------------------------------------------------------------------------------------------------------------------------------------------

	movdqu       xmm6, xmm1 ; xmm6 == xmm1
	movdqu       xmm7, xmm1 ; xmm7 == xmm1

	psrldq       xmm6, 4 ; xmm6 <- [ 0 | src[n-2][0] | src[n-2][1] | src[n-2][2] ]
	psrldq       xmm7, 8 ; xmm7 <- [ 0 |      0      | src[n-2][0] | src[n-2][1] ]

	punpcklbw    xmm6, xmm8 ; xmm6 <- [ 0 | src[n-2][1].a | 0 | src[n-2][1].r | 0 | src[n-2][1].g | 0 | src[n-2][1].b | 0 | src[n-2][2].a | 0 | src[n-2][2].r | 0 | src[n-2][2].g | 0 | src[n-2][2].b ]
	punpcklbw    xmm7, xmm8 ; xmm7 <- [ 0 | src[n-2][0].a | 0 | src[n-2][0].r | 0 | src[n-2][0].g | 0 | src[n-2][0].b | 0 | src[n-2][1].a | 0 | src[n-2][1].r | 0 | src[n-2][1].g | 0 | src[n-2][1].b ]
	
	paddw        xmm6, xmm7 ; xmm6 <- [  src[n-2][0] + src[n-2][1]    |  src[n-2][1] + src[n-2][2]    ]
	movdqu       xmm7, xmm6 ; xmm7 == xmm6
	psrlw        xmm6, 1    ; xmm6 <- [ (src[n-2][0] + src[n-2][1])/2 | (src[n-2][1] + src[n-2][2])/2 ]

	packuswb     xmm6, xmm8 ; xmm6 <- [ 0 | 0 | (src[n-2][0] + src[n-2][1])/2 | (src[n-2][1] + src[n-2][2])/2 ]

; --------------------------------------------------------------------------------------------------------------------------------------------------

	movdqu       xmm2, xmm0 ; xmm2 == xmm0
	movdqu       xmm3, xmm1 ; xmm3 == xmm1

	psrldq       xmm2, 8 ; xmm2 <- [ 0 | 0 | src[n-1][0] | src[n-1][1] ]
	psrldq       xmm3, 8 ; xmm3 <- [ 0 | 0 | src[n-2][0] | src[n-2][1] ]

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

	
	
; --------------------------------------------------------------------------------------------------------------------------------------------------


	add     rsp, 8
	pop     r15
	pop     r14
	pop     r13
	pop     r12
	pop     rbp
	ret
