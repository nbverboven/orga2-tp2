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
	RGBA (*matrix_src)[srcw] = (RGBA (*)[srcw]) src;
	RGBA (*matrix_dst)[dstw] = (RGBA (*)[dstw]) dst;

	// Primero copio los pixeles que no se modifican

	uint32_t fila_img_modificada = 1;
	uint32_t fila_img_original = 0;
	uint32_t columna_img_modificada;
	uint32_t columna_img_original;

	while ( fila_img_modificada < dsth )
	{
		columna_img_modificada = 0;
		columna_img_original = 0;

		while ( columna_img_modificada < dstw-1 )
		{

			matrix_dst[fila_img_modificada][columna_img_modificada].a = matrix_src[fila_img_original][columna_img_original].a;
			matrix_dst[fila_img_modificada][columna_img_modificada].b = matrix_src[fila_img_original][columna_img_original].b;
			matrix_dst[fila_img_modificada][columna_img_modificada].g = matrix_src[fila_img_original][columna_img_original].g;
			matrix_dst[fila_img_modificada][columna_img_modificada].r = matrix_src[fila_img_original][columna_img_original].r;

			columna_img_modificada += 2;
			columna_img_original += 1;
		}

		fila_img_modificada += 2;
		fila_img_original += 1;
	}

	uint8_t img_m_ant_A, img_m_ant_B, img_m_ant_G, img_m_ant_R,
	        img_m_sig_A, img_m_sig_B, img_m_sig_G, img_m_sig_R;

	// Ahora voy a agregar los pixeles que están entre dos de los originales (recorro filas)


	fila_img_modificada = 1;


	while ( fila_img_modificada < dsth )
	{
		columna_img_modificada = 1;

		while ( columna_img_modificada < dstw-1 )
		{

			img_m_ant_A = matrix_dst[fila_img_modificada][columna_img_modificada-1].a;
			img_m_ant_B = matrix_dst[fila_img_modificada][columna_img_modificada-1].b;
			img_m_ant_G = matrix_dst[fila_img_modificada][columna_img_modificada-1].g;
			img_m_ant_R = matrix_dst[fila_img_modificada][columna_img_modificada-1].r;

			img_m_sig_A = matrix_dst[fila_img_modificada][columna_img_modificada+1].a;
			img_m_sig_B = matrix_dst[fila_img_modificada][columna_img_modificada+1].b;
			img_m_sig_G = matrix_dst[fila_img_modificada][columna_img_modificada+1].g;
			img_m_sig_R = matrix_dst[fila_img_modificada][columna_img_modificada+1].r;

			matrix_dst[fila_img_modificada][columna_img_modificada].a = fmax( img_m_ant_A , img_m_sig_A );
			matrix_dst[fila_img_modificada][columna_img_modificada].b = fmax( fmin( ( img_m_ant_B + img_m_sig_B ) >> 1, 255), 0 );
			matrix_dst[fila_img_modificada][columna_img_modificada].g = fmax( fmin( ( img_m_ant_G + img_m_sig_G ) >> 1, 255), 0 );
			matrix_dst[fila_img_modificada][columna_img_modificada].r = fmax( fmin( ( img_m_ant_R + img_m_sig_R ) >> 1, 255), 0 );

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
			img_m_ant_A = matrix_dst[fila_img_modificada-1][columna_img_modificada].a;
			img_m_ant_B = matrix_dst[fila_img_modificada-1][columna_img_modificada].b;
			img_m_ant_G = matrix_dst[fila_img_modificada-1][columna_img_modificada].g;
			img_m_ant_R = matrix_dst[fila_img_modificada-1][columna_img_modificada].r;

			img_m_sig_A = matrix_dst[fila_img_modificada+1][columna_img_modificada].a;
			img_m_sig_B = matrix_dst[fila_img_modificada+1][columna_img_modificada].b;
			img_m_sig_G = matrix_dst[fila_img_modificada+1][columna_img_modificada].g;
			img_m_sig_R = matrix_dst[fila_img_modificada+1][columna_img_modificada].r;

			matrix_dst[fila_img_modificada][columna_img_modificada].a = fmax( img_m_ant_A , img_m_sig_A );
			matrix_dst[fila_img_modificada][columna_img_modificada].b = fmax( fmin( ( img_m_ant_B + img_m_sig_B ) >> 1, 255), 0 );
			matrix_dst[fila_img_modificada][columna_img_modificada].g = fmax( fmin( ( img_m_ant_G + img_m_sig_G ) >> 1, 255), 0 );
			matrix_dst[fila_img_modificada][columna_img_modificada].r = fmax( fmin( ( img_m_ant_R + img_m_sig_R ) >> 1, 255), 0 );

			fila_img_modificada += 2;
		}

		columna_img_modificada += 2;
	}

	// // Agrego los pixeles que están entre cuatro de los originales

	uint32_t img_m_arriba_izq_A, img_m_arriba_izq_B, img_m_arriba_izq_G, img_m_arriba_izq_R,
	          img_m_arriba_der_B, img_m_arriba_der_G, img_m_arriba_der_R,
	           img_m_abajo_izq_B,  img_m_abajo_izq_G,  img_m_abajo_izq_R,
	           img_m_abajo_der_B,  img_m_abajo_der_G,  img_m_abajo_der_R;


	fila_img_modificada = 2;

	while ( fila_img_modificada < dsth )
	{
		columna_img_modificada = 1;

		while ( columna_img_modificada < dstw-1 )
		{

			img_m_arriba_izq_A = matrix_dst[fila_img_modificada+1][columna_img_modificada-1].a;
			img_m_arriba_izq_B = matrix_dst[fila_img_modificada+1][columna_img_modificada-1].b;
			img_m_arriba_izq_G = matrix_dst[fila_img_modificada+1][columna_img_modificada-1].g;
			img_m_arriba_izq_R = matrix_dst[fila_img_modificada+1][columna_img_modificada-1].r;

			img_m_arriba_der_B = matrix_dst[fila_img_modificada+1][columna_img_modificada+1].b;
			img_m_arriba_der_G = matrix_dst[fila_img_modificada+1][columna_img_modificada+1].g;
			img_m_arriba_der_R = matrix_dst[fila_img_modificada+1][columna_img_modificada+1].r;

			img_m_abajo_izq_B = matrix_dst[fila_img_modificada-1][columna_img_modificada-1].b;
			img_m_abajo_izq_G = matrix_dst[fila_img_modificada-1][columna_img_modificada-1].g;
			img_m_abajo_izq_R = matrix_dst[fila_img_modificada-1][columna_img_modificada-1].r;

			img_m_abajo_der_B = matrix_dst[fila_img_modificada-1][columna_img_modificada+1].b;
			img_m_abajo_der_G = matrix_dst[fila_img_modificada-1][columna_img_modificada+1].g;
			img_m_abajo_der_R = matrix_dst[fila_img_modificada-1][columna_img_modificada+1].r;

			matrix_dst[fila_img_modificada][columna_img_modificada].a =  img_m_arriba_izq_A;//fmax( fmax( ( img_m_arriba_izq_A, img_m_arriba_der_A ), img_m_abajo_izq_A ), img_m_abajo_der_A);
			matrix_dst[fila_img_modificada][columna_img_modificada].b = fmax( fmin( ( img_m_arriba_izq_B + img_m_arriba_der_B + img_m_abajo_izq_B + img_m_abajo_der_B ) >> 2, 255), 0);
			matrix_dst[fila_img_modificada][columna_img_modificada].g = fmax( fmin( ( img_m_arriba_izq_G + img_m_arriba_der_G + img_m_abajo_izq_G + img_m_abajo_der_G ) >> 2, 255), 0);
			matrix_dst[fila_img_modificada][columna_img_modificada].r = fmax( fmin( ( img_m_arriba_izq_R + img_m_arriba_der_R + img_m_abajo_izq_R + img_m_abajo_der_R ) >> 2, 255), 0);

			columna_img_modificada += 2;
		}

		fila_img_modificada += 2;
	}

	// Hago los bordes


	columna_img_modificada = 0;

	// Borde inferior
	while ( columna_img_modificada < dstw )
	{
		matrix_dst[0][columna_img_modificada].a = matrix_dst[1][columna_img_modificada].a;
		matrix_dst[0][columna_img_modificada].b = matrix_dst[1][columna_img_modificada].b;
		matrix_dst[0][columna_img_modificada].g = matrix_dst[1][columna_img_modificada].g;
		matrix_dst[0][columna_img_modificada].r = matrix_dst[1][columna_img_modificada].r;

		columna_img_modificada += 1;
	}

	

	fila_img_modificada = 1;


	while ( fila_img_modificada < dsth )
	{
		matrix_dst[fila_img_modificada][dstw-1].a = matrix_dst[fila_img_modificada][dstw-2].a;
		matrix_dst[fila_img_modificada][dstw-1].b = matrix_dst[fila_img_modificada][dstw-2].b;
		matrix_dst[fila_img_modificada][dstw-1].g = matrix_dst[fila_img_modificada][dstw-2].g;
		matrix_dst[fila_img_modificada][dstw-1].r = matrix_dst[fila_img_modificada][dstw-2].r;

		fila_img_modificada += 1;
	}




}
