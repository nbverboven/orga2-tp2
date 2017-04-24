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

	uint8_t c1[srcw*srch], c2[srcw*srch], c3[srcw*srch], c4[srcw*srch];
	int j = 0;
	int k = 0;
	int l = 0;
	int m = 0;
	int n = 0;
	uint32_t i = 0;
	while(i < 4*srcw*srch){

		if(fmod(i/(4*srcw),2) == 0){

			c1[j] = *(src+i);
			c1[j+1] = *(src+i+1);
			c1[j+2] = *(src+i+2);
			c1[j+3] = *(src+i+3);
			j += 4;

			c2[k] = *(src+i+4);
			c2[k+1] = *(src+i+5);
			c2[k+2] = *(src+i+6);
			c2[k+3] = *(src+i+7);
			k += 4;
		}else{

			c3[l] = *(src+i);
			c3[l+1] = *(src+i+1);
			c3[l+2] = *(src+i+2);
			c3[l+3] = *(src+i+3);
			l += 4;

			c4[m] = *(src+i+4);
			c4[m+1] = *(src+i+5);
			c4[m+2] = *(src+i+6);
			c4[m+3] = *(src+i+7); 
			m += 4;
		}
		
		i += 8;
	}

	i = 0;
	while(n < 2*srcw*srch){

		m = 0;
		while(m < 2*srcw){

			*(dst+n) = c1[i];
			*(dst+n+1) = c1[i+1];
			*(dst+n+2) = c1[i+2];
			*(dst+n+3) = c1[i+3];
			i += 4;
			n += 4;
			m += 4;
		}

		while(m < 4*srcw){

			*(dst+n) = c2[j];
			*(dst+n+1) = c2[j+1];
			*(dst+n+2) = c2[j+2];
			*(dst+n+3) = c2[j+3];
			j += 4;
			n += 4;
			m += 4;
		}	
	}

	i = 0;
	j = 0;
	while(n < 4*srcw*srch){

		m = 0;
		while(m < 2*srcw){

			*(dst+n) = c3[i];
			*(dst+n+1) = c3[i+1];
			*(dst+n+2) = c3[i+2];
			*(dst+n+3) = c3[i+3];
			i += 4;
			n += 4;
			m += 4;
		}

		while(m < 4*srcw){

			*(dst+n) = c4[j];
			*(dst+n+1) = c4[j+1];
			*(dst+n+2) = c4[j+2];
			*(dst+n+3) = c4[j+3];
			j += 4;
			n += 4;
			m += 4;
		}
 
	}
	
}

                    
                    
                    
                    

                    
                    
                    
                    