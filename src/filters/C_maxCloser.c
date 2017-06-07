/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion maxCloser                                  */
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

            //if(w < 4 || h < 4){ret = 0;}else{ret = 1;}
            ret = !( w < 4 || h < 4 ); // Dado que la comparación devuelve 1 si es True y 0 en el caso contrario, esto tiene sentido

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
            // calculo el max 
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

                // fin calculo el max

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
/*void C_maxCloser(uint8_t* src, uint32_t srcw, uint32_t srch,
                 uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)), float val) {

RGBA (*matrix_src)[srcw] = (RGBA (*)[srcw]) src;
RGBA (*matrix_dst)[dstw] = (RGBA (*)[dstw]) dst;

for (int f = 0; f < 3; f++) {
    for (int c = 0; c < srcw; c++) {

        matrix_dst[f][c].r = 255;
        matrix_dst[f][c].g = 255;
        matrix_dst[f][c].b = 255;        
    }
}

for (int f = srch-3; f < srch; f++) {
    for (int c = 0; c < srcw; c++) {
        
        matrix_dst[f][c].r = 255;
        matrix_dst[f][c].g = 255;
        matrix_dst[f][c].b = 255;        
    }
}

for (int f = 3; f < srch-3; f++) {
    for (int c = 0; c < 3; c++) {
        
        matrix_dst[f][c].r = 255;
        matrix_dst[f][c].g = 255;
        matrix_dst[f][c].b = 255;        
    }
}

for (int f = 3; f < srch-3; f++) {
    for (int c = srcw-3; c < srcw; c++) {
        
        matrix_dst[f][c].r = 255;
        matrix_dst[f][c].g = 255;
        matrix_dst[f][c].b = 255;        
    }
}

for (int f = 3; f < srch-3; f++) {
        for (int c = 3; c < srcw-3; c++) {
    //pointers
            RGBA *p_d = (RGBA*) &matrix_dst[f][c];

            RGBA *p_menos3_men3 = (RGBA*) &matrix_src[f-3][(c-3)];
            RGBA *p_menos3_men2 = (RGBA*) &matrix_src[f-3][(c-2)];
            RGBA *p_menos3_men1 = (RGBA*) &matrix_src[f-3][(c-1)];
            RGBA *p_menos3_men0 = (RGBA*) &matrix_src[f-3][  c  ];
            RGBA *p_menos3_mas1 = (RGBA*) &matrix_src[f-3][(c+1)];
            RGBA *p_menos3_mas2 = (RGBA*) &matrix_src[f-3][(c+2)];
            RGBA *p_menos3_mas3 = (RGBA*) &matrix_src[f-3][(c+3)];

            RGBA *p_menos2_men3 = (RGBA*) &matrix_src[f-2][(c-3)];
            RGBA *p_menos2_men2 = (RGBA*) &matrix_src[f-2][(c-2)];
            RGBA *p_menos2_men1 = (RGBA*) &matrix_src[f-2][(c-1)];
            RGBA *p_menos2_men0 = (RGBA*) &matrix_src[f-2][  c  ];
            RGBA *p_menos2_mas1 = (RGBA*) &matrix_src[f-2][(c+1)];
            RGBA *p_menos2_mas2 = (RGBA*) &matrix_src[f-2][(c+2)];
            RGBA *p_menos2_mas3 = (RGBA*) &matrix_src[f-2][(c+3)];

            RGBA *p_menos1_men3 = (RGBA*) &matrix_src[f-1][(c-3)];
            RGBA *p_menos1_men2 = (RGBA*) &matrix_src[f-1][(c-2)];
            RGBA *p_menos1_men1 = (RGBA*) &matrix_src[f-1][(c-1)];
            RGBA *p_menos1_men0 = (RGBA*) &matrix_src[f-1][  c  ];
            RGBA *p_menos1_mas1 = (RGBA*) &matrix_src[f-1][(c+1)];
            RGBA *p_menos1_mas2 = (RGBA*) &matrix_src[f-1][(c+2)];
            RGBA *p_menos1_mas3 = (RGBA*) &matrix_src[f-1][(c+3)];

            RGBA *p_menos0_men3 = (RGBA*) &matrix_src[f][(c-3)];
            RGBA *p_menos0_men2 = (RGBA*) &matrix_src[f][(c-2)];
            RGBA *p_menos0_men1 = (RGBA*) &matrix_src[f][(c-1)];
            RGBA *p_menos0_men0 = (RGBA*) &matrix_src[f][  c  ];
            RGBA *p_menos0_mas1 = (RGBA*) &matrix_src[f][(c+1)];
            RGBA *p_menos0_mas2 = (RGBA*) &matrix_src[f][(c+2)];
            RGBA *p_menos0_mas3 = (RGBA*) &matrix_src[f][(c+3)];

            RGBA *p_mas1_men3 = (RGBA*) &matrix_src[f+1][(c-3)];
            RGBA *p_mas1_men2 = (RGBA*) &matrix_src[f+1][(c-2)];
            RGBA *p_mas1_men1 = (RGBA*) &matrix_src[f+1][(c-1)];
            RGBA *p_mas1_men0 = (RGBA*) &matrix_src[f+1][  c  ];
            RGBA *p_mas1_mas1 = (RGBA*) &matrix_src[f+1][(c+1)];
            RGBA *p_mas1_mas2 = (RGBA*) &matrix_src[f+1][(c+2)];
            RGBA *p_mas1_mas3 = (RGBA*) &matrix_src[f+1][(c+3)];

            RGBA *p_mas2_men3 = (RGBA*) &matrix_src[f+2][(c-3)];
            RGBA *p_mas2_men2 = (RGBA*) &matrix_src[f+2][(c-2)];
            RGBA *p_mas2_men1 = (RGBA*) &matrix_src[f+2][(c-1)];
            RGBA *p_mas2_men0 = (RGBA*) &matrix_src[f+2][  c  ];
            RGBA *p_mas2_mas1 = (RGBA*) &matrix_src[f+2][(c+1)];
            RGBA *p_mas2_mas2 = (RGBA*) &matrix_src[f+2][(c+2)];
            RGBA *p_mas2_mas3 = (RGBA*) &matrix_src[f+2][(c+3)];

            RGBA *p_mas3_men3 = (RGBA*) &matrix_src[f+3][(c-3)];
            RGBA *p_mas3_men2 = (RGBA*) &matrix_src[f+3][(c-2)];
            RGBA *p_mas3_men1 = (RGBA*) &matrix_src[f+3][(c-1)];
            RGBA *p_mas3_men0 = (RGBA*) &matrix_src[f+3][  c  ];
            RGBA *p_mas3_mas1 = (RGBA*) &matrix_src[f+3][(c+1)];
            RGBA *p_mas3_mas2 = (RGBA*) &matrix_src[f+3][(c+2)];
            RGBA *p_mas3_mas3 = (RGBA*) &matrix_src[f+3][(c+3)];

    //Valores De Alrededor
            uint8_t valR[49] = { p_menos3_men3->r, p_menos3_men2->r, p_menos3_men1->r,
                                      p_menos3_men0->r, p_menos3_mas1->r, p_menos3_mas2->r,
                                      p_menos3_mas3->r, p_menos2_men3->r, p_menos2_men2->r,
                                       p_menos2_men1->r, p_menos2_men0->r, p_menos2_mas1->r,
                                       p_menos2_mas2->r, p_menos2_mas3->r, p_menos1_men3->r,
                                       p_menos1_men2->r, p_menos1_men1->r, p_menos1_men0->r,
                                       p_menos1_mas1->r, p_menos1_mas2->r, p_menos1_mas3->r,
                                       p_menos0_men3->r, p_menos0_men2->r, p_menos0_men1->r,
                                       p_menos0_men0->r, p_menos0_mas1->r, p_menos0_mas2->r,
                                       p_menos0_mas3->r, p_mas1_men3->r, p_mas1_men2->r, 
                                        p_mas1_men1->r, p_mas1_men0->r, p_mas1_mas1->r, 
                                        p_mas1_mas2->r, p_mas1_mas3->r, p_mas2_men3->r, 
                                        p_mas2_men2->r, p_mas2_men1->r, p_mas2_men0->r, 
                                        p_mas2_mas1->r, p_mas2_mas2->r, p_mas2_mas3->r, 
                                        p_mas3_men3->r, p_mas3_men2->r, p_mas3_men1->r, 
                                        p_mas3_men0->r, p_mas3_mas1->r, p_mas3_mas2->r, 
                                        p_mas3_mas3->r };

            uint8_t valG[49] = { p_menos3_men3->g, p_menos3_men2->g, p_menos3_men1->g,
                                      p_menos3_men0->g, p_menos3_mas1->g, p_menos3_mas2->g,
                                      p_menos3_mas3->g, p_menos2_men3->g, p_menos2_men2->g,
                                       p_menos2_men1->g, p_menos2_men0->g, p_menos2_mas1->g,
                                       p_menos2_mas2->g, p_menos2_mas3->g, p_menos1_men3->g,
                                       p_menos1_men2->g, p_menos1_men1->g, p_menos1_men0->g,
                                       p_menos1_mas1->g, p_menos1_mas2->g, p_menos1_mas3->g,
                                       p_menos0_men3->g, p_menos0_men2->g, p_menos0_men1->g,
                                       p_menos0_men0->g, p_menos0_mas1->g, p_menos0_mas2->g,
                                       p_menos0_mas3->g, p_mas1_men3->g, p_mas1_men2->g, 
                                        p_mas1_men1->g, p_mas1_men0->g, p_mas1_mas1->g, 
                                        p_mas1_mas2->g, p_mas1_mas3->g, p_mas2_men3->g, 
                                        p_mas2_men2->g, p_mas2_men1->g, p_mas2_men0->g, 
                                        p_mas2_mas1->g, p_mas2_mas2->g, p_mas2_mas3->g, 
                                        p_mas3_men3->g, p_mas3_men2->g, p_mas3_men1->g, 
                                        p_mas3_men0->g, p_mas3_mas1->g, p_mas3_mas2->g, 
                                        p_mas3_mas3->g };

            uint8_t valB[49] = { p_menos3_men3->b, p_menos3_men2->b, p_menos3_men1->b,
                                      p_menos3_men0->b, p_menos3_mas1->b, p_menos3_mas2->b,
                                      p_menos3_mas3->b, p_menos2_men3->b, p_menos2_men2->b,
                                       p_menos2_men1->b, p_menos2_men0->b, p_menos2_mas1->b,
                                       p_menos2_mas2->b, p_menos2_mas3->b, p_menos1_men3->b,
                                       p_menos1_men2->b, p_menos1_men1->b, p_menos1_men0->b,
                                       p_menos1_mas1->b, p_menos1_mas2->b, p_menos1_mas3->b,
                                       p_menos0_men3->b, p_menos0_men2->b, p_menos0_men1->b,
                                       p_menos0_men0->b, p_menos0_mas1->b, p_menos0_mas2->b,
                                       p_menos0_mas3->b, p_mas1_men3->b, p_mas1_men2->b, 
                                        p_mas1_men1->b, p_mas1_men0->b, p_mas1_mas1->b, 
                                        p_mas1_mas2->b, p_mas1_mas3->b, p_mas2_men3->b, 
                                        p_mas2_men2->b, p_mas2_men1->b, p_mas2_men0->b, 
                                        p_mas2_mas1->b, p_mas2_mas2->b, p_mas2_mas3->b, 
                                        p_mas3_men3->b, p_mas3_men2->b, p_mas3_men1->b, 
                                        p_mas3_men0->b, p_mas3_mas1->b, p_mas3_mas2->b, 
                                        p_mas3_mas3->b };
    //inicio maxes      
            uint8_t maxR = valR[0];
            uint8_t maxG = valG[0];
            uint8_t maxB = valB[0];                   
    //seteo maxes       
            for (int i =1; i<49;i++){
                if (maxR<valR[i]) maxR = valR[i];
                if (maxG<valG[i]) maxG = valG[i];
                if (maxB<valB[i]) maxB = valB[i];
            }        
    //asigno destino    
            p_d->r = p_menos0_men0->r*(1.0-val) + maxR*val;
            p_d->g = p_menos0_men0->g*(1.0-val) + maxG*val;
            p_d->b = p_menos0_men0->b*(1.0-val) + maxB*val;
            
        }
    }
}*/
