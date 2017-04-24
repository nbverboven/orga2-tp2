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
	/*****************************
		Nico está haciendo esto
	******************************/

	uint8_t *img_m_A, *img_m_B, *img_m_G, *img_m_R,
	         img_o_A,  img_o_B,  img_o_G,  img_o_R;

	// Primero copio los pixeles que no se modifican

	uint32_t indice_img_original = 0;
	uint32_t fila_img_modificada = 1;
	uint32_t columna_img_modificada;
	uint32_t indice_img_modificada;

	while ( fila_img_modificada < dsth )
	{
		columna_img_modificada = 0;

		while ( columna_img_modificada < dstw )
		{
			indice_img_modificada = 4*dstw*fila_img_modificada + 4*columna_img_modificada;

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

	uint8_t img_m_ant_A, img_m_ant_B, img_m_ant_G, img_m_ant_R,
	        img_m_sig_A, img_m_sig_B, img_m_sig_G, img_m_sig_R;

	// Ahora voy a agregar los pixeles que están entre dos de los originales (recorro filas)

	uint32_t indice_img_modificada_anterior;
	uint32_t indice_img_modificada_siguiente;

	fila_img_modificada = 1;

	while ( fila_img_modificada < dsth )
	{
		columna_img_modificada = 1;

		while ( columna_img_modificada < dstw )
		{
			indice_img_modificada = 4*dstw*fila_img_modificada + 4*columna_img_modificada;
			indice_img_modificada_anterior = 4*dstw*fila_img_modificada + (4*columna_img_modificada - 1);
			indice_img_modificada_siguiente = 4*dstw*fila_img_modificada + (4*columna_img_modificada + 1);

			img_m_ant_A = *(dst + indice_img_modificada_anterior + A32);
			img_m_ant_B = *(dst + indice_img_modificada_anterior + B32);
			img_m_ant_G = *(dst + indice_img_modificada_anterior + G32);
			img_m_ant_R = *(dst + indice_img_modificada_anterior + R32);

			img_m_sig_A = *(dst + indice_img_modificada_siguiente + A32);
			img_m_sig_B = *(dst + indice_img_modificada_siguiente + B32);
			img_m_sig_G = *(dst + indice_img_modificada_siguiente + G32);
			img_m_sig_R = *(dst + indice_img_modificada_siguiente + R32);

			img_m_A = dst + indice_img_modificada + A32;
			img_m_B = dst + indice_img_modificada + B32;
			img_m_G = dst + indice_img_modificada + G32;
			img_m_R = dst + indice_img_modificada + R32;

			img_m_A = ( img_m_ant_A + img_m_sig_A ) >> 2;
			img_m_B = ( img_m_ant_B + img_m_sig_B ) >> 2;
			img_m_G = ( img_m_ant_G + img_m_sig_G ) >> 2;
			img_m_R = ( img_m_ant_R + img_m_sig_R ) >> 2;

			columna_img_modificada += 2;
		}

		fila_img_modificada += 2;
	}

	// Ahora voy a agregar los pixeles que están entre dos de los originales (recorro columnas)

	columna_img_modificada = 0;

	while ( columna_img_modificada < dstw )
	{
		fila_img_modificada = 1;

		while ( fila_img_modificada < dsth )
		{
			indice_img_modificada = 4*dstw*fila_img_modificada + 4*columna_img_modificada;
			indice_img_modificada_anterior = (4*dstw*fila_img_modificada - 1) + 4*columna_img_modificada;
			indice_img_modificada_siguiente = (4*dstw*fila_img_modificada + 1) + 4*columna_img_modificada;

			img_m_ant_A = *(dst + indice_img_modificada_anterior + A32);
			img_m_ant_B = *(dst + indice_img_modificada_anterior + B32);
			img_m_ant_G = *(dst + indice_img_modificada_anterior + G32);
			img_m_ant_R = *(dst + indice_img_modificada_anterior + R32);

			img_m_sig_A = *(dst + indice_img_modificada_siguiente + A32);
			img_m_sig_B = *(dst + indice_img_modificada_siguiente + B32);
			img_m_sig_G = *(dst + indice_img_modificada_siguiente + G32);
			img_m_sig_R = *(dst + indice_img_modificada_siguiente + R32);

			img_m_A = dst + indice_img_modificada + A32;
			img_m_B = dst + indice_img_modificada + B32;
			img_m_G = dst + indice_img_modificada + G32;
			img_m_R = dst + indice_img_modificada + R32;

			img_m_A = ( img_m_ant_A + img_m_sig_A ) >> 2;
			img_m_B = ( img_m_ant_B + img_m_sig_B ) >> 2;
			img_m_G = ( img_m_ant_G + img_m_sig_G ) >> 2;
			img_m_R = ( img_m_ant_R + img_m_sig_R ) >> 2;

			fila_img_modificada += 2;
		}

		columna_img_modificada += 2;
	}
}

