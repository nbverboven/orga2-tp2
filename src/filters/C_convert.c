/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion convertRGBtoYUV y convertYUVtoRGB          */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

void C_convertRGBtoYUV(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {

	uint8_t *A, B, G, R, *V, *U, *Y; 
	
		uint32_t j = 0;
		while(j < 4*srch*srcw){

			B = *(src+j+1);
			G = *(src+j+2);
			R = *(src+j+3);

			A = dst+j;
			V = dst+j+1;
			U = dst+j+2;
			Y = dst+j+3;

			*A = *(src+j); // La componente A se mantiene igual
			*Y = fmin((((66 * R + 129 * G + 25 * B + 128) >> 8) + 16),255);
			*U = fmax(fmin((((-38 * R - 74 * G + 112 * B + 128) >> 8) + 128),255),0);
			*V = fmax(fmin((((112 * R - 94 * G - 18 * B + 128) >> 8) + 128),255),0);

			j += 4;
		}
}

void C_convertYUVtoRGB(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {

	uint8_t *A, *B, *G, *R, V, U, Y; 

		uint32_t j = 0;
		while(j < 4*srch*srcw){

			V = *(src+j+1);
			U = *(src+j+2);
			Y = *(src+j+3);

			A = dst+j;
			B = dst+j+1;
			G = dst+j+2;
			R = dst+j+3;

			*A = *(src+j); // La componente A se mantiene igual
			*R = fmax(fmin(((298 * (Y - 16) + 409 * (V - 128) + 128) >> 8),255),0);
			*G = fmax(fmin(((298 * (Y - 16) - 100 * (U - 128) - 208 * (V - 128) + 128) >> 8),255),0);
			*B = fmax(fmin(((298 * (Y - 16) + 516 * (U - 128) + 128) >> 8),255),0);

			j += 4;
		}
}
