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
    
	double maxR, maxG, maxB;

    int gH,gW, ph,pw;

    RGBA (*matrix_src)[srcw] = (RGBA (*)[srcw]) src;
    RGBA (*matrix_dst)[dstw] = (RGBA (*)[dstw]) dst;

     gH=0;
    while(gH < srch){
         gW=0;
        while(gW < srcw){
            /** calculo el max **/
            maxR = 0.0;
            maxG = 0.0;
            maxB = 0.0;

            if(inRange(gW, gH, srcw, srch) == 1){

                ph = -3;
                while( ph<4 ){

                    pw = -3;
                    while( pw<4 ){

                        maxR = fmax( matrix_src[gH+ph][gW+pw].r ,maxR);
                        maxG = fmax( matrix_src[gH+ph][gW+pw].g ,maxG);
                        maxB = fmax( matrix_src[gH+ph][gW+pw].b ,maxB);

                        pw++;
                    }//END While

                    ph++;
                }//END While

                /** fin calculo el max **/

                matrix_dst[gH][gW].a = matrix_src[gH][gW].a; // La componente A se mantiene igual
                matrix_dst[gH][gW].r = matrix_src[gH][gW].r*(1.0-val) + maxR*val;
                matrix_dst[gH][gW].g = matrix_src[gH][gW].g*(1.0-val) + maxG*val;
                matrix_dst[gH][gW].b = matrix_src[gH][gW].b*(1.0-val) + maxB*val;

            }else{

                matrix_dst[gH][gW].a = matrix_src[gH][gW].a; // La componente A se mantiene igual
                matrix_dst[gH][gW].r = 255;
                matrix_dst[gH][gW].g = 255;
                matrix_dst[gH][gW].b = 255;

            }
    

            gW++;
        }

        gH++;
    }

   

}

