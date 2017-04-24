/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

void C_linearZoom(uint8_t* src, uint32_t srcw, uint32_t srch,
                  uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)))
{
	// Nico está haciendo esto

	uint8_t *img_m_A, *img_m_B, *img_m_G, *img_m_R,
	         img_o_A,  img_o_B,  img_o_G,  img_o_R;

	// Primero copio los valores que no se modifican

	uint32_t indice_img_original = 0;
	uint32_t fila_img_modificada = 0;

	while ( fila_img_modificada < dsth )
	{
		uint32_t columna_img_modificada = 0;

		while ( columna_img_modificada < dstw )
		{
			uint32_t indice_img_modificada = 4*dstw*fila_img_modificada + 4*columna_img_modificada;

			img_o_A = *(src + indice_img_original + A32);
			img_o_B = *(src + indice_img_original + B32);
			img_o_G = *(src + indice_img_original + G32);
			img_o_R = *(src + indice_img_original + R32);

			img_m_A = dst + indice_img_modificada + A32;
			img_m_B = dst + indice_img_modificada + B32;
			img_m_G = dst + indice_img_modificada + G32;
			img_m_R = dst + indice_img_modificada + R32;

			*img_m_A = img_o_A;
			*img_m_B = img_o_B;
			*img_m_G = img_o_G;
			*img_m_R = img_o_R;

			indice_img_original += 4;
			columna_img_modificada += 2;
		}

		fila_img_modificada += 2;
	}
}

