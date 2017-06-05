%define offset_ARGB 4

global ASM_convertYUVtoRGB
global ASM_convertRGBtoYUV
extern C_convertYUVtoRGB
extern C_convertRGBtoYUV

section .rodata 

    soloU: dd 0xffff0000, 0x00000000, 0xffff0000, 0x00000000
    soloV: dd 0xffff0000, 0x00000000, 0xffff0000, 0x00000000
    soloY: dd 0xffff0000, 0x00000000, 0xffff0000, 0x00000000

    val128: dd 0, 128, 0, 0
    val16: 	dd 0, 16, 0, 0
    val298: dd 0, 298, 0, 0
    val516: dd 0, 516, 0, 0
    val100: dd 0, 100, 0, 0
    val208: dd 0, 208, 0, 0
    val409: dd 0, 409, 0, 0

    soloG: dd 0xffff0000, 0x00000000, 0xffff0000, 0x00000000
    soloB: dd 0xffff0000, 0x00000000, 0xffff0000, 0x00000000
    soloR: dd 0xffff0000, 0x00000000, 0xffff0000, 0x00000000

    val66:		dw 0, 66, 0, 0, 0, 66, 0, 0
    val129: 	dw 0, 129, 0, 0, 0, 129, 0, 0
    val25: 		dw 0, 25, 0, 0, 0, 25, 0, 0
    val16word: 	dw 0, 16, 0, 0, 0, 16, 0, 0
    val38: 		dw 0, 38, 0, 0, 0, 38, 0, 0
    val74: 		dw 0, 74, 0, 0, 0, 74, 0, 0
    val112: 	dw 0, 112, 0, 0, 0, 112, 0, 0
    val94: 		dw 0, 94, 0, 0, 0, 94, 0, 0
    val18: 		dw 0, 18, 0, 0, 0, 18, 0, 0
    val128word: dw 0, 128, 0, 0, 0, 128, 0, 0

section .text

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
            punpcklbw xmm1, xmm0    ;xmm1=[A V U Y | A2 V2 U2 Y2]
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
    ; rsi -> srcw   		(uint32_t)
    ; rdx -> srch   		(uint32_t)
    ; rcx -> puntero dst    (uint8_t)
    ; r8 -> dstw    		(uint32_t)
    ; r9 -> dsth    		(uint32_t)

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
            cmp rbx, r14
            je .fin

            xorps xmm0, xmm0
            movq xmm1, [r12+rbx]
            punpcklbw xmm1, xmm0    ;xmm1=[A B G R | A2 B2 G2 R2]
            movdqu xmm2, xmm1
            movdqu xmm3, xmm1
            
        ;solo B
            pand xmm1, [soloB]      ;xmm1=[0 B 0 0 | 0 B2 0 0]

        ;solo G
            psrldq xmm2, 2
            pand xmm2, [soloG]      ;xmm2=[0 G 0 0 | 0 G2 0 0]
           
        ;solo R
            psrldq xmm3, 4
            pand xmm3, [soloR]      ;xmm3=[0 R 0 0 | 0 R2 0 0]

        ;obtengo Y
            movdqu xmm12, xmm3         
            pmullw xmm12, [val66]	;xmm12=[0 66*R 0 0 | 0 66*R2 0 0]

            movdqu xmm10, xmm2
            pmullw xmm10, [val129]	;xmm10=[0 129*G 0 0 | 0 129*G2 0 0]

            movdqu xmm14, xmm1
            pmullw xmm14, [val25]	;xmm14=[0 25*B 0 0 | 0 25*B2 0 0]
         
            paddw xmm12, xmm10
            paddw xmm12, xmm14	
            paddw xmm12, [val128word]
            psraw xmm12, 8
            paddw xmm12, [val16word] ;xmm12=[0 nuevoY 0 0 | 0 nuevoY2 0 0]

        ;obtengo U
            movdqu xmm7, xmm3      
            pmullw xmm7, [val38]	;xmm7=[0 38*R 0 0 | 0 38*R2 0 0]

            movdqu xmm10, xmm2
            pmullw xmm10, [val74]	;xmm10=[0 74*G 0 0 | 0 74*G2 0 0]

            movdqu xmm14, xmm1
            pmullw xmm14, [val112]	;xmm14=[0 112*B 0 0 | 0 112*B 0 0]

            psubw xmm14, xmm10
            psubw xmm14, xmm7	
            paddw xmm14, [val128word]
            psraw xmm14, 8
            paddw xmm14, [val128word] 	;xmm14=[0 nuevoU 0 0 | 0 nuevoU2 0 0]

        ;obtengo V     
            pmullw xmm3, [val112]	;xmm3=[0 112*R 0 0 | 0 112*R2 0 0]

            movdqu xmm10, xmm2
            pmullw xmm10, [val94]	;xmm10=[0 94*G 0 0 | 0 94*G 0 0]

            movdqu xmm7, xmm1
            pmullw xmm7, [val18]	;xmm7=[0 18*B 0 0 | 0 18*B 0 0]

            psubw xmm3, xmm10
            psubw xmm3, xmm7	
            paddw xmm3, [val128word]
            psraw xmm3, 8
            paddw xmm3, [val128word] 	;xmm3=[0 nuevoV 0 0 | 0 nuevoV2 0 0]

        ;acomodo Y
            packuswb xmm12, xmm0 	;xmm12=[---- | ---- | 0 nuevoY 0 0 | 0 nuevoY2 0 0]

        ;acomodo U   
            packuswb xmm14, xmm0 	;xmm14=[---- | ---- | 0 0 nuevoU 0 | 0 0 nuevoU2 0]
            pslldq xmm14, 1 

        ;acomodo V
            packuswb xmm3, xmm0 	;xmm3=[---- | ---- | 0 0 0 nuevoV | 0 0 0 nuevoV2]
            pslldq xmm3, 2

        ;junto todo
            por xmm3, xmm14
            por xmm3, xmm12         ;xmm3=[---- | ---- | 0 nuevoY nuevoU nuevoV | 0 nuevoY2 nuevoU2 nuevoV2]

        ;muevo el dato a la nueva imagen
            movq [r13+rbx], xmm3

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