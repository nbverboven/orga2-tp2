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
	uint32_t i = 0;
	while(i < 4*srch){ // No se por que si no multiplico por 4 hace solo 1/4 de la imagen

		uint32_t j = 0;
		while(j < srcw){

			B = *(src+srcw*i+j+1);
			G = *(src+srcw*i+j+2);
			R = *(src+srcw*i+j+3);

			A = dst+srcw*i+j;
			V = dst+srcw*i+j+1;
			U = dst+srcw*i+j+2;
			Y = dst+srcw*i+j+3;

			*A = *(src+srcw*i+j); // La componente A se mantiene igual
			*Y = fmin((((66 * R + 129 * G + 25 * B + 128) >> 8) + 16),255);
			*U = fmax(fmin((((-38 * R - 74 * G + 112 * B + 128) >> 8) + 128),255),0);
			*V = fmax(fmin((((112 * R - 94 * G - 18 * B + 128) >> 8) + 128),255),0);

			j += 4;
		}

		i++;	
	}
}

void C_convertYUVtoRGB(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {

	uint8_t *A, *B, *G, *R, V, U, Y; 
	uint32_t i = 0;
	while(i < 4*srch){ // No se por que si no multiplico por 4 hace solo 1/4 de la imagen

		uint32_t j = 0;
		while(j < srcw){

			V = *(src+srcw*i+j+1);
			U = *(src+srcw*i+j+2);
			Y = *(src+srcw*i+j+3);

			A = dst+srcw*i+j;
			B = dst+srcw*i+j+1;
			G = dst+srcw*i+j+2;
			R = dst+srcw*i+j+3;

			*A = *(src+srcw*i+j); // La componente A se mantiene igual
			*R = fmax(fmin(((298 * (Y - 16) + 409 * (V - 128) + 128) >> 8),255),0);
			*G = fmax(fmin(((298 * (Y - 16) - 100 * (U - 128) - 208 * (V - 128) + 128) >> 8),255),0);
			*B = fmax(fmin(((298 * (Y - 16) + 516 * (U - 128) + 128) >> 8),255),0);

			j += 4;
		}

		i++;	
	}
}
