%define offset_ARGB 4
%define offset_ARGB_A 0
%define offset_ARGB_R 3
%define offset_ARGB_G 2
%define offset_ARGB_B 1

global ASM_convertYUVtoRGB
global ASM_convertRGBtoYUV
extern C_convertYUVtoRGB
extern C_convertRGBtoYUV

section .rodata 
    replaceAto1: dw 0,0,0,1, 0,0,0,1

    mask_Y: dw 66, 129, 25, 128, 66, 129, 25, 128
    mask_U: dw -38, -74, 112, 128, -38, -74, 112, 128
    mask_V: dw 112, -94, -18, 128, 112, -94, -18, 128

    add_y: dd 16, 16, 16, 16
    add_u: dd 128, 128, 128, 128
    add_v: dd 128, 128, 128, 128

    soloU: dd 0xffff0000, 0x00000000, 0xffff0000, 0x00000000
    soloV: dd 0xffff0000, 0x00000000, 0xffff0000, 0x00000000
    soloY: dd 0xffff0000, 0x00000000, 0xffff0000, 0x00000000

    val128: dd 0, 128, 0, 0
    val16: dd 0, 16, 0, 0
    val298: dd 0, 298, 0, 0
    val516: dd 0, 516, 0, 0
    val100: dd 0, 100, 0, 0
    val208: dd 0, 208, 0, 0
    val409: dd 0, 409, 0, 0

section .text

    ;        ********    ATENCION!!     ********
    ;    Esta funcion esta siendo desarrollada por Andres.
    ;    Puto el que lee

    ; rdi -> puntero src    (uint8_t)
    ; rsi -> puntero srcw   (uint32_t)
    ; rdx -> puntero srch   (uint32_t)
    ; rcx -> puntero dst    (uint8_t)
    ; r8 -> puntero dstw    (uint32_t)
    ; r9 -> puntero dsth    (uint32_t)
    ASM_convertYUVtoRGB:

             push rbp
            mov rbp, rsp
            push rbx
            push r12
            push r13
            push r14
            push r15
            ; Pila alineada

            mov r12, rdi    ;r12= puntero src
            mov r13, rcx    ;r13= puntero dst

            xor rax,rax
            mov eax, esi    ;eax= srcwi
            mov edx, edx    ;edx= srch
            mul edx         ;rax= srcw*srch
            mov edx, offset_ARGB
            mul edx         ;rax= srcw*srch*4
            mov r14, rax    ;r14= srcw*srch*4

            xor rbx, rbx

        .ciclo:
            cmp rbx, r14
            je .fin

            xorps xmm0, xmm0
            movq xmm1, [r12+rbx]
            punpcklbw xmm1, xmm0    ;xmm7=[A V U Y | A2 V2 U2 Y2]
            movdqu xmm2, xmm1
            movdqu xmm3, xmm1
            
        ;solo V
            pand xmm1, [soloV]      ;xmm1=[0 V 0 0 | 0 V2 0 0]
            movdqu xmm4, xmm1
            punpckhwd xmm1, xmm0    ;xmm1=[0 V 0 0]
            punpcklwd xmm4, xmm0    ;xmm4=[0 V2 0 0]
            psubd xmm1, [val128]    ;xmm1=[0 V-128 0 0]
            psubd xmm4, [val128]    ;xmm4=[0 V2-128 0 0]

        ;solo U
            psrldq xmm2, 2
            pand xmm2, [soloU]      ;xmm2=[0 U 0 0 | 0 U2 0 0]
            movdqu xmm5, xmm2
            punpckhwd xmm2, xmm0    ;xmm2=[0 U 0 0]
            punpcklwd xmm5, xmm0    ;xmm5=[0 U2 0 0]
            psubd xmm2, [val128]    ;xmm2=[0 U-128 0 0]
            psubd xmm5, [val128]    ;xmm5=[0 U2-128 0 0]

        ;solo Y
            psrldq xmm3, 4
            pand xmm3, [soloY]      ;xmm3=[0 Y 0 0 | 0 Y2 0 0]
            movdqu xmm6, xmm3
            punpckhwd xmm3, xmm0    ;xmm3=[0 Y 0 0]
            punpcklwd xmm6, xmm0    ;xmm6=[0 Y2 0 0]
            psubd xmm3, [val16]    ;xmm3=[0 Y-16 0 0]
            psubd xmm6, [val16]    ;xmm6=[0 Y2-16 0 0]
            pmulld xmm3, [val298]   ;xmm3=[0 298*(Y-16) 0 0]
            pmulld xmm6, [val298]   ;xmm6=[0 298*(Y2-16) 0 0]

        ;obtengo B
            movdqu xmm12, xmm3      ;xmm12=[0 298*(Y-16) 0 0] 
            movdqu xmm13, xmm6      ;xmm13=[0 298*(Y2-16) 0 0]
            movdqu xmm10, xmm2
            movdqu xmm11, xmm5
            pmulld xmm10, [val516]  ;xmm10=[0 516*(U-128) 0 0]
            pmulld xmm11, [val516]  ;xmm11=[0 516*(U2-128) 0 0]
            paddd xmm12, xmm10
            paddd xmm12, [val128]
            psrld xmm12, 8          ;xmm12=[0 298*(Y-16)+516*(U-128)-128 << 8 0 0]
            paddd xmm13, xmm11
            paddd xmm13, [val128]
            psrld xmm13, 8          ;xmm13=[0 298*(Y2-16)+516*(U2-128)-128 << 8 0 0]

        ;obtengo G
            movdqu xmm14, xmm3      ;xmm14=[0 298*(Y-16) 0 0] 
            movdqu xmm15, xmm6      ;xmm15=[0 298*(Y2-16) 0 0]
            movdqu xmm10, xmm2
            movdqu xmm11, xmm5
            pmulld xmm10, [val100]  ;xmm10=[0 100*(U-128) 0 0]
            pmulld xmm11, [val100]  ;xmm11=[0 100*(U2-128) 0 0]
            movdqu xmm8, xmm1
            movdqu xmm9, xmm4
            pmulld xmm8, [val208]  ;xmm8=[0 208*(V-128) 0 0]
            pmulld xmm9, [val208]  ;xmm9=[0 208*(V2-128) 0 0]
            psubd xmm14, xmm10
            psubd xmm14, xmm8
            paddd xmm14, [val128]
            psrld xmm14, 8          ;xmm14=[0 298*(Y-16)-100*(U-128)-208*(V-128)+128 << 8 0 0]
            psubd xmm15, xmm11
            psubd xmm15, xmm9
            paddd xmm15, [val128]
            psrld xmm15, 8          ;xmm15=[0 298*(Y2-16)-100*(U2-128)-208*(V2-128)+128 << 8 0 0]


        ;obtengo R
            movdqu xmm8, xmm1
            movdqu xmm9, xmm4
            pmulld xmm8, [val409]   ;xmm8=[0 409*(V-128) 0 0]
            pmulld xmm9, [val409]   ;xmm9=[0 409*(V2-128) 0 0]
                                    ;xmm3=[0 298*(Y-16) 0 0]
            paddd xmm8, xmm3        
            paddd xmm8, [val128]
            psrld xmm8, 8           ;xmm8=[0 298*(Y-16)+409*(V-128)+128 << 8 0 0]
                                    ;xmm6=[0 298*(Y2-16) 0 0]
            paddd xmm9, xmm6
            paddd xmm9, [val128]
            psrld xmm9, 8           ;xmm9=[0 298*(Y2-16)+409*(V2-128)+128 << 8 0 0]

        ;acomodo B
            packusdw xmm12, xmm0
            packuswb xmm12, xmm0
            packusdw xmm13, xmm0
            packuswb xmm13, xmm0
            pslldq xmm12, 4
            por xmm12, xmm13        ;xmm12=[---- | ---- | 0 nuevoB 0 0 | 0 nuevoB2 0 0]

        ;acomodo G    
            packusdw xmm14, xmm0
            packuswb xmm14, xmm0
            packusdw xmm15, xmm0
            packuswb xmm15, xmm0
            pslldq xmm14, 5
            pslldq xmm15, 1
            por xmm14, xmm15        ;xmm14=[---- | ---- | 0 0 nuevoG 0 | 0 0 nuevoG2 0]

        ;acomodo R
            packusdw xmm8, xmm0
            packuswb xmm8, xmm0
            packusdw xmm9, xmm0
            packuswb xmm9, xmm0
            pslldq xmm8, 6
            pslldq xmm9, 2
            por xmm8, xmm9          ;xmm8=[---- | ---- | 0 0 0 nuevoR | 0 0 0 nuevoR2]

        ;junto todo
            por xmm8, xmm14
            por xmm8, xmm12         ;xmm8=[---- | ---- | 0 nuevoB nuevoG nuevoR | 0 nuevoB2 nuevoG2 nuevoR2]

        ;muevo el dato a la nueva imagen
            movq [r13+rbx], xmm8

            add rbx, 8
            jmp .ciclo

        .fin:
            ; Desencolo
            pop r15
            pop r14
            pop r13
            pop r12
            pop rbx
            pop rbp            

    ret

    ; rdi -> puntero src    (uint8_t)
    ; rsi -> srcw   (uint32_t)
    ; rdx -> srch   (uint32_t)
    ; rcx -> puntero dst    (uint8_t)
    ; r8 -> dstw    (uint32_t)
    ; r9 -> dsth    (uint32_t)
    ASM_convertRGBtoYUV:
            push rbp
            mov rbp, rsp
            push rbx
            push r12
            push r13
            push r14
            push r15
            ; Pila alineada

            mov r12, rdi    ;r12= puntero src
            mov r13, rcx    ;r13= puntero dst

            xor rax,rax
            mov eax, esi    ;eax= srcwi
            mov edx, edx    ;edx= srch
            mul edx         ;rax= srcw*srch
            mov edx, offset_ARGB
            mul edx         ;rax= srcw*srch*4
            mov r14, rax    ;r14= srcw*srch*4

            xor rbx, rbx
        .ciclo:
            cmp rbx, r14    ;if rbx == srch*srcw*4
            je .fin         ; then jmp .fin
            
            pmovzxbw xmm0, [r12+rbx]    ; xmm0 = [ pixel[1][1] | pixel[1][2] ]
            pmovzxbw xmm15, [r12+rbx]   ; xmm0 = [ pixel[1][1] | pixel[1][2] ]
            ;Como los pixeles vienen ARGB los voy a convertir a BRG1 para calcular YUV
            psrlq xmm0, 16             ; xmm0 << 16 (word)
            psllq xmm15, 16            ; xmm15 >> 16 (word)
            pblendw xmm0, xmm15, 0x88
            psrlq xmm0, 16             ; xmm0 << 16 (word)
            psllq xmm15, 16            ; xmm15 >> 16 (word)
            pblendw xmm0, xmm15, 0x88
            psrlq xmm0, 16             ; xmm0 << 16 (word)
            movdqu xmm15, [replaceAto1]; xmm3 = [ 0 0 0 1 | 0 0 0 1 ]
            pblendw xmm0, xmm15, 0x88  ; xmm0 = [ R G B 1 | R G B 1]
            ; xmm0 = [  R   G   B   1  |  R   G   B   1  ]

            ; Estoy moviendo 2 pixeles,1 pixel = 4 bits (ARGB)

            ;uso rcx para operar con el segundo pixel
            mov rcx, rbx
            add rcx, 4
            ;copio A dado que sigue igual
            mov al, [r12+rbx]   ; copio A primer pixel
            mov [r13+rbx], al   ;A primer pixel
            mov al, [r12+rcx]   ; copio A segundo pixel
            mov [r13+rcx], al   ;A segundo pixel

            ;calculo v
            movdqu xmm3, [mask_V]   ; xmm3 = [ 112 -94 -18 128 | 112 -94 -18 128 ]
                                    ; xmm0 = [  R   G   B   1  |  R   G   B   1  ]
            pmaddwd xmm3, xmm0      ; xmm3 = [ 112*R-94*G  -18*B+128 | 112*R-94*G  -18*B+128 ]
            phaddd xmm3, xmm3       ; xmm3 = [ xxx xxx | (112*R-94*G-18*B+128) (112*R-94*G-18*B+128) ]
            psrld xmm3, 8           ; xmm3 >> 8 (dword)
            movdqu xmm11, [add_v]   ; xmm11 = [ 128 128 128 128 ]
            paddd xmm3, xmm11       ; xmm3 = [ ? ? (128+V) (128+V) ]
            packusdw xmm3,xmm3      ; xmm3 = [ ? ? ? ? | ? ? V V ]
            packuswb xmm3,xmm3      ; xmm3 = [ ? ? ? ? ? ? ? ? | ? ? ? ? ? ? V V ]
            movq rax, xmm3

            inc rcx
            inc rbx
            mov [r13+rbx], al
            mov al, ah
            mov [r13+rcx], al


            ;calculo U
            movdqu xmm2, [mask_U]   ; xmm2 = [ -38 -74 112 128 ]
                                    ; xmm0 = [  R   G   B   1  |  R   G   B   1  ]
            pmaddwd xmm2, xmm0      ; xmm2 = [ -38*R-74*G 112*B+128 | -38*R-74*G 112*B+128 ]
            phaddd xmm2, xmm2       ; xmm2 = [ xxx xxx |  (-38*R-74*G+112*B+128)  (-38*R-74*G+112*B+128) ]
            psrld xmm2, 8           ; xmm2 >> 8 (dword)
            movdqu xmm10, [add_u]   ; xmm10 = [ 128 128 128 128 ]
            paddd xmm2, xmm10       ; xmm2 = [ ? ? (128+Y) (128+U) ]
            packusdw xmm2,xmm2      ; xmm2 = [ ? ? ? ? | ? ? U U ]
            packuswb xmm2,xmm2      ; xmm2 = [ ? ? ? ? ? ? ? ? | ? ? ? ? ? ? U U ]
            movq rax, xmm2

            inc rcx
            inc rbx
            mov [r13+rbx], al
            mov al, ah
            mov [r13+rcx], al
            

            ;calculo Y
            movdqu xmm1, [mask_Y]   ; xmm1 = [  66 129 25 128  |  66 129 25 128  ]
                                    ; xmm0 = [  R   G   B   1  |  R   G   B   1  ]
            pmaddwd xmm1, xmm0      ; xmm1 = [ 66*R+129*G 25*B+128 | 66*R+129*G 25*B+128 ]
            phaddd xmm1, xmm1       ; xmm1 = [ xxx xxx |  (66*R+129*G+25*B+128)  (66*R+129*G+25*B+128) ]
            psrld xmm1, 8           ; xmm1 >> 8 (dword)
            movdqu xmm9, [add_y]    ; xmm9 = [ 16 16 16 16 ]
            paddd xmm1, xmm9        ; xmm1 = [ ? ? (16+Y) (16+Y) ]
            packusdw xmm1,xmm1      ; xmm1 = [ ? ? ? ? | ? ? Y Y ]
            packuswb xmm1,xmm1      ; xmm1 = [ ? ? ? ? ? ? ? ? | ? ? ? ? ? ? Y Y ]
            movq rax, xmm1

            inc rcx
            inc rbx
            mov [r13+rbx], al
            mov al, ah
            mov [r13+rcx], al

            ; incremento rcx para que pase al nuevo pixel
            inc rcx
            mov rbx, rcx
            jmp .ciclo

        .fin:
            ; Desencolo
            pop r15
            pop r14
            pop r13
            pop r12
            pop rbx
            pop rbp
    ret