/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

int inRange(int w, int h, uint32_t srcw, uint32_t srch){

    int ret;

    if(w < 3 || h < 3){

        ret = 0;
    }else{
            w = srcw - w;
            h = srch - h;

            if(w < 4 || h < 4){ret = 0;}else{ret = 1;}

        }

        return ret;
}

void C_maxCloser(uint8_t* src, uint32_t srcw, uint32_t srch,
                 uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)), float val) {
    
	uint8_t *A, B, G, R, *_B, *_G, *_R; 
	float maxR, maxG, maxB;

    int b, gH,gW, ph,pw;
    uint32_t k = 0;

    //RGBA (*matrix_src)[srcw] = RGBA (*)[srcw] src;
    //matrix_src[fila][col].g

    //while(k < 4*((srch+1)*srcw+1)){
    while(k < 4*srch*srcw){

            R = *(src+k+3);
            G = *(src+k+2);
            B = *(src+k+1);

            /** calculo el max **/

            b = k / 4;      //bytes
            gH = b / dstw;  //global height
            gW = b % dstw;  //global width
            ph = -3;

            maxR = 0.0;
            maxG = 0.0;
            maxB = 0.0;

        if(inRange(gW, gH, srcw, srch) == 1){

            while( ph<4 ){

                pw = -3;
                while( pw<4 ){

                    maxR = fmax( *(src+(k+3+4*(pw+ph*srcw))), maxR );
                    maxG = fmax( *(src+(k+2+4*(pw+ph*srcw))), maxG );
                    maxB = fmax( *(src+(k+1+4*(pw+ph*srcw))), maxB );
                    
                    pw++;
                }//END While

                ph++;
            }//END While

            /** fin calculo el max **/

            A = dst+k;
            _R = dst+k+3;
            _G = dst+k+2;
            _B = dst+k+1;

            *A = *(src+k); // La componente A se mantiene igual
            *_R = fmax(fmin( R*(1.0-val) + maxR*val ,255),0);
            *_G = fmax(fmin( G*(1.0-val) + maxG*val ,255),0);
            *_B = fmax(fmin( B*(1.0-val) + maxB*val ,255),0);

        }else{

            A = dst+k;
            _R = dst+k+3;
            _G = dst+k+2;
            _B = dst+k+1;

            *A = 255; 
            *_R = 255;
            *_G = 255;
            *_B = 255;

        }
            k += 4;
    }    

}

