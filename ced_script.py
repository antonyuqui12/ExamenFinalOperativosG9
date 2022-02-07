#!/usr/bin/env python
# coding: utf-8

import xlsxwriter

import numpy as np
import pandas as pd
from glob import glob


# In[37]:

#----------------------- Se extrae las cedulas del archivo .xlsx -------------------------------------#

### Las cedulas extraidas de la pestaña 7; sheet_name=6

file = glob('*.xlsx')[-1]
ds = pd.read_excel(file, sheet_name=6, index_col=[0])
ds.columns = ['cedulas', 0, 1]
ceds = list(ds['cedulas'].astype(np.str_))
ceds = ['0'+i if len(i)<10 else i for i in ceds ]

#ceds = list(ds['cedulas'])

#---------------------------------------

#Colocamos las cedulas de la base de datos para pruebas
# ceds = [107425134, 107252777, 302447156, 105182752, 150548790, 107174013, 106368699, 106055783, 106037302, 150573848, 106427164, 150043685, 105565444, 105994057, 107168320, 106485980, 106122252, 107171803, 106271976, 106139389, 106439094, 107289167, 1400814990, 105947378, 705397511, 302447404, 105754618, 105062269, 105142384, 105564546, 105994099, 107378143, 106426208, 604231043, 104728886, 106904675, 302876578, 302707708, 302886577, 150552073, 150547834, 106352784, 302721006, 106765258, 302973417]


#---------------------- Se va verificando que las cedulas se encuentran presentes en el documento colocando validas y no validas ------------------#

#SE inicia con un diccionario vacio
D = {} ### diccionario vacio


txts = glob("*.txt") ### archivos de fechas
columnas = ['Estudiante'] + [i.split('.')[0] for i in txts] ### lo usaremos como encabezado


#Se evcalua dentro de cada txt si las cedulas estan presentes o no

for txt in txts:
    fecha = txt.split('.')[0]
    file = open(txt, 'r')
    lines = [int(i.strip()) for i in file.readlines()]
    file.close()
    for ced in ceds: ### recorremos las cedulas
        if int(ced) in lines: ### asistencia
            if fecha not in D:
                D[fecha] = {ced:'A'}
            else:
                D[fecha][ced]='A'
        else: ### falta
            if fecha not in D:
                D[fecha] = {ced:'F'}
            else:
                D[fecha][ced]='F'

#Se crea un dataframe con los valores del diccionario
ds = pd.DataFrame(D).reset_index().to_numpy()
ds1 = [np.array(columnas)] + list(ds) ### obtenemos la lista de datos
asistencias = np.array(ds1) ### convertimos las lista en un arreglo bidimensional
# asistencias


# Creando el nuevo xlsx

workbook   = xlsxwriter.Workbook('asistencias.xlsx')
worksheet = workbook.add_worksheet()

filas, columns = asistencias.shape
for fila in range(filas):
    for columna in range(columns):
        info = str(asistencias[fila, columna])
        worksheet.write(fila, columna, info) ### escribimos en el archivo

workbook.close()






