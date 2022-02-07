#!/usr/bin/bash

for f in *.png; do mv "$f"  `echo $f | tr ' ' '_'`; done #Elimina los espacios entre los caracteres

for archivo in *.png; 
do

#	echo "Recortando las imagenes"

#	convert "$archivo" -crop 3320x1080+1600+100 "corte_$archivo"       									#Recorte de imagen

	echo "Convirtiendo $archivo"

	convert "$archivo" -threshold 25% "convert25_$archivo"										#Primer filtro

	convert "$archivo" -threshold 50% "convert50_$archivo" 										#Segundo filtro

	convert "$archivo" -threshold 68% "convert68_$archivo"										#Tercer filtro

	echo "Buscando cedulas"

	tesseract "convert25_$archivo" "25_$archivo"  --dpi 20000										#Datos Primer Filtro

	tesseract "convert50_$archivo" "50_$archivo"  --dpl 20000										#Datos Segundo Filtro

	tesseract "convert68_$archivo" "68_$archivo"  --dpl 20000										#Datos Tercer Filtro

	egrep -o "[0-9]{10}" "25_$archivo.txt" | uniq > "cedulas25_$archivo.txt"								#Cedulas Primer Filtro

	egrep -o "[0-9]{10}" "50_$archivo.txt" | uniq > "cedulas50_$archivo.txt"								#Cedulas Segundo Filtro

	egrep -o "[0-9]{10}" "68_$archivo.txt" | uniq > "cedulas68_$archivo.txt"                                                                #Cedulas Tercer Filtro

	cat "cedulas25_$archivo.txt" "cedulas50_$archivo.txt" "cedulas68_$archivo.txt" | uniq > "cedulas_$archivo.txt"

#	rm -f "$archivo.txt"

	rm -f "convert25_$archivo"

	rm -f "convert50_$archivo"

	rm -f "convert68_$archivo"

	rm -f "25_$archivo.txt"

	rm -f "50_$archivo.txt"

	rm -f "68_$archivo.txt" 

#	rm -f "corte_$archivo"

	rm -f "cedulas25_$archivo.txt"

	rm -f "cedulas50_$archivo.txt"

	rm -f "cedulas68_$archivo.txt"

#        cedulastotal = 0

	while IFS= read -r line; do

	awk  '{ cedula = $line

		if(length(cedula)==10){                                                                                                         #Se comprueba que el numero tenga 10 digitos

		dig_region = substr(cedula,0,2)													#Se obtiene el Numero de provincia

		if(int(dig_region) >= 1 && int(dig_region) <= 24){										#Se comprueba si esta dentro de las 24 provincias

		ult_dig=int(substr(cedula,10,1))												#Se obtiene el ultimo digito

		pares = int(substr(cedula,2,1)) + int(substr(cedula,4,1)) + int(substr(cedula,6,1)) + int(substr(cedula,8,1))  			#Se suman digitos pares

		numero1 = int(substr(cedula,1,1))   												#|

		numero1 = numero1*2														#|

		if (numero1 > 9) {numero1 = (numero1 - 9)}											#| Primer digito impar

		numero3 = int(substr(cedula,3,1))												#|

		numero3 =  numero3*2														#|

		if (numero3 > 9) {numero3 = (numero3 - 9)}											#| Segundo digito impar

		numero5 = int(substr(cedula,5,1))												#|

		numero5 = numero5*2														#|

		if (numero5 > 9) {numero5 = (numero5 - 9)}											#| Tercer digito impar

		numero7 = int(substr(cedula,7,1))												#|

		numero7 = numero7*2														#|

		if (numero7 > 9) {numero7 = (numero7 - 9)}											#| Cuarto digito impar

		numero9 = int(substr(cedula,9,1))												#|

		numero9 = numero9*2														#|

		if (numero9 > 9) {numero9 = (numero9-9)}											#| Quinto digito impar

		impares = numero1 + numero3 + numero5 + numero7 + numero9									#Suma de impares

		total = pares + impares 													#Valor total

		totstr = total + ""

		prim_dig = substr(totstr,0,1)

		decena = (int(prim_dig)+1)*10

		validador = decena - total													#Digito Validador

		if (validador == 10){dig_val=0}

		if (validador == ult_dig){print (cedula) > "validas.txt"}         									#Cedula Valida

		if (validador != ult_dig){print (cedula "..... [Invalida]")}									#Cedula Invalida

		}else {print (cedula ".....[Invalida] La cedula no pertenece a Ecuador")}							#Cedula Invalida por no ser de Ecuador

		}else {print (cedula ".....[Invalida] La cedula no tiene 10 digitos")}								#Cedula Invalida por no tener 10 digitos
	}'

	done < "cedulas_$archivo.txt"

	fecha=${archivo:3:10}

	cat "validas.txt" >> "$fecha.txt"												#cedulas Validas con fecha

	rm -f "validas.txt"

	rm -f "cedulas_$archivo.txt"

done


python3 ced_script.py


rm -f *.txt
