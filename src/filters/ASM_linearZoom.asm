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
lea     r14, [r8 - 4]      ; r14 <- dstw - 4
pxor    xmm8, xmm8

mov     rbx, rdi           ; rbx <- &src[n-1][0]
lea     r13, [rcx + 8*r8]  ; r13 <- &dst[n-3][0]


.ciclo:

cmp       rbx, rax
jge       .finn_ciclo

.genero_filas_modificadas:

; Versión 2.1

movdqu     xmm0, [rbx]         ; xmm0 <- [ src[n-1][3] | src[n-1][2] | src[n-1][1] | src[n-1][0] ]
movdqu     xmm1, [rbx + 4*rsi] ; xmm1 <- [ src[n-2][3] | src[n-2][2] | src[n-2][1] | src[n-2][0] ]

movdqu    xmm2, xmm0
movdqu    xmm3, xmm1

pslldq    xmm0, 8 ; xmm0 <- [ src[n-1][1] | src[n-1][0] |      0      |      0      ]
pslldq    xmm1, 8 ; xmm1 <- [ src[n-2][1] | src[n-2][0] |      0      |      0      ]

psrldq    xmm2, 4 ; xmm2 <- [      0      | src[n-1][3] | src[n-1][2] | src[n-1][1] ]
psrldq    xmm3, 4 ; xmm3 <- [      0      | src[n-2][3] | src[n-2][2] | src[n-2][1] ]

punpckhbw  xmm0, xmm8 
punpckhbw  xmm1, xmm8
punpcklbw  xmm2, xmm8
punpcklbw  xmm3, xmm8

; xmm0 <- [ src[n-1][1] | src[n-1][0] ]
; xmm1 <- [ src[n-2][1] | src[n-2][0] ]
; xmm2 <- [ src[n-1][2] | src[n-1][1] ]
; xmm3 <- [ src[n-2][2] | src[n-2][1] ]		

movdqu      xmm4, xmm1
paddw       xmm4, xmm0 ; xmm4 <- [ src[n-2][1] + src[n-1][1] | src[n-2][0] + src[n-1][0] ]
movdqu      xmm6, xmm4
psrlw       xmm4, 1    ; xmm4 <- [ (src[n-2][1] + src[n-1][1]) / 2 | (src[n-2][0] + src[n-1][0]) / 2 ]

movdqu      xmm5, xmm3
paddw       xmm5, xmm2 ; xmm5 <- [ src[n-2][2] + src[n-1][2] | src[n-2][1] + src[n-1][1] ]
paddw       xmm6, xmm5 ; xmm6 <- [ src[n-2][1] + src[n-1][1] + src[n-2][2] + src[n-1][2] | src[n-2][0] + src[n-1][0] + src[n-2][1] + src[n-1][1] ]
psrlw       xmm5, 1    ; xmm5 <- [ (src[n-2][2] + src[n-1][2]) / 2 | (src[n-2][1] + src[n-1][1]) / 2 ]
psrlw       xmm6, 2    ; xmm6 <- [ (src[n-2][1] + src[n-1][1] + src[n-2][2] + src[n-1][2]) / 4 | (src[n-2][0] + src[n-1][0] + src[n-2][1] + src[n-1][1]) / 4 ]

paddw       xmm3, xmm1
psrlw       xmm3, 1    ; xmm3 <- [ (src[n-2][2] + src[n-2][1]) / 2 | (src[n-2][1] + src[n-2][0]) / 2 ]

packuswb    xmm1, xmm8 ; xmm1 <- [      0      |      0      |           src[n-2][1]           |           src[n-2][0]           ]
packuswb    xmm3, xmm8 ; xmm3 <- [      0      |      0      | (src[n-2][2] + src[n-2][1]) / 2 | (src[n-2][1] + src[n-2][0]) / 2 ]
packuswb    xmm4, xmm8 ; xmm5 <- [      0      |      0      | (src[n-2][1] + src[n-1][1]) / 2 | (src[n-2][0] + src[n-1][0]) / 2 ]
packuswb    xmm6, xmm8 ; xmm6 <- [      0      |      0      | (src[n-2][1] + src[n-1][1] + src[n-2][2] + src[n-1][2]) / 4 | (src[n-2][0] + src[n-1][0] + src[n-2][1] + src[n-1][1]) / 4 ]

pslldq     xmm3, 8
por        xmm1, xmm3       ; xmm1 <- [ (src[n-2][2] + src[n-2][1]) / 2 | (src[n-2][1] + src[n-2][0]) / 2 |           src[n-2][1]           | src[n-2][0] ]
pshufd     xmm1, xmm1, 0xD8 ; xmm1 <- [ (src[n-2][2] + src[n-2][1]) / 2 |           src[n-2][1]           | (src[n-2][1] + src[n-2][0]) / 2 | src[n-2][0] ]

pslldq     xmm6, 8
por        xmm4, xmm6
pshufd     xmm4, xmm4, 0xD8


movdqu    [r13], xmm4
movdqu    [r13 + 4*r8], xmm1

add       rbx, 8
add       r13, 16

add       r12, 4

.asd:

cmp       r12, r14
jl        .fin_ciclo

xor       r12, r12
lea       r13, [r13 + 4*r8 + 16]

add       rbx, 8

.fin_ciclo:

jmp       .ciclo


.finn_ciclo:

lea     rbx, [rdi + 4*rsi - 8]
lea     r13, [rcx + 8*r8 - 16]
lea     r13, [r13 + 4*r8]

.ciclo2:

cmp     rbx, rax
jge     .fin_ciclo2

.genero_borde:

; Versión 1.1

movq     xmm0, [rbx]         ; xmm0 <- [ ----- | ----- | src[n-1][m-2] | src[n-1][m-1] ]
movq     xmm1, [rbx + 4*rsi] ; xmm1 <- [ ----- | ----- | src[n-2][m-2] | src[n-2][m-1] ]


punpcklbw    xmm0, xmm8 ; xmm0 <- [ src[n-1][m-2] | src[n-1][m-1] ]
punpcklbw    xmm1, xmm8 ; xmm1 <- [ src[n-2][m-2] | src[n-2][m-1] ]

movdqu     xmm2, xmm0
movdqu     xmm3, xmm1

paddw    xmm2, xmm1    ; xmm2 <- [ src[n-2][m-2] + src[n-1][m-2] | src[n-2][m-1] + src[n-1][m-1] ]
movdqu   xmm4, xmm2    ; xmm4 <- [ src[n-2][m-2] + src[n-1][m-2] | src[n-2][m-1] + src[n-1][m-1] ]
psrldq   xmm4, 8       ; xmm4 <- [               0               | src[n-2][m-1] + src[n-1][m-1] ]
paddw    xmm4, xmm2    ; xmm4 <- [ ------- | src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1] ]

psrlw    xmm2, 1       ; xmm2 <- [ (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
psrlw    xmm4, 2       ; xmm4 <- [ ------- | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 ]

movdqu      xmm5, xmm1 ; xmm1 <- [ src[n-2][m-2] | src[n-2][m-1] ]

psrldq      xmm5, 8    ; xmm5 <- [       0       | src[n-2][m-2] ]

paddw       xmm5, xmm1
psrlw       xmm5, 1    ; xmm5 <- [ ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]

packuswb    xmm1, xmm8 ; xmm1 <- [       0       |        0       |            src[n-2][m-2]            |             src[n-2][m-1]           ] 
packuswb    xmm5, xmm8 ; xmm5 <- [       0       |        0       |            -------------            | (src[n-1][m-2] + src[n-1][m-1]) / 2 ]
packuswb    xmm2, xmm8 ; xmm2 <- [       0       |        0       | (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]
packuswb    xmm4, xmm8 ; xmm4 <- [       0       |        0       |            -------------            | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 ]

pslldq      xmm4, 8
por         xmm2, xmm4       ; xmm2 <- [ ------- | (src[n-2][m-2] + src[n-1][m-2] + src[n-2][m-1] + src[n-1][m-1]) / 4 | (src[n-2][m-2] + src[n-1][m-2]) / 2 | (src[n-2][m-1] + src[n-1][m-1]) / 2 ]

pshufd      xmm2, xmm2, 0x09 ; xmm2 <- [ (src[n-1][m-1] + src[n-2][m-1]) / 2 | (src[n-1][m-1] + src[n-2][m-1]) / 2 | (src[n-1][m-1] + src[n-2][m-1] + src[n-1][m-2] + src[n-2][m-2]) / 4 | (src[n-1][m-2] + src[n-2][m-2]) / 2 ]

pslldq      xmm5, 8
por         xmm5, xmm1       ; xmm5 <- [ ------------- | (src[n-1][m-2] + src[n-1][m-1]) / 2 | src[n-2][m-2] | src[n-2][m-1] ]

pshufd      xmm5, xmm5, 0x09 ; xmm5 <- [ src[n-2][m-1] | src[n-2][m-1] | (src[n-1][m-2] + src[n-1][m-1]) / 2 | src[n-2][m-2] ]

movdqu   [r13], xmm2
movdqu   [r13 + 4*r8], xmm5


lea     rbx, [rbx + 4*rsi]
lea     r13, [r13 + 8*r8]

jmp     .ciclo2


.fin_ciclo2:

xor     r12, r12
mov     rbx, rdi
mov     r13, rcx


.ciclo3:

cmp     r12, rsi
jge     .fin

movdqu    xmm0, [rbx] ; xmm0 <- [ src[n-1][3] | src[n-1][2] | src[n-1][1] | src[n-1][0] ]
movdqu    xmm1, xmm0  ; xmm1 <- [ src[n-1][3] | src[n-1][2] | src[n-1][1] | src[n-1][0] ]

psrldq    xmm1, 4     ; xmm1 <- [      0      | src[n-1][3] | src[n-1][2] | src[n-1][1] ]

punpcklbw    xmm0, xmm8 ; xmm0 <- [ src[n-1][1] | src[n-1][0] ]
punpcklbw    xmm1, xmm8 ; xmm1 <- [ src[n-1][2] | src[n-1][1] ]

paddw        xmm1, xmm0 ; xmm1 <- [ (src[n-1][2] + src[n-1][1]) | (src[n-1][1] + src[n-1][0]) ]
psrlw        xmm1, 1    ; xmm1 <- [ (src[n-1][2] + src[n-1][1]) / 2 | (src[n-1][1] + src[n-1][0]) / 2 ]

packuswb     xmm0, xmm8 ; xmm0 <- [      0      |      0      |           src[n-1][1]           |           src[n-1][0]           ]
packuswb     xmm1, xmm8 ; xmm1 <- [      0      |      0      | (src[n-1][2] + src[n-1][1]) / 2 | (src[n-1][1] + src[n-1][0]) / 2 ]

pslldq       xmm1, 8
por          xmm0, xmm1 ; xmm0 <- [ (src[n-1][2] + src[n-1][1]) / 2 | (src[n-1][1] + src[n-1][0]) / 2 | src[n-1][1] | src[n-1][0] ]

pshufd       xmm0, xmm0, 0xD8

movdqu       [r13], xmm0
movdqu       [r13 + 4*r8], xmm0

add          rbx, 8
add          r13, 16
add          r12, 2

jmp          .ciclo3


.fin:

add     rsp, 8
pop     r15
pop     r14
pop     r13
pop     r12
pop     rbx
pop     rbp
ret

