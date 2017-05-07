%define saturacion_max 255
%define saturacion_min 0
%define offset_ARGB 4
%define offset_ARGB_A 0
%define offset_ARGB_R 3
%define offset_ARGB_G 2
%define offset_ARGB_B 1

global ASM_convertYUVtoRGB
global ASM_convertRGBtoYUV
extern C_convertYUVtoRGB
extern C_convertRGBtoYUV

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

        movdqu xmm0, [r12+rbx]  ; xmm0 = [pixel[1][1] | pixel[1][2] | pixel[1][3] | pixel[1][4]]

        movdqu [r13+rbx], xmm0
        



        add rbx, 8   ; rbx += 4
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