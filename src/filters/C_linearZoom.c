/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

void agregoIguales(uint8_t* src, uint32_t srcw, uint32_t srch __attribute__((unused)),
                   uint8_t* dst, uint32_t dstw, uint32_t dsth)
{
	RGBA (*matrix_src)[srcw] = (RGBA (*)[srcw]) src;
	RGBA (*matrix_dst)[dstw] = (RGBA (*)[dstw]) dst;

	uint32_t columna_dst;
	uint32_t columna_src;

	uint32_t fila_dst = 1;
	uint32_t fila_src = 0;

	while ( fila_dst < dsth )
	{
		columna_dst = 0;
		columna_src = 0;

		while ( columna_dst < dstw-1 )
		{
			matrix_dst[fila_dst][columna_dst] = matrix_src[fila_src][columna_src];

			columna_dst += 2;
			columna_src += 1;
		}

		fila_dst += 2;
		fila_src += 1;
	}	
}


void agregoEntre2(uint8_t* dst, uint32_t dstw, uint32_t dsth)
{
	RGBA (*matrix_dst)[dstw] = (RGBA (*)[dstw]) dst;

	uint8_t img_m_ant_A, img_m_ant_B, img_m_ant_G, img_m_ant_R,
	        img_m_sig_A, img_m_sig_B, img_m_sig_G, img_m_sig_R;

	uint32_t fila_dst;
	uint32_t columna_dst;

	// Recorro columnas
	fila_dst = 1;

	while ( fila_dst < dsth )
	{
		columna_dst = 1;

		while ( columna_dst < dstw-1 )
		{
			img_m_ant_A = matrix_dst[fila_dst][columna_dst-1].a;
			img_m_ant_B = matrix_dst[fila_dst][columna_dst-1].b;
			img_m_ant_G = matrix_dst[fila_dst][columna_dst-1].g;
			img_m_ant_R = matrix_dst[fila_dst][columna_dst-1].r;

			img_m_sig_A = matrix_dst[fila_dst][columna_dst+1].a;
			img_m_sig_B = matrix_dst[fila_dst][columna_dst+1].b;
			img_m_sig_G = matrix_dst[fila_dst][columna_dst+1].g;
			img_m_sig_R = matrix_dst[fila_dst][columna_dst+1].r;

			matrix_dst[fila_dst][columna_dst].a = fmax( img_m_ant_A , img_m_sig_A );
			matrix_dst[fila_dst][columna_dst].b = fmax( fmin( ( img_m_ant_B + img_m_sig_B ) >> 1, 255), 0 );
			matrix_dst[fila_dst][columna_dst].g = fmax( fmin( ( img_m_ant_G + img_m_sig_G ) >> 1, 255), 0 );
			matrix_dst[fila_dst][columna_dst].r = fmax( fmin( ( img_m_ant_R + img_m_sig_R ) >> 1, 255), 0 );

			columna_dst += 2;
		}

		fila_dst += 2;
	}

	// Recorro filas
	columna_dst = 0;

	while ( columna_dst < dstw-1 )
	{
		fila_dst = 2;

		while ( fila_dst < dsth )
		{
			img_m_ant_A = matrix_dst[fila_dst-1][columna_dst].a;
			img_m_ant_B = matrix_dst[fila_dst-1][columna_dst].b;
			img_m_ant_G = matrix_dst[fila_dst-1][columna_dst].g;
			img_m_ant_R = matrix_dst[fila_dst-1][columna_dst].r;

			img_m_sig_A = matrix_dst[fila_dst+1][columna_dst].a;
			img_m_sig_B = matrix_dst[fila_dst+1][columna_dst].b;
			img_m_sig_G = matrix_dst[fila_dst+1][columna_dst].g;
			img_m_sig_R = matrix_dst[fila_dst+1][columna_dst].r;

			matrix_dst[fila_dst][columna_dst].a = fmax( img_m_ant_A , img_m_sig_A );
			matrix_dst[fila_dst][columna_dst].b = fmax( fmin( ( img_m_ant_B + img_m_sig_B ) >> 1, 255), 0 );
			matrix_dst[fila_dst][columna_dst].g = fmax( fmin( ( img_m_ant_G + img_m_sig_G ) >> 1, 255), 0 );
			matrix_dst[fila_dst][columna_dst].r = fmax( fmin( ( img_m_ant_R + img_m_sig_R ) >> 1, 255), 0 );

			fila_dst += 2;
		}

		columna_dst += 2;
	}
}


void agregoEntre4(uint8_t* dst, uint32_t dstw, uint32_t dsth)
{
	RGBA (*matrix_dst)[dstw] = (RGBA (*)[dstw]) dst;

	uint32_t img_m_arriba_izq_A, img_m_arriba_izq_B, img_m_arriba_izq_G, img_m_arriba_izq_R,
	                             img_m_arriba_der_B, img_m_arriba_der_G, img_m_arriba_der_R,
	                             img_m_abajo_izq_B,  img_m_abajo_izq_G,  img_m_abajo_izq_R,
	                             img_m_abajo_der_B,  img_m_abajo_der_G,  img_m_abajo_der_R;

	uint32_t fila_dst;
	uint32_t columna_dst;

	fila_dst = 2;

	while ( fila_dst < dsth )
	{
		columna_dst = 1;

		while ( columna_dst < dstw-1 )
		{
			img_m_arriba_izq_A = matrix_dst[fila_dst+1][columna_dst-1].a;
			img_m_arriba_izq_B = matrix_dst[fila_dst+1][columna_dst-1].b;
			img_m_arriba_izq_G = matrix_dst[fila_dst+1][columna_dst-1].g;
			img_m_arriba_izq_R = matrix_dst[fila_dst+1][columna_dst-1].r;

			img_m_arriba_der_B = matrix_dst[fila_dst+1][columna_dst+1].b;
			img_m_arriba_der_G = matrix_dst[fila_dst+1][columna_dst+1].g;
			img_m_arriba_der_R = matrix_dst[fila_dst+1][columna_dst+1].r;

			img_m_abajo_izq_B = matrix_dst[fila_dst-1][columna_dst-1].b;
			img_m_abajo_izq_G = matrix_dst[fila_dst-1][columna_dst-1].g;
			img_m_abajo_izq_R = matrix_dst[fila_dst-1][columna_dst-1].r;

			img_m_abajo_der_B = matrix_dst[fila_dst-1][columna_dst+1].b;
			img_m_abajo_der_G = matrix_dst[fila_dst-1][columna_dst+1].g;
			img_m_abajo_der_R = matrix_dst[fila_dst-1][columna_dst+1].r;

			matrix_dst[fila_dst][columna_dst].a =  img_m_arriba_izq_A;
			matrix_dst[fila_dst][columna_dst].b = fmax( fmin( ( img_m_arriba_izq_B + img_m_arriba_der_B + img_m_abajo_izq_B + img_m_abajo_der_B ) >> 2, 255), 0);
			matrix_dst[fila_dst][columna_dst].g = fmax( fmin( ( img_m_arriba_izq_G + img_m_arriba_der_G + img_m_abajo_izq_G + img_m_abajo_der_G ) >> 2, 255), 0);
			matrix_dst[fila_dst][columna_dst].r = fmax( fmin( ( img_m_arriba_izq_R + img_m_arriba_der_R + img_m_abajo_izq_R + img_m_abajo_der_R ) >> 2, 255), 0);

			columna_dst += 2;
		}

		fila_dst += 2;
	}
}


void agregoBordes(uint8_t* dst, uint32_t dstw, uint32_t dsth)
{
	RGBA (*matrix_dst)[dstw] = (RGBA (*)[dstw]) dst;

	uint32_t fila_dst;
	uint32_t columna_dst;

	// Borde inferior

	columna_dst = 0;

	while ( columna_dst < dstw )
	{
		matrix_dst[0][columna_dst] = matrix_dst[1][columna_dst];

		columna_dst += 1;
	}

	// Borde derecho

	fila_dst = 0;

	while ( fila_dst < dsth )
	{
		matrix_dst[fila_dst][dstw-1] = matrix_dst[fila_dst][dstw-2];

		fila_dst += 1;
	}
}


void C_linearZoom(uint8_t* src, uint32_t srcw, uint32_t srch,
                  uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)))
{
	// Primero copio los pixeles que no se modifican
	agregoIguales(src, srcw, srch, dst, dstw, dsth);

	// Ahora voy a agregar los pixeles que están entre dos de los originales
	agregoEntre2(dst, dstw, dsth);

	// Agrego los pixeles que están entre cuatro de los originales
	agregoEntre4(dst, dstw, dsth);

	// Agrego los bordes derecho e inferior
	agregoBordes(dst, dstw, dsth);
}
