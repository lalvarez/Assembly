			.data
				
				ficheroEntrada: .asciiz "c:\users\ficheroE.txt" 
				
				ficheroSalida: .asciiz "c:\users\ficheroS.txt"
				
				tipo_fichero: .word 0x002			#Fichero tipo lectura-escritura
					
				VFicheroE: .space 1024 				#Espacio donde se almacenaran los bytes leidos
				
				VFicheroS: .space 1024
				
				VNPalabras: .space 1024

				nbytes: .word 0x001
				
				Espacio: .byte ' '					#Cadenas auxiliares
				
				Salto : .byte '\n'
					
				ExtMax: .word 0x256
				
				Longitud: .asciiz "\nLongitud"
				
				LongitudMedia: .asciiz "\nLongitud media: "
				
				NumeroDePalabras: .asciiz "\nNumero de palabras: "
				
				NumeroDeCaracteres: .asciiz "\nNumero de caracteres: "
				
				DosPuntos: .asciiz ": "
				
				Error1: .asciiz "Error al abrir el fichero"
			
				Error2: .asciiz "Fichero vacio"

				numero: .space 1
				
				media: .space 4


			.text
			.globl main
			
			
			main:
			
				la $a0, ficheroEntrada							#Paso de parametros a la funcion Ejercicio1
				la $a1, ficheroSalida
				
				jal Ejercicio2									#Llamada a la funcion Ejercicio1 
				
				li $v0, 10										#Finalizacion del programa 
				syscall
				
			
			
			
			Ejercicio2:
				
					
					#Variables locales
					
					li $s1, 0							#Se almacenaran el descriptor del fichero 
					li $s2, 0 							#Se almacenaran el numero de caracteres de la palabra leida en cada interaccion
					
					lbu $s3, Espacio					#Se almacena en s3 el char que corresponde a un espacio (' ') 
					lbu $s6, Salto
					
					li $s4, 0 							#Contador de palabras del fichero
					li $s5,0 							#Contador de caracteres de todo el fichero
					li $s7,0							#Se almacenaran el descriptor del fichero Salida
					
					move $t8, $a0
					move $t9, $a1
					
					AperturaFichero:
							
							li $t0, -1
							move $a0, $t8						#Se almacena la direccion en la cual se encuentra el fichero
							lw $a1, tipo_fichero				#Cargamos el tipo de fichero 
							li $v0, 13
							syscall
							
							beq $v0, $zero, FinalLectura		#Si devuelve un 0, la lectura del fichero ha finalizado
								
							move $s1, $v0						#Se almacena el descriptor del fichero en una reg. temporal	
							
							beq $s1, $t0, ErrorFichero
								
							Lectura:
								
								li $t0,0							#Almacena temporalmente el byte (letra de la palabra)
								li $t1,0 							#Contador para posicionar en el vector VFicheroE
								li $s2, 0 							#Se almacenaran el numero de caracteres de la palabra leida en cada interaccion
								
								#Lectura del primer byte del fichero

								move $a0, $s1						#Se almacena el descriptor del fichero 
								la $a1, VFicheroE($t1)		        #Se establece  la direccion de inicio donde se guardaran los bytes 
								lbu $a2, nbytes 					#Se establece el numero de bytes a leer 
								li $v0, 14							#Codigo de lectura de fichero 
								syscall								#Si devuelve un 1, la lectura es correcta

								beq $v0, $zero, FicheroVacio		#Si devuelve un 0, la lectura del fichero ha finalizado
								lbu $t0, VFicheroE($t1)
								
								#Lector lee palabra a palabra el fichero, una vez leida y almacenada en un vector, el programa realiza una bif a PalabraLeida

								Lector:	

									beq $t0, $s3, PalabraLeida			#Si el byte es un espacio, se sobrentiende que la palabra ha finalizado y procedemos a comparar
									beq $t0, $s6, PalabraLeida			#En caso contrario continuamos con la lectura de la palabra
										
																		#Impresion de el caracter actual (No necesario)
									move $a0, $t0	 					#Se establece el byte a imprimir 
									li $v0, 11 							#Codigo de llamada para imprimir un tipo char
									syscall

									add $t1, $t1, 1						#Pasamos a la siguiente posicion de memoria
									add $s2, $s2, 1						#Aumentamos el contador de caracteres 
									add $s5, $s5, 1
									
									move $a0, $s1						#Se almacena el descriptor del fichero 
									la $a1, VFicheroE($t1)				#Se establece  la direccion de inicio donde se guardaran los bytes 
									lbu $a2, nbytes 					#Se establece el numero de bytes a leer 
									li $v0, 14							#Codigo de lectura de fichero 
									syscall
									
									beq $v0, $zero, PalabraLeidaFinal	#Si devuelve un 0, la lectura del fichero ha finalizado
									
									lbu $t0, VFicheroE($t1)				#Se almacena el byte a imprimir para su posterior comparacion
									
									b Lector

							
									PalabraLeida:
										
										#En s2 se encuentra almacenado el numero de char de la palabra
										#Almacenamos el contenido que anteriormente habia en la posicion de la pila correspondiente a esa palabra
										
										move $a0, $s3
										li $v0, 11
										syscall
										
										li $t2,0
										
										la $t4, VNPalabras
										
										
										add $t2, $t4, $s2 					#Se determina la posicion en la pila correspondiente a cada palabra
										
										
										
										lbu $t3, ($t2)						#Se almacena el numero de palabras con esa longitud que habia anteriormente
										add $t3, $t3, 1						#Se incrementa
										
										sb $t3, ($t2)						#Se actualiza el valor
										
										b Lectura
										
										
									PalabraLeidaFinal:

										#En s2 se encuentra almacenado el numero de char de la palabra
										#Almacenamos el contenido que anteriormente habia en la posicion de la pila correspondiente a esa palabra
										
										li $t2,0
										
										la $t4, VNPalabras
										
										add $t2, $t4, $s2 					#Se determina la posicion en la pila correspondiente a cada palabra
										lbu $t3, ($t2)						#Se almacena el numero de palabras con esa longitud que habia anteriormente
										add $t3, $t3, 1						#Se incrementa
										
										sb $t3, ($t2)						#Se actualiza el valor
										
										
										FinalLectura:
											
											li $t0, 0
											li $t1, 0
											li $t2, 0
											li $t6, 0
											li $t8, 0
											li $t5,0
											
											la $t4, VNPalabras
											
											addu $t0, $t4, 1
											
											addu $t1, $t4, 256
										   
											contadorPalabras: 
												
												beq $t0, $t1, fin1				#Se recorren cada una de las posiciones de VNPalabras
												
												lbu $t2, ($t0)					#Se almacena el contenido 
																				#Paso de parametros a la funcion ImpresionOcurrencia
												move $a0, $t2					#En $a0 se deja el numero de palabras de esa longitud
												move $a1, $t0					#En $a1 se deja la direccion donde se encuentra, es decir la informacion de la longitud concreta
												
												addu $sp, $sp, -4
												sw $ra, ($sp)
												
												jal ImpresionOcurrencia
												
												lw $ra, ($sp)					#Revertimos la direccion anterior almacenada en la pila
												
												addu $sp, $sp, 4
												
												
												add $s4, $s4, $t2
												addu $t0, $t0, 1
												
												b contadorPalabras
									
								
											fin1: 
												
												b DeterminarMedia
						
						
											ImpresionOcurrencia:
												
												move $t2, $a0
												
												beqz $t2, fin2						#Si no es cero, implica que hay una o mas palabras de esa longitud
													
													move $t3, $a0
													
													la $t4, VNPalabras 				 #x - (x - long )
													sub $t4, $a1, $t4
													
													move $a0, $s3
													li $v0, 11
													syscall
													
													la $a0, Longitud				#Impresion de una cadena String (Longitud)
													li $v0, 4
													syscall
													
													move $a0, $t4					#Impresion del entero que contiene la longitud de la palabra
													li $v0, 1
													syscall
													
													add $t8, $t4, 48				#Se almacena en el vector el dato de la longitud de la palabra
													sb $t8, VFicheroS($t5)
													add $t5, $t5, 1
													
												
													la $a0, DosPuntos				#Impresion de una cadena String (:)
													li $v0, 4
													syscall
													
													move $a0, $t3					#Impresion del entero que contiene el numero de palabras de dicha longitud
													li $v0, 1
													syscall
													
													add $t8, $t3, 48				#Se almacena en el vector el dato de el numero de palabras de dicha longitud
													sb $t8, VFicheroS($t5)
													add $t5, $t5, 1
													
													
													
													move $a0, $t3					#Se deja el parametro como estaba inicialmente 
													
											fin2:
											
												jr $ra                           	#volvemos a la funcion anterior
													
						
												
											DeterminarMedia:
												
																			
												mtc1 $s5,$f5					#Pasamos el valor del numero de palabras de CPU a FPU
												cvt.s.w $f0,$f5					#Pasamos el valor del numero de palabras a coma flotante
												mtc1 $s4,$f4					#Pasamos el valor del numero de caracteres total de CPU a FPU
												cvt.s.w $f1,$f4					#Pasamos el valor del numero de caracteres a coma flotante
												
												div.s $f12,$f0,$f1				#Dividimos los dos valores para hacer la media
												
												
												
												la $a0, LongitudMedia
												li $v0, 4
												syscall

												li $v0, 2						#Imprimimos el valor de la division
												syscall
												
												li $t0, 0
												div $t0, $s5, $s4
												add $t0, $t0, 48
												sb $t0, media
												
												b  FicheroSalida
												
							
							
							
											FicheroSalida:
															
															#Crear fichero salida			#Se trunca el fichero de salida donde se escribiran los datos
															move $a0, $t9
															li $a1, 0x601
															li $a2, 0x1FF
															li $v0, 13
															syscall
															
															move $s7, $v0
															
															div $t3, $t5, 2					#Se calcula el numero de datos obtenidos
															li $t6, 0						#Contador para desplazamiento por el vector 
															la $t0, VFicheroS				#Se almacena la direccion de memoria para posterior lectura
															
													bu:
															bge $t3, $t5, fin
															
															
															move $a0, $s7					#Escribimos los contenidos auxiliares
															la $a1, Longitud
															li $a2, 9
															li $v0, 15
															syscall
															
															move $a0, $s7					#Recorremos el vector recuperando la informacion de la longitud de las palabras
															move $a1, $t0
															li $a2, 1
															li $v0, 15
															syscall
															
															add $t0, $t0, 1

															move $a0, $s7
															la $a1, DosPuntos
															li $a2, 1
															li $v0, 15
															syscall
															
															move $a0, $s7					#Recorremos el vector recuperando la informacion del numero de palabras de la longitud anterior
															move $a1, $t0
															li $a2, 1
															li $v0, 15
															syscall
															
															move $a0, $s7
															la $a1, Salto
															li $a2, 1
															li $v0, 15
															syscall
															
															
															add $t3, $t3,1					#Proseguimos a la siguiente posicion en memoria
															add $t6,$t6,1
															add $t0, $t0, 1

															b bu
															
														
															
													

															fin:
																	
																	move $a0, $s7					#Escribimos los contenidos auxiliares
																	la $a1, LongitudMedia
																	li $a2, 15
																	li $v0, 15
																	syscall
																	
																	move $a0, $s7
																	la $a1, DosPuntos
																	li $a2, 1
																	li $v0, 15
																	syscall
																	
																	move $a0, $s7
																	la $a1, media
																	li $a2, 1
																	li $v0, 15
																	syscall
																
																	#PRUEBA IMPRESION DEL NUMERO DE CHAR DE LA CADENA Y DE LA 1 PALABRA DEL FICHERO

																move $a0, $s3
																li $v0, 11
																syscall
																
																la $a0, NumeroDePalabras
																li $v0, 4
																syscall
																			
																move $a0, $s4
																li $v0, 1
																syscall
																
																move $a0, $s3
																li $v0, 11
																syscall
																
																la $a0, NumeroDeCaracteres
																li $v0, 4
																syscall
																
																move $a0, $s5
																li $v0, 1
																syscall

							
							
																
															FINALPROGRAMA:
																
																#Finalizacion del programa
																#Se cierra el fichero 
																
																move $a0, $s1			#Almacenamiento del fichero a cerrar
																li $v0, 16				#Codigo de llamada para cerrar fichero
																syscall
																
																jr $ra

																
															FicheroVacio:
																	
																	la $a0, Error2							#Al detectar el error se imprime por pantalla la cadena Error1
																	li $v0, 4
																	syscall
																	
																	jr $ra
															
															ErrorFichero:

																	la $a0, Error1							#Al detectar el error se imprime por pantalla la cadena Error1
																	li $v0, 4
																	syscall
																	
																	jr $ra
