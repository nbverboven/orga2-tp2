%define saturacion_max dw 255, 255, 255, 255
%define saturacion_min dw 0, 0, 0, 0
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
    mask_Y: dw 0, 25, 129, 66, 0, 25, 129, 66
    mask_U: dw 0, 112, -74, -38, 0, 112, -74, -38
    mask_V: dw 0, -18, -94, 112, 0, -18, -94, 112

    add_y: dd 16, 16, 16, 16
    add_u: dd 128, 128, 128, 128
    add_v: dd 128, 128, 128, 128

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
            
            pmovzxbw xmm0, [r12+rbx]  ; xmm0 = [ pixel[1][1] | pixel[1][2] ]
            ; Estoy moviendo 2 pixeles,1 pixel = 4 bits (ARGB)

            ;uso rcx para operar con el segundo pixel
            mov rcx, rbx
            add rcx, 4
            ;copio A dado que sigue igual
            mov al, [r12+rbx]
            mov [r13+rbx], al   ;A primer pixel
            mov [r13+rcx], al   ;A segundo pixel

            ;calculo v
            movdqu xmm3, [mask_V]   ; xmm3 = [ 0 -18 -94 112 ]
            pmaddwd xmm3, xmm0      ; xmm3 = [ (0*A+B*112) (-74)*G+R*(-38) ]
            phaddd xmm3, xmm3       ; xmm3 = [ xxx xxx |  ((0*A+B*112)+(-74)*G+R*(-38))  ((0*A+B*112)+(-74)*G+R*(-38)) ]
            psrld xmm3, 8           ; xmm3 >> 8 (dword)
            movdqu xmm11, [add_v]   ; xmm11 = [ 128 128 128 128 ]
            paddd xmm3, xmm11       ; xmm3 = [ ? ? (128+V) (128+V) ]
            packssdw xmm3,xmm3      ; xmm3 = [ ? ? ? ? | ? ? V V ]
            packsswb xmm3,xmm3      
            movq rax, xmm3

            inc rcx
            inc rbx
            mov [r13+rbx], al
            mov al, ah
            mov [r13+rcx], al


            ;calculo U
            movdqu xmm2, [mask_U]   ; xmm2 = [ 0 112 -74 -38 ]
            pmaddwd xmm2, xmm0      ; xmm2 = [ (0*A+B*112) ((-74)*G+R*(-38)) ]
            phaddd xmm2, xmm2       ; xmm2 = [ xxx xxx |  ((0*A+B*25)+(129*G+R*66))  ((0*A+B*25)+(129*G+R*66)) ]
            psrld xmm2, 8           ; xmm2 >> 8 (dword)
            movdqu xmm10, [add_u]   ; xmm10 = [ 128 128 128 128 ]
            paddd xmm2, xmm10       ; xmm2 = [ ? ? (128+Y) (128+U) ]
            packssdw xmm2,xmm2      ; xmm2 = [ ? ? ? ? | ? ? U U ]
            packsswb xmm2,xmm2      
            movq rax, xmm2

            inc rcx
            inc rbx
            mov [r13+rbx], al
            mov al, ah
            mov [r13+rcx], al
            

            ;calculo Y
            movdqu xmm1, [mask_Y]   ; xmm1 = [ 0 25 129 66 | 0 25 129 66 ]
                                    ; xmm0 = [ A  B  G  R  | A  B  G  R  ]
            pmaddwd xmm1, xmm0      ; xmm1 = [ (0*A+B*25) (129*G+R*66) | (0*A+B*25) (129*G+R*66) ]
            phaddd xmm1, xmm1       ; xmm1 = [ xxx xxx |  ((0*A+B*25)+(129*G+R*66))  ((0*A+B*25)+(129*G+R*66)) ]
            psrld xmm1, 8           ; xmm1 >> 8 (dword)
            movdqu xmm9, [add_y]    ; xmm9 = [ 16 16 16 16 ]
            paddd xmm1, xmm9        ; xmm1 = [ ? ? (16+Y) (16+Y) ]
            packssdw xmm1,xmm1      ; xmm1 = [ ? ? ? ? | ? ? Y Y ]
            packsswb xmm1,xmm1      
            movq rax, xmm1

            inc rcx
            inc rbx
            mov [r13+rbx], al
            mov al, ah
            mov [r13+rcx], al

            ;seteo YUV
            ;movq [r13+rbx], xmm0

            ;add rbx, 8   ; rbx += 8 (porque son 2 pixeles, 4bits x pixel)
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