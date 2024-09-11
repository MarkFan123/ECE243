.text  # The numbers that turn into executable instructions
.global _start
_start:

/* r13 should contain the grade of the person with the student number, -1 if not found */
/* r10 has the student number being searched */


	movia r10, 10392584		# r10 is where you put the student number being searched for

/* Your code goes here  */
	movia r11, Snumbers
	ldw r12, (r11)		# r12 stores the current student number being stored
	
	movia r14, Grades
	
loop: 
	beq r10, r12, finished		# compare the current student number
	beq r12, r0, notFound			# if new sn=0, return
	
	addi r11, r11, 4			# i+=1 
	addi r14, r14, 1
	ldw r12, (r11)				# store new student number
	br loop
	

finished: 
	ldb r13, (r14)
	movia r15, result
	stb r13, (r15)
	br iloop
	
notFound: 
	movi r13, -1		# r13 <- -1, in the case where no grade is returned
	stb r13, (r15)
	br iloop

iloop: br iloop


.data  	# the numbers that are the data 

/* result should hold the grade of the student number put into r10, or
-1 if the student number isn't found */ 

result: .byte 0
		.align 2
		
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .byte 99, 68, 90, 85, 91, 67, 80
        .byte 66, 95, 91, 91, 99, 76, 68  
        .byte 69, 93, 90, 72
	
	