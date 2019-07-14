			.data
				
				nombre_fichero: .asciiz "c:\users\fichero.txt"
				
				cadena: .asciiz "na"
				
				tipo_fichero: .word 0x002					#Fichero tipo lectura-escritura
					
				VFichero: .space 2048 						#Espacio donde se almacenaran los bytes leidos
				
				VCadena: .space 2048						#Espacio donde se almacena la cadena pedida

				nbytes: .word 0x001
				
				Espacio: .byte ' '							#En esta direccion se almacenara un espacio
				
				Salto : .byte '\n'
					
				Error1: .asciiz "Error al abrir el fichero"	#Excepciones posibles
				
				Error2: .asciiz "Fichero vacio"

			.text
			.globl main
			
			
			main:
				
				la $a0, nombre_fichero							#Paso de parametros
				la $a1, cadena
				
				jal Ejercicio1									#Llamada a la funcion Ejercicio1 
				
				li $v0, 10										#Finalizacion del programa 
				syscall
				
				
				
					Ejercicio1:
					
						#Variables locales a la funcion 
						 
						li $s0, 0									#Se almacenaran el numero de caracteres que contiene la cadena
						li $s1, 0									#Se almacenaran el descriptor del fichero 
						li $s2, 0 									#Se almacenaran el numero de caracteres de la palabra leida en cada interaccion
						
						lbu $s3, Espacio							#Se almacena el char que corresponde a un espacio (' ') 
						li $s4, 0 									#Contador de veces que aparece la cadena
						lbu $s5, Salto								#Se almacena un salto de linea 

						#ALmacenamiento de la cadena en un vector, no recibe parametros ya que solo usa la variable global de cadena
						
						Crear_cadena:

							li $t0, 0								#Almacena el caracter 
							move $t1,$a1							#Contador para el desplazamiento por la cadena 
						
							lb $t0, ($t1) 							#Se guarda el primer byte de la cadena en un registro temporal 
							
							bucle:
								
								beqz $t0, fin						#Condicion de parada: cuando se lea algo diferente a un caracter realiza una bif inc.
								
								sb $t0, VCadena($t2)				#Se almacena el char en el vector
								
								
								add $s0, $s0, 1						#Se aumenta el contador de caracteres de la cadena 
								add $t1, $t1, 1						#Se aumenta el contador que se desplaza por el vector 
								add $t2, $t2, 1

								lb $t0, ($t1)						#Se guarda el siguiente character en un registro temporal

								b bucle

							
							fin:
								
								b AperturaFichero					#Continuamos el programa 
								
							
							AperturaFichero:
								
								li $t0, -1
								
								la $a0, nombre_fichero					#Se almacena la direccion en la cual se encuentra el fichero
								lw $a1, tipo_fichero					#Cargamos el tipo de fichero 
								li $v0, 13
								syscall
									
								move $s1, $v0							#Se almacena el descriptor del fichero en una reg. temporal
								
								beq $s1, $t0, ErrorFichero
								
								
							Lectura:
								
								li $t0,0								#Almacena temporalmente el byte (letra de la palabra)
								li $t1,0 								#Contador para posicionar en el vector VFichero
								
								#Lectura del primer byte del fichero

								move $a0, $s1							#Se almacena el descriptor del fichero 
								la $a1, VFichero($t1)		        	#Se establece  la direccion de inicio donde se guardaran los bytes 
								lbu $a2, nbytes 						#Se establece el numero de bytes a leer 
								li $v0, 14								#Codigo de lectura de fichero 
								syscall									#Si devuelve un 1, la lectura es correcta

								beq $v0, $zero, FicheroVacio			#Si devuelve un 0, la lectura del fichero ha finalizado

								lbu $t0, VFichero($t1)					#Se almacena en el registro el primer caracter de la palabra
								
								
								#Lector lee palabra a palabra el fichero
								
								Lector:	

									beq $t0, $s3, Comparador			#Si el byte es un espacio, se sobrentiende que la palabra ha finalizado y procedemos a compararla con la cadena
									beq $t0, $s5, Comparador									#En caso contrario continuamos con la lectura de la palabra


									add $t1, $t1, 1						#Pasamos a la siguiente posicion de memoria
									add $s2, $s2, 1						#Aumentamos el contador de caracteres 

									move $a0, $s1						#Se almacena el descriptor del fichero 
									la $a1, VFichero($t1)				#Se establece  la direccion de inicio donde se guardaran los bytes 
									lbu $a2, nbytes 					#Se establece el numero de bytes a leer 
									li $v0, 14							#Codigo de lectura de fichero 
									syscall
								
										beq $v0, $zero, ComparadorFinal		#Si devuelve un 0, la lectura del fichero ha finalizado
									
										lbu $t0, VFichero($t1)				#Se almacena el byte a imprimir para su posterior comparacion
								
									b Lector
								
								
							Comparador: 
							
								addu $s2, $s2, -1						#Porque empieza a comparar en la 0

								li $t0,0								#Registros temporales para almacenar caracteres
								li $t7,0
								
								li $t3,0
								li $t4,0
									
								li $t1,0								#Registros temporales que funcionan como contadores llevando a cabo el desplazamiento 
								li $t8,0								#por las posiciones de memoria
								
								li $t2,0
								li $t6,0
								li $t5,1
								
							empieza:
								
								lbu $t0, VCadena($t1) 		
								lbu $t7, VFichero($t8)

								
								bucle3:
								
									beq $t0,$t7,iguales
									add $t8,$t8,1
									lbu $t7, VFichero($t8)
									bgeu $t8, $s2, acaba					#cuando se acaban de comprobar todas las letras pasamos a la siguiente comprobacion
									
									b bucle3

								
							acaba:	
								
								#Si llega hasta aqui es porque comparo la primera letra con todas y ninguna es igual
								
								b Lector
								

							iguales:
								
								add $t2, $t1, 1
								add $t6, $t8, 1
								add $t5, $t5, 1
								
								lbu $t3, VCadena($t2)
								lbu $t4, VFichero($t6)
								
								beq $t3, $t4, anadir 					#Si las siguientes letras no son iguales continuamos
								
								add $t8,$t8,1
								b empieza


							anadir: 
								
								bgeu $t5, $s0, anadir2					#Se compara que el caracter sea igual y ademas que sea el ultimo antes de anadir 
								b iguales
								
								anadir2: 
										
										add $s4, $s4, 1					#Se aumenta el numero de palabras encontradas
																		#Una vez encontrada una coincidencia continuamos a la siguiente palabra
								
								b Lector


							ComparadorFinal: 

								addu $s2, $s2, -1						#Porque empieza a comparar en la 0

								li $t0,0								#Registros temporales para almacenar caracteres
								li $t7,0
								
								li $t3,0
								li $t4,0
								
								li $t1,0								#Registros temporales que funcionan como contadores llevando a cabo el desplazamiento 
								li $t8,0								#por las posiciones de memoria
								
								li $t2,0
								li $t6,0	
								
								
							EmpiezaFinal:
								
								lbu $t0, VCadena($t1) 		
								lbu $t7, VFichero($t8)

								
							BucleFinal:
								
								beq $t0,$t7,IgualesFinal
									add $t8,$t8,1
									lbu $t7, VFichero($t8)
									bgeu $t8, $s2, AcabaFinal			#cuando se acaban de comprobar todas las letras pasamos a la siguiente comprobacion
									
									b BucleFinal

									
							AcabaFinal:	
								
								#Si llega hasta aqui es porque comparo la primera letra con todas y ninguna es igual
								
								b finFichero
								

							IgualesFinal:
								
								add $t2, $t1, 1
								add $t6, $t8, 1
								
								lbu $t3, VCadena($t2)					#Cargamos los caracteres a comparar
								lbu $t4, VFichero($t6)
								
								beq $t3, $t4, AnadirFinal 				#Si las siguientes letras no son iguales continuamos
								
								add $t8,$t8,1
								b EmpiezaFinal


							AnadirFinal: 
								
								add $s4, $s4, 1							#El numero de palabras que contienen la cadena es incrementado
								
								b finFichero
								

							
							
							
							finFichero:
								
								move $a0, $s4
								li $v0, 1
								syscall

								#Se cierra el fichero 
								move $a0, $t0							#Almacenamiento del fichero a cerrar
								li $v0, 16								#Codigo de llamada para cerrar fichero
								syscall

								#Finalizacion del programa
								
								jr $ra


							
							
							
							
							
							ErrorFichero:

								la $a0, Error1							#Al detectar el error se imprime por pantalla la cadena Error1
								li $v0, 4
								syscall
								
								jr $ra

							FicheroVacio:
								
								la $a0, Error2							#Al detectar el error se imprime por pantalla la cadena Error1
								li $v0, 4
								syscall
								
								jr $ra
							
