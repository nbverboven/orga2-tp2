from subprocess import call
# from matplotlib import pyplot as plt
# import itertools
# import numpy as np
import os
import sys

lenguaje = sys.argv[1]
filtro = sys.argv[2]
cant_iteraciones =  int(sys.argv[3])


def timeCounter(lenguaje, filtro, ciclos):

	# Borro el archivo que tenía los tiempos en C/asm para el filtro 
	# pasado como segundo parámetro, si ya existía
	try:
		os.remove(lenguaje.upper() + "_" + filtro + "_tiempos.txt")
	except FileNotFoundError:
		pass

	# try:
	# 	os.remove("src/img/" + lenguaje + "_lena_" + filtro + ".bmp")
	# except FileNotFoundError:
	# 	pass

	count = 0
	imagen_fuente = "src/img/lena.bmp"
	imagen_destino = "src/img/" + lenguaje.upper() + "_lena_" + filtro + ".bmp"

	while count < ciclos:
		call( ["./bin/tp2", lenguaje, filtro, imagen_fuente, imagen_destino] )
		count += 1



# Ejecuto esto si llamo a este módulo directamente
if __name__ == '__main__':
	timeCounter(lenguaje, filtro, cant_iteraciones)

