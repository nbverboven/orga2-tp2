%define tamanio_pixel 4

global ASM_maxCloser
extern C_maxCloser

; rdi   -> puntero src      (uint8_t)
; rsi   -> srcw             (uint32_t)
; rdx   -> srch             (uint32_t)
; rcx   -> puntero dst      (uint8_t)
; r8    -> dstw             (uint32_t)
; r9    -> dsth             (uint32_t)
; xmm0  -> val              (float)

    section .rodata

    blanco: dd 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff

    section .text

ASM_maxCloser:

        push rbx
        push r12
        push r13
        push r14
        push r15
        ; Pila alineada

        mov r12, rdi    ;r12 -> puntero imagen src 
        mov r13, rdx    ;r13 -> srch  
        mov r9, 4 

        mov rax, r13
        mul rsi
        mul r9
        mov r14, rax     ;r14 -> 4*srcw*srch 

        mov rax, rsi
        mul r9
        mov r8, rax     ;r8 -> 4*srcw

        xorps xmm15, xmm15
        xor r15, r15
        inc r15
        cvtsi2ss xmm15, r15
        subps xmm15, xmm0            
        pshufd xmm15, xmm15, 0x00  ;xmm15 -> [1-Val | 1-Val | 1-Val | 1-Val] 

        movdqu xmm14, xmm0          
        pshufd xmm14, xmm14, 0x00   ;xmm14 -> [Val | Val | Val | Val]

        xor rbx, rbx    ;rbx -> contador posicion global

    .ciclo:
        cmp rbx, r14
        jge .fin

        mov rdi, rbx
        mov rdx, r13
        call in_range       ;Me fijo si estoy en el margen de 3 pixeles
        cmp rax, 0
        je .pintarBlanco    ;Si estoy en el margen pinto el pixel de blanco
        mov rax, -3             
        mul r8              ;rax -> -3*srcw*4 Esquina inferior izquierda del kernel de 7x7

    ;busco maximo    
        add rax, rbx         ;r8 -> posicion columna
        sub rax, 12
        movdqu xmm0, [r12+rax]      ;xmm0 -> [kernel[0][3] | kernel[0][2] | kernel[0][1] | kernel[0][0]]
        movdqu xmm1, [r12+rax+12]   ;xmm1 -> [kernel[0][6] | kernel[0][5] | kernel[0][4] | kernel[0][3]]

        add rax, r8                 ;rax -> -2*srcw
        movdqu xmm2, [r12+rax]      ;xmm2 -> [kernel[1][3] | kernel[1][2] | kernel[1][1] | kernel[1][0]]
        movdqu xmm3, [r12+rax+12]   ;xmm3 -> [kernel[1][6] | kernel[1][5] | kernel[1][4] | kernel[1][3]]

        add rax, r8                 ;rax -> -1*srcw
        movdqu xmm4, [r12+rax]      ;xmm4 -> [kernel[2][3] | kernel[2][2] | kernel[2][1] | kernel[2][0]]
        movdqu xmm5, [r12+rax+12]   ;xmm5 -> [kernel[2][6] | kernel[2][5] | kernel[2][4] | kernel[2][3]]

        add rax, r8                 ;rax -> 0*srcw
        movdqu xmm6, [r12+rax]      ;xmm6 -> [kernel[3][3] | kernel[3][2] | kernel[3][1] | kernel[3][0]]
        movdqu xmm7, [r12+rax+12]   ;xmm7 -> [kernel[3][6] | kernel[3][5] | kernel[3][4] | kernel[3][3]]

        add rax, r8                 ;rax -> 1*srcw
        movdqu xmm8, [r12+rax]      ;xmm8 -> [kernel[4][3] | kernel[4][2] | kernel[4][1] | kernel[4][0]]
        movdqu xmm9, [r12+rax+12]   ;xmm9 -> [kernel[4][6] | kernel[4][5] | kernel[4][4] | kernel[4][3]]

        add rax, r8                 ;rax -> 2*srcw
        movdqu xmm10, [r12+rax]     ;xmm10 -> [kernel[5][3] | kernel[5][2] | kernel[5][1] | kernel[5][0]]
        movdqu xmm11, [r12+rax+12]  ;xmm11 -> [kernel[5][6] | kernel[5][5] | kernel[5][4] | kernel[5][3]]

        add rax, r8                 ;rax -> 3*srcw
        movdqu xmm12, [r12+rax]     ;xmm12 -> [kernel[6][3] | kernel[6][2] | kernel[6][1] | kernel[6][0]]
        movdqu xmm13, [r12+rax+12]  ;xmm13 -> [kernel[6][6] | kernel[6][5] | kernel[6][4] | kernel[6][3]]

        pmaxub xmm0, xmm1
        pmaxub xmm0, xmm2
        pmaxub xmm0, xmm3
        pmaxub xmm0, xmm4
        pmaxub xmm0, xmm5
        pmaxub xmm0, xmm6
        pmaxub xmm0, xmm7
        pmaxub xmm0, xmm8
        pmaxub xmm0, xmm9
        pmaxub xmm0, xmm10
        pmaxub xmm0, xmm11
        pmaxub xmm0, xmm12
        pmaxub xmm0, xmm13

        movdqu xmm1, xmm0
        movdqu xmm2, xmm0
        movdqu xmm3, xmm0
        psrldq xmm1, 4
        psrldq xmm2, 8
        psrldq xmm3, 12
        pmaxub xmm0, xmm1
        pmaxub xmm0, xmm2
        pmaxub xmm0, xmm3       ;xmm0 -> [---- | ---- | ---- | maxRGBA]

    ;opero con el maximo
        xorps xmm1, xmm1
        punpcklbw xmm0, xmm1
        punpcklwd xmm0, xmm1    ;xmm0= [maxR | maxG | maxB | ----]
        cvtdq2ps xmm0, xmm0
        mulps xmm0, xmm14        ;xmm0= [Val*maxR | Val*maxG | Val*maxB | ----]

        xorps xmm2, xmm2
        movd xmm2, [r12+rbx]
        punpcklbw xmm2, xmm1
        punpcklwd xmm2, xmm1    ;xmm2= [R | G | B | A]
        cvtdq2ps xmm2, xmm2
        mulps xmm2, xmm15        ;xmm2= [(1-Val)*R | (1-Val)*G | (1-Val)*B | ----]

        addps xmm0, xmm2        ;xmm0= [(1-Val)*R+Val*maxR | (1-Val)*G+Val*maxG | (1-Val)*B+Val*maxB | ----]

        cvtps2dq xmm0, xmm0
        packusdw xmm0, xmm1
        packuswb xmm0, xmm1

    ;muevo el nuevo pixel a la imagen destino
        movd [rcx+rbx], xmm0  

        add rbx, 4
        jmp .ciclo

    .pintarBlanco:
        movd xmm0, [blanco]
        movd [rcx+rbx], xmm0
        add rbx, 4
        jmp .ciclo


    .fin:
        ; Desencolo
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx

ret

global in_range
in_range:
        push r12
        push r13
        push r14
        push r15

        push rcx

        mov r14, rsi    ;r14 -> srcw
        mov rcx, 4
        mov r15, rdx    ;r15 -> srch

        xor rdx, rdx
        xor rax, rax

        mov rax, rdi    ;rdi -> posicion en la imagen*4
        div rcx
                        ;rax = rbx/4 -> pixel actual 

        div r14
        mov r12, rax    ;r12 = (rbx/4)/srcw -> fila en la que estoy parado
        mov r13, rdx    ;r13 -> columna actual

        cmp r12, 3
        jl .esBorde     ;Me fijo si estoy en el borde de arriba

        cmp r13, 3
        jl .esBorde     ;Me fijo si estoy en el borde izquierdo

        sub r15, r12
        cmp r15, 4
        jl .esBorde     ;Me fijo si estoy en el borde de abajo

        sub r14, rdx    
        cmp r14, 4
        jl .esBorde     ;Me fijo si estoy en el borde de la derecha

        mov rax, 1
        jmp .fin        

    .esBorde:
        mov rax, 0

    .fin:
        pop rcx
        pop r15
        pop r14
        pop r13
        pop r12
ret

;EXPERIMENTO
;     ASM_maxCloser:

;         push rbx
;         push r12
;         push r13
;         push r14
;         push r15
;         ; Pila alineada

;         mov r12, rdi    ;r12 -> puntero imagen src 
;         mov r13, rdx    ;r13 -> srch  
;         mov r9, 4       ;r9 -> 4

;         mov rax, r13
;         mul rsi
;         mul r9
;         mov r14, rax     ;r14 -> 4*srcw*srch 

;         mov rax, rsi
;         mul r9
;         mov r8, rax     ;r8 -> 4*srcw

;         xorps xmm15, xmm15
;         xor r15, r15
;         inc r15
;         cvtsi2ss xmm15, r15
;         subps xmm15, xmm0            
;         pshufd xmm15, xmm15, 0x00  ;xmm15 -> [1-Val | 1-Val | 1-Val | 1-Val] 

;         movdqu xmm14, xmm0          
;         pshufd xmm14, xmm14, 0x00   ;xmm14 -> [Val | Val | Val | Val]

;         xor rbx, rbx    ;rbx -> contador posicion global
;         xor r11, r11    ;fila global
;         xor r15, r15
;         mov r10, -1    ;posicion kernel

;     .ciclo:
;         cmp rbx, r14
;         jge .fin

;         mov rdi, rbx
;         mov rdx, r13
;         call in_range       ;Me fijo si estoy en el margen de 3 pixeles
;         cmp rax, 0
;         je .pintarBlanco    ;Si estoy en el margen pinto el pixel de blanco
;         cmp r10, -1
;         je .armoKernelEntero
;         jmp .actualizarPosiciones

;     .armoKernelEntero:
;         mov rax, -3             
;         mul r8                      ;rax -> -3*srcw*4 Esquina inferior izquierda del kernel de 7x7    
;         add rax, rbx                ;r8 -> posicion columna
;         sub rax, 12
;         mov r15, rax
;         movdqu xmm0, [r12+r15]      ;xmm0 -> [kernel[0][3] | kernel[0][2] | kernel[0][1] | kernel[0][0]]
;         movdqu xmm1, [r12+r15+12]   ;xmm1 -> [kernel[0][6] | kernel[0][5] | kernel[0][4] | kernel[0][3]]
;         pmaxub xmm0, xmm1

;         add r15, r8                 ;r15 -> -2*srcw
;         movdqu xmm1, [r12+r15]      ;xmm1 -> [kernel[1][3] | kernel[1][2] | kernel[1][1] | kernel[1][0]]
;         movdqu xmm2, [r12+r15+12]   ;xmm2 -> [kernel[1][6] | kernel[1][5] | kernel[1][4] | kernel[1][3]]
;         pmaxub xmm1, xmm2

;         add r15, r8                 ;r15 -> -1*srcw
;         movdqu xmm2, [r12+r15]      ;xmm2 -> [kernel[2][3] | kernel[2][2] | kernel[2][1] | kernel[2][0]]
;         movdqu xmm3, [r12+r15+12]   ;xmm3 -> [kernel[2][6] | kernel[2][5] | kernel[2][4] | kernel[2][3]]
;         pmaxub xmm2, xmm3

;         add r15, r8                 ;r15 -> 0*srcw
;         movdqu xmm3, [r12+r15]      ;xmm3 -> [kernel[3][3] | kernel[3][2] | kernel[3][1] | kernel[3][0]]
;         movdqu xmm4, [r12+r15+12]   ;xmm4 -> [kernel[3][6] | kernel[3][5] | kernel[3][4] | kernel[3][3]]
;         pmaxub xmm3, xmm4

;         add r15, r8                 ;r15 -> 1*srcw
;         movdqu xmm4, [r12+r15]      ;xmm4 -> [kernel[4][3] | kernel[4][2] | kernel[4][1] | kernel[4][0]]
;         movdqu xmm5, [r12+r15+12]   ;xmm5 -> [kernel[4][6] | kernel[4][5] | kernel[4][4] | kernel[4][3]]
;         pmaxub xmm4, xmm5

;         add r15, r8                 ;r15 -> 2*srcw
;         movdqu xmm5, [r12+r15]      ;xmm5 -> [kernel[5][3] | kernel[5][2] | kernel[5][1] | kernel[5][0]]
;         movdqu xmm6, [r12+r15+12]   ;xmm6 -> [kernel[5][6] | kernel[5][5] | kernel[5][4] | kernel[5][3]]
;         pmaxub xmm5, xmm6

;         add r15, r8                 ;r15 -> 3*srcw
;         movdqu xmm6, [r12+r15]      ;xmm6 -> [kernel[6][3] | kernel[6][2] | kernel[6][1] | kernel[6][0]]
;         movdqu xmm7, [r12+r15+12]   ;xmm7 -> [kernel[6][6] | kernel[6][5] | kernel[6][4] | kernel[6][3]]
;         pmaxub xmm6, xmm7

;         inc r10
;         jmp .buscoMaximo

;     .cambio0:
;         add r15, r8
;         movdqu xmm0, [r12+r15]
;         movdqu xmm7, [r12+r15+12]
;         pmaxub xmm0, xmm7
;         inc r10
;         jmp .buscoMaximo

;     .cambio1:
;         add r15, r8
;         movdqu xmm1, [r12+r15]
;         movdqu xmm8, [r12+r15+12]
;         pmaxub xmm1, xmm8
;         inc r10
;         jmp .buscoMaximo

;     .cambio2:
;         add r15, r8
;         movdqu xmm2, [r12+r15]
;         movdqu xmm9, [r12+r15+12]
;         pmaxub xmm2, xmm9
;         inc r10
;         jmp .buscoMaximo

;     .cambio3:
;         add r15, r8
;         movdqu xmm3, [r12+r15]
;         movdqu xmm10, [r12+r15+12]
;         pmaxub xmm3, xmm10
;         inc r10
;         jmp .buscoMaximo

;     .cambio4:
;         add r15, r8
;         movdqu xmm4, [r12+r15]
;         movdqu xmm11, [r12+r15+12]
;         pmaxub xmm4, xmm11
;         inc r10
;         jmp .buscoMaximo

;     .cambio5:
;         add r15, r8
;         movdqu xmm5, [r12+r15]
;         movdqu xmm12, [r12+r15+12]
;         pmaxub xmm5, xmm12
;         inc r10
;         jmp .buscoMaximo

;     .cambio6:
;         add r15, r8
;         movdqu xmm6, [r12+r15]
;         movdqu xmm13, [r12+r15+12]
;         pmaxub xmm6, xmm13
;         xor r10, r10

;     .buscoMaximo:
;         movdqu xmm7, xmm0

;         pmaxub xmm7, xmm1
;         pmaxub xmm7, xmm2
;         pmaxub xmm7, xmm3
;         pmaxub xmm7, xmm4
;         pmaxub xmm7, xmm5
;         pmaxub xmm7, xmm6

;         movdqu xmm8, xmm7
;         movdqu xmm9, xmm7
;         movdqu xmm10, xmm7
;         psrldq xmm8, 4
;         psrldq xmm9, 8
;         psrldq xmm10, 12
;         pmaxub xmm7, xmm8
;         pmaxub xmm7, xmm9
;         pmaxub xmm7, xmm10       ;xmm7 -> [---- | ---- | ---- | maxRGBA]

;     ;opero con el maximo
;         xorps xmm8, xmm8
;         punpcklbw xmm7, xmm8
;         punpcklwd xmm7, xmm8    ;xmm7= [maxR | maxG | maxB | ----]
;         cvtdq2ps xmm7, xmm7
;         mulps xmm7, xmm14        ;xmm7= [Val*maxR | Val*maxG | Val*maxB | ----]

;         xorps xmm9, xmm9
;         movd xmm9, [r12+rbx]
;         punpcklbw xmm9, xmm8
;         punpcklwd xmm9, xmm8    ;xmm9= [R | G | B | A]
;         cvtdq2ps xmm9, xmm9
;         mulps xmm9, xmm15        ;xmm9= [(1-Val)*R | (1-Val)*G | (1-Val)*B | ----]

;         addps xmm7, xmm9        ;xmm9= [(1-Val)*R+Val*maxR | (1-Val)*G+Val*maxG | (1-Val)*B+Val*maxB | ----]

;         cvtps2dq xmm7, xmm7
;         packusdw xmm7, xmm8
;         packuswb xmm7, xmm8

;     ;muevo el nuevo pixel a la imagen destino
;         movd [rcx+rbx], xmm7  

;     ;actualizo indices
;         add rbx, r8
;         inc r11
;         jmp .ciclo

;     .pintarBlanco:
;         movd xmm11, [blanco]
;         movd [rcx+rbx], xmm11
;         add rbx, r8
;         inc r11
;         cmp r11, r13
;         je .actualizoIndiceFila
;         jmp .ciclo

;     .actualizarPosiciones:
;         cmp r10, 0
;         je .cambio0
;         cmp r10, 1
;         je .cambio1
;         cmp r10, 2
;         je .cambio2
;         cmp r10, 3
;         je .cambio3
;         cmp r10, 4
;         je .cambio4
;         cmp r10, 5
;         je .cambio5
;         cmp r10, 6
;         je .cambio6

;     .actualizoIndiceFila:
;         xor r11, r11
;         add rbx, 4
;         sub rbx, r14 ;paso a la siguiente columna
;         mov r10, -1
;         jmp .ciclo

;     .fin:
;         ; Desencolo
;         pop r15
;         pop r14
;         pop r13
;         pop r12
;         pop rbx

; ret
