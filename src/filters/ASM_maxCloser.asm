global ASM_maxCloser
extern C_maxCloser

;         ********    ATENCION!!     ********
;    Esta funcion esta siendo desarrollada por Federico.
;    En otras palbras, la modificas y te cago a trompadas.
;    Puto el que lee

; rdi 	-> puntero src    	(uint8_t)
; rsi 	-> srcw   			(uint32_t)
; rdx 	-> srch   			(uint32_t)
; rcx 	-> puntero dst    	(uint8_t)
; r8  	-> dstw    			(uint32_t)
; r9  	-> dsth    			(uint32_t)
; xmm0 	-> val				(float)

ASM_maxCloser:

		push rbx
        push r12
        push r13
        push r14
        push r15
        ; Pila alineada

        mov r12, rdi    ;r12= puntero src
        mov r13, rcx    ;r13= puntero dst



        .fin:
        ; Desencolo
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx

ret