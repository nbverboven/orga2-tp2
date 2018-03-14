Trabajo práctico 2 - Organización del computador 2
====================================================


Sobre cómo organizar un poco el repositorio
-----------------------------------------------------

Los archivos .o y los ejecutables ténganlos en sus máquinas, no los comiteen. Es un bardo si no cada vez que se hace un pull. Suban solamente los archivos .c o .asm que editaron y cada uno lo 
compila por su cuenta.

--Nico

Información para los experimentos del tp
--------------------------------------------------

Subí un archivo *.py* con un par de funciones para contar los ciclos del reloj que insumen los distintos filtros. Además, modifiqué el archivo **run.c** para que escriba en un archivo *.txt*
 los resultados obtenidos.

La forma de usarlo es bastante fácil. Lo que hay que hacer es escribir en la consola 

```
python3 tomar_tiempos.py [c/asm] [filtro] [cantidad de muestras]
```

En el caso de *maxCloser*, se toma un 
parámetro adicional (var). En este caso, el comando se ejecuta como

```
python3 tomar_tiempos.py [c/asm] maxCloser [var] [cantidad de muestras]
``` 

El siguiente código llama 10 veces a la implementación en C de *rgb2yuv* y genera un archivo de texto con la cantidad de ciclos que tardó por cada iteración: 

```
python3 tomar_tiempos c rgb2yuv 10
```

Veamos qué tengo que hacer si ahora quiero ejecutar 150 veces *maxCloser* en asm con un valor de var de 0.313: 

```
python3 tomar_tiempos.py asm maxCloser 0.313 150
```

Un par de aclaraciones para terminar:

- Los .txt se generan en el directorio desde donde se llama a `tomar_tiempos.py`. Una sugerencia es hacerlo en la carpeta tp2_Orga2.
- La cantidad de iteraciones. Yo lo probé en las compus de la facultad con 500 y tarda un rato. Véanlo.
- Los archivos donde se guardan los tiempos se borran cada vez que se corre el mismo filtro. Es decir, si yo hice `python3 tomar_tiempos.py asm maxCloser 0.313 150` y después 
`python3 tomar_tiempos.py asm maxCloser 0.313 15`, lo que voy a tener al final es un archivo llamado **ASM_maxCloser_tiempos.txt** con 15 entradas.
- La imagen por defecto que se usa es lena.bmp, que está ubicada en **src/img/**. Podría cambiarse esto si hicera falta, pero me pareció que para empezar estaba bien.

-- Nico
