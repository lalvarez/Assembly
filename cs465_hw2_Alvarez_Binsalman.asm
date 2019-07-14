
# Sarah Binsalman G:01037417
#Laura Alvarez G01166085
# CS465

#The algorithm of this program reads one number, allocate size of n from the heap and return the address of the array in main 
# Then main passes the needed perameters to init to  loop and inisalize the values and return to main 
# another call from main is done after preparing the perameter to print_value to print each elemement and collect the sum of the elemments.
# print_values jump to print sum when done to print the sum of the array  
# print_sum print the value and return to main 
# main exit the program
 



# these are used for the printing 
.data 
	prompt: .asciiz "Enter the size of the array: "
	prompt1: .asciiz "Value at array index "
	prompt2: .asciiz " is "
	prompt3: .asciiz "Sum of the values is  "
	newline: .asciiz "\n"	



.text 
	
main:	
	# prompt the user to enter N
	li $v0, 4		# system call
	la $a0, prompt		# print the sentence to prompt the user
	syscall
	
	# get the user inpit
	li $v0, 5		#system call
	syscall 
	
	add $t1,$zero, $v0	# store the value of the user in $t1 to save it from changing and use it in for loop
	add $a0, $zero, $v0	# pass the value to allocate array size N
	li $v0, 9
	syscall
	
	addi $s0, $v0, 0 	#store the address of the array A in $s0 to save from changing 
	
	#Passing the parameters to the function init
	
	#In $a0 we have the first parameter N
	move $a1, $s0		 #address
	#Calling the function init
	jal init
	
	#Passing the parameters to the function values
	move $a0, $s1 #N
	move $a1, $s0 #address
	#Calling the function values
	jal print_values	
	
	#Exit program
	li $v0, 10
	syscall
	

init:   
	#This function receives the parameters $a0 = N and $a1 = address og the array
	# $a1 used to iterate over the loop instead of $s0 to maintain a 
	#reference to the beginning of the Array in future interactions
	
	
	#Initializating variables
	li $t2, 1 		# i = $t2  used as the index in the array 
	li $t3, 1 		# $t3 used to storage the value of the previous element in the array while looping
	li $t4, 0		# $t4 is going to storage the first member of the operation
	li $t5, 1		# $t5 used to calculate the 2's power
	addi $t6, $a1, 0  	# $t6 used to iterate over the loop instead of $s0 to maintain a 
				#reference to the beginning of the Array in future interactions 	
	
	add $s1, $zero, $a0	
	sw $t3, ($t6) #A[0] =1

	# for loop to initialize the values of the array as following A[i]= i*A[i-1]+2i		
loop0:	beq $t2, $s1, fin_init	# strats form i = 1 to N-1
	mul $t4, $t2, $t3 	# $t4 = i * A[i-1]
	mul $t5, $t5, 2 	# $t5 = 2^i
	add $t4, $t4, $t5 	# $t4 = i * A[i-1]+2^i
	add $t6, $t6, 4		# access to the next element 
	sw $t4, ($t6)		# A[i] = i * A[i-1]+2^i
	lw $t3, ($t6)		#t3  = the current element which will be the previous in the next iteration 
	addi $t2, $t2, 1	# increment index i 
	j loop0			# keep looping 
	
fin_init: 

	jr $ra			#We go back to main

print_values: 
	
	li $t2,0		# initialize the index to the beginning of the array
	li $t3, 0
	li $t4, 0		# reset and used for adding the sum of array's elements
	add $t6, $zero, $a1	# initialize the pointer to the beginning of the array again
	move $s1, $a0		#We save the parameter N
	
	add $sp, $sp -4		#Making space in the stack
	sw $ra, ($sp)		#Saving $ra before calling print in the loop
	
loop:	
	# loop over again, add the sum and print the value at each index 
	beq $t2, $s1, print_sum	# stop when reaching the end of the array 
	lw $t3, ($t6)		# load the element 
	add $a0, $zero, $t2	# prepare the arguments form printing the index and value print(index, value)
	add $a1, $zero, $t3	# $a0 = index and $a1= value
	jal print		# print "Value at array index i is A[i]
	add $t4, $t4, $t3	#adding to the sum to register $t4
	add $t6, $t6, 4 	# increment the array to the next address in memory
	addi $t2, $t2, 1 	# increment i 
	j loop			# keep looping 

print_sum:

	li $v0, 4		# system call
	la $a0, prompt3		# print the sentence 
	syscall
	
	add $a0, $zero, $t4	# pass the value to the system to be printed
	li $v0, 1		# system call to print the number 
	syscall
	
	lw $ra, ($sp)		#Restore $ra value to go to main
	add $sp, $sp, 4		#Clean the stack frame
	jr $ra			#Go to main
	

print: 
	# this prints the index and values of each element of the array
	# $a0 = index 	$a1 = value 
	add $t1, $zero, $a0
	add $t7, $zero, $a1
	
	li $v0, 4		#"Value at array index"
	la $a0, prompt1		
	syscall
	
	li $v0, 1		#" i" 
	add $a0, $zero, $t1
	syscall
	
	li $v0, 4		# "is "
	la $a0, prompt2
	syscall
	
	li $v0, 1		#" x"
	add $a0, $zero, $t7
	syscall
	
	li $v0, 4		# print newline
	la $a0, newline
	syscall
	
	jr $ra