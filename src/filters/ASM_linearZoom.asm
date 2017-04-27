global ASM_linearZoom
extern C_linearZoom

ASM_linearZoom:
	push    rbp
	mov     rbp, rsp

	call    C_linearZoom

	pop     rbp
	ret