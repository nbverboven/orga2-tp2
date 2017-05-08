/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion fourCombine                                */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

void C_fourCombine(uint8_t* src, uint32_t srcw, uint32_t srch,
                   uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {

uint32_t i = 0;
uint32_t j = srcw*4;
uint32_t k = 0;
uint32_t l = srcw*2;

	while(i < srcw*srch*4 - srcw*4){

		if(i == j){
			i += srcw*4;
			j = i + srcw*4;
		}

		if(k == l){
			k += srcw*2;
			l = k + srcw*2;
		}

		*(dst+k) = *(src+i);
		*(dst+k+1) = *(src+i+1);
		*(dst+k+2) = *(src+i+2);
		*(dst+k+3) = *(src+i+3);

		*(dst+k+2*srcw) = *(src+i+4);
		*(dst+k+2*srcw+1) = *(src+i+4+1);
		*(dst+k+2*srcw+2) = *(src+i+4+2);
		*(dst+k+2*srcw+3) = *(src+i+4+3);

		*(dst+k+2*srcw*srch) = *(src+i+4*srcw);
		*(dst+k+2*srcw*srch+1) = *(src+i+4*srcw+1);
		*(dst+k+2*srcw*srch+2) = *(src+i+4*srcw+2);
		*(dst+k+2*srcw*srch+3) = *(src+i+4*srcw+3);

		*(dst+k+2*srcw+2*srcw*srch) = *(src+i+4*srcw+4);
		*(dst+k+2*srcw+2*srcw*srch+1) = *(src+i+4*srcw+4+1);
		*(dst+k+2*srcw+2*srcw*srch+2) = *(src+i+4*srcw+4+2);
		*(dst+k+2*srcw+2*srcw*srch+3) = *(src+i+4*srcw+4+3);

		i += 8;
		k += 4;
	}
}



                    
                    
                    
                    

                    
                    
                    
                    