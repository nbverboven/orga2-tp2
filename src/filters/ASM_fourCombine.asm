%define offset_ARGB 4
%define offset_ARGB_A 0
%define offset_ARGB_R 3
%define offset_ARGB_G 2
%define offset_ARGB_B 1

global ASM_fourCombine
extern C_fourCombine

/**         ********    ATENCION!!     ********
    Esta funcion esta siendo desarrollada por Federico.
    En otras palbras, la modificas y te cago a trompadas.
    Puto el que lee
**/

; rdi -> puntero src    (uint8_t)
; rsi -> puntero srcw   (uint32_t)
; rdx -> puntero srch   (uint32_t)
; rcx -> puntero dst    (uint8_t)
; r8 -> puntero dstw    (uint32_t)
; r9 -> puntero dsth    (uint32_t)

ASM_fourCombine:

		push rbp
        mov rbp, rsp
        push rbx
        push r12
        push r13
        push r14
        push r15
        ; Pila alineada

        mov r12, rdi    ;r12= puntero src
        mov r13, rdi    ;r13= puntero dst

        xor rax,rax
        mov eax, [rsi]  ;eax= srcw
        mov edx, [rdx]  ;edx= srch
        mul edx         ;rax= srcw*srch
        mov edx, offset_ARGB
        mul edx         ;rax= srcw*srch*4
        mov r14, rax    ;r14= srcw*srch*4 Es la cantidad de bytes de la imagen



        .fin:
        ; Desencolo
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

ret