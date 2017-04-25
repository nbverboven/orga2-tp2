/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

uint32_t getInRange(uint32_t p, uint32_t g , uint32_t dst){
    uint32_t ret;

    if((p+g) > 2){
        ret = p + g - 3;
        if(ret > (dst+1)*4)
            ret = (dst+1)*4;
    }else
        ret = 0;

    return ret;
}

void C_maxCloser(uint8_t* src, uint32_t srcw, uint32_t srch,
                 uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)), float val) {
    
	uint8_t *A, B, G, R, *_B, *_G, *_R; 
	double maxR, maxG, maxB;

    uint32_t b, gH,gW, ph,pw, w,h;
    uint32_t k = 0;

    while(k < 4*((srch+1)*srcw+1)){
    //while(k < 4*srch*srcw){

            R = *(src+k+3);
            G = *(src+k+2);
            B = *(src+k+1);

            /** calculo el max **/

            b = k / 4;      //bytes
            gH = b / dstw;  //height
            gW = b % dstw;  //width
            pw = 0;
            
            w = getInRange(pw,gW,dstw);

            maxR = 0.0;
            maxG = 0.0;
            maxB = 0.0;

            //printf("Estoy parado en: W:%u H:%u\n", gW, gH);
            while( pw<7 ){
                ph = 0;
                h = getInRange(ph,gH,dsth);

                while( ph<7 ){
                        
                    maxR = fmax( *(src+(w*h*4)+3), maxR );
                    maxG = fmax( *(src+(w*h*4)+2), maxG );
                    maxB = fmax( *(src+(w*h*4)+1), maxB );
                    /*
                        printf("(%u,%u) - ",w,h);
                        printf("maxR = %f ",maxR);
                        printf("maxG = %f ",maxG);
                        printf("maxB = %f \n",maxB);
                    */

                    ph = ph+1;
                    h = getInRange(ph,gH,dsth);
                }//END While


            pw = pw+1;
            w = getInRange(pw,gW,dstw);
            }//END While
            
            /** fin calculo el max **/

            A = dst+k;
            _R = dst+k+3;
            _G = dst+k+2;
            _B = dst+k+1;

            /*
                printf("Quedaron: ");
                printf("maxR = %f ",maxR);
                printf("maxG = %f ",maxG);
                printf("maxB = %f \n",maxB);
                printf("\n");
            */

            *A = *(src+k); // La componente A se mantiene igual
            *_R = fmax(fmin( R*(1.0-val) + maxR*val ,255),0);
            *_G = fmax(fmin( G*(1.0-val) + maxG*val ,255),0);
            *_B = fmax(fmin( B*(1.0-val) + maxB*val ,255),0);

            k += 4;
    }    

}

