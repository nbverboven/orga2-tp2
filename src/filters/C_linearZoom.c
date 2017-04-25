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

		while ( columna_img_modificada < dstw-1 )
		{
			indice_img_modificada = 4*dstw*fila_img_modificada + 4*columna_img_modificada;
			indice_img_modificada_anterior = 4*dstw*fila_img_modificada + 4*(columna_img_modificada - 1);
			indice_img_modificada_siguiente = 4*dstw*fila_img_modificada + 4*(columna_img_modificada + 1);

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

			// *img_m_A = fmax( fmin( ( img_m_ant_A + img_m_sig_A ) >> 2, 255), 0 );
			*img_m_A = fmax( img_m_ant_A , img_m_sig_A );
			*img_m_B = fmax( fmin( ( img_m_ant_B + img_m_sig_B ) >> 1, 255), 0 );
			*img_m_G = fmax( fmin( ( img_m_ant_G + img_m_sig_G ) >> 1, 255), 0 );
			*img_m_R = fmax( fmin( ( img_m_ant_R + img_m_sig_R ) >> 1, 255), 0 );

			columna_img_modificada += 2;
		}

		fila_img_modificada += 2;
	}

	// Ahora voy a agregar los pixeles que están entre dos de los originales (recorro columnas)

	columna_img_modificada = 0;

	while ( columna_img_modificada < dstw-1 )
	{
		fila_img_modificada = 2;

		while ( fila_img_modificada < dsth )
		{
			indice_img_modificada = 4*dstw*fila_img_modificada + 4*columna_img_modificada;
			indice_img_modificada_anterior = 4*dstw*(fila_img_modificada - 1) + 4*columna_img_modificada;
			indice_img_modificada_siguiente = 4*dstw*(fila_img_modificada + 1) + 4*columna_img_modificada;

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

			//*img_m_A = fmax( fmin( ( img_m_ant_A + img_m_sig_A ) >> 2, 255), 0);
			*img_m_A = fmax( img_m_ant_A , img_m_sig_A );
			*img_m_B = fmax( fmin( ( img_m_ant_B + img_m_sig_B ) >> 1, 255), 0);
			*img_m_G = fmax( fmin( ( img_m_ant_G + img_m_sig_G ) >> 1, 255), 0);
			*img_m_R = fmax( fmin( ( img_m_ant_R + img_m_sig_R ) >> 1, 255), 0);

			fila_img_modificada += 2;
		}

		columna_img_modificada += 2;
	}

	// Agrego los pixeles que están entre cuatro de los originales

	uint32_t img_m_arriba_izq_A, img_m_arriba_izq_B, img_m_arriba_izq_G, img_m_arriba_izq_R,
	         img_m_arriba_der_A, img_m_arriba_der_B, img_m_arriba_der_G, img_m_arriba_der_R,
	         img_m_abajo_izq_A,  img_m_abajo_izq_B,  img_m_abajo_izq_G,  img_m_abajo_izq_R,
	         img_m_abajo_der_A,  img_m_abajo_der_B,  img_m_abajo_der_G,  img_m_abajo_der_R;

	uint32_t indice_img_modificada_arriba_izq;
	uint32_t indice_img_modificada_arriba_der;
	uint32_t indice_img_modificada_abajo_izq;
	uint32_t indice_img_modificada_abajo_der;

	fila_img_modificada = 2;

	while ( fila_img_modificada < dsth )
	{
		columna_img_modificada = 1;

		while ( columna_img_modificada < dstw-1 )
		{
			indice_img_modificada = 4*dstw*fila_img_modificada + 4*columna_img_modificada;
			indice_img_modificada_arriba_izq = 4*dstw*(fila_img_modificada + 1) + 4*(columna_img_modificada - 1);
			indice_img_modificada_arriba_der = 4*dstw*(fila_img_modificada + 1) + 4*(columna_img_modificada + 1);
			indice_img_modificada_abajo_izq = 4*dstw*(fila_img_modificada - 1) + 4*(columna_img_modificada - 1);
			indice_img_modificada_abajo_der = 4*dstw*(fila_img_modificada - 1) + 4*(columna_img_modificada + 1);

			img_m_arriba_izq_A = *(dst + indice_img_modificada_arriba_izq + A32);
			img_m_arriba_izq_B = *(dst + indice_img_modificada_arriba_izq + B32);
			img_m_arriba_izq_G = *(dst + indice_img_modificada_arriba_izq + G32);
			img_m_arriba_izq_R = *(dst + indice_img_modificada_arriba_izq + R32);

			img_m_arriba_der_A = *(dst + indice_img_modificada_arriba_der + A32);
			img_m_arriba_der_B = *(dst + indice_img_modificada_arriba_der + B32);
			img_m_arriba_der_G = *(dst + indice_img_modificada_arriba_der + G32);
			img_m_arriba_der_R = *(dst + indice_img_modificada_arriba_der + R32);

			img_m_abajo_izq_A = *(dst + indice_img_modificada_abajo_izq + A32);
			img_m_abajo_izq_B = *(dst + indice_img_modificada_abajo_izq + B32);
			img_m_abajo_izq_G = *(dst + indice_img_modificada_abajo_izq + G32);
			img_m_abajo_izq_R = *(dst + indice_img_modificada_abajo_izq + R32);

			img_m_abajo_der_A = *(dst + indice_img_modificada_abajo_der + A32);
			img_m_abajo_der_B = *(dst + indice_img_modificada_abajo_der + B32);
			img_m_abajo_der_G = *(dst + indice_img_modificada_abajo_der + G32);
			img_m_abajo_der_R = *(dst + indice_img_modificada_abajo_der + R32);

			img_m_A = dst + indice_img_modificada + A32;
			img_m_B = dst + indice_img_modificada + B32;
			img_m_G = dst + indice_img_modificada + G32;
			img_m_R = dst + indice_img_modificada + R32;

			//*img_m_A = fmax( fmin( ( img_m_arriba_izq_A + img_m_arriba_der_A + img_m_abajo_izq_A + img_m_abajo_der_A ) >> 4, 255), 0);
			*img_m_A =  img_m_arriba_izq_A;//fmax( fmax( ( img_m_arriba_izq_A, img_m_arriba_der_A ), img_m_abajo_izq_A ), img_m_abajo_der_A);
			*img_m_B = fmax( fmin( ( img_m_arriba_izq_B + img_m_arriba_der_B + img_m_abajo_izq_B + img_m_abajo_der_B ) >> 2, 255), 0);
			*img_m_G = fmax( fmin( ( img_m_arriba_izq_G + img_m_arriba_der_G + img_m_abajo_izq_G + img_m_abajo_der_G ) >> 2, 255), 0);
			*img_m_R = fmax( fmin( ( img_m_arriba_izq_R + img_m_arriba_der_R + img_m_abajo_izq_R + img_m_abajo_der_R ) >> 2, 255), 0);

			columna_img_modificada += 2;
		}

		fila_img_modificada += 2;
	}

	// Hago los bordes

	/***********************************
	        ESTO NO ANDAAAAAAAAAAA
	************************************/

	// uint32_t indice_img_modificada_arriba;
	// uint32_t indice_img_modificada_izquierda;

	// columna_img_modificada = 0;

	// while ( columna_img_modificada < dstw )
	// {
	// 	indice_img_modificada = 4*columna_img_modificada;
	// 	indice_img_modificada_arriba = 4*dstw + 4*columna_img_modificada; // Arriba del borde de abajo
	// 	indice_img_modificada_izquierda = 4*dstw*dsth - 4*dstw*columna_img_modificada - 1; // A la izquierda del borde derecho

	// 	img_m_ant_A = *(dst + indice_img_modificada_arriba + A32);
	// 	img_m_ant_B = *(dst + indice_img_modificada_arriba + B32);
	// 	img_m_ant_G = *(dst + indice_img_modificada_arriba + G32);
	// 	img_m_ant_R = *(dst + indice_img_modificada_arriba + R32);

	// 	img_m_sig_A = *(dst + indice_img_modificada_izquierda + A32);
	// 	img_m_sig_B = *(dst + indice_img_modificada_izquierda + B32);
	// 	img_m_sig_G = *(dst + indice_img_modificada_izquierda + G32);
	// 	img_m_sig_R = *(dst + indice_img_modificada_izquierda + R32);

	// 	if ( columna_img_modificada < dstw-1 )
	// 	{
	// 		indice_img_modificada = 4*dstw*dsth - 4*dstw*columna_img_modificada;

	// 		img_m_A = dst + indice_img_modificada + A32;
	// 		img_m_B = dst + indice_img_modificada + B32;
	// 		img_m_G = dst + indice_img_modificada + G32;
	// 		img_m_R = dst + indice_img_modificada + R32;

	// 		// *img_m_A = fmax( fmin( ( img_m_ant_A + img_m_sig_A ) >> 2, 255), 0 );
	// 		*img_m_A = img_m_ant_A,
	// 		*img_m_B = fmax( fmin( img_m_ant_B, 255), 0 );
	// 		*img_m_G = fmax( fmin( img_m_ant_G, 255), 0 );
	// 		*img_m_R = fmax( fmin( img_m_ant_R, 255), 0 );
	// 	}


	// 	img_m_A = dst + indice_img_modificada + A32;
	// 	img_m_B = dst + indice_img_modificada + B32;
	// 	img_m_G = dst + indice_img_modificada + G32;
	// 	img_m_R = dst + indice_img_modificada + R32;

	// 	// *img_m_A = fmax( fmin( ( img_m_ant_A + img_m_sig_A ) >> 2, 255), 0 );
	// 	*img_m_A = img_m_ant_A,
	// 	*img_m_B = fmax( fmin( img_m_sig_B, 255), 0 );
	// 	*img_m_G = fmax( fmin( img_m_sig_G, 255), 0 );
	// 	*img_m_R = fmax( fmin( img_m_sig_R, 255), 0 );


	// 	columna_img_modificada += 1;
	// }

}
