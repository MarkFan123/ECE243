 /* Program to add 1 to 30 using a loop */
 
.global _start
_start:
	
	movi r8, 1		# initialize r8 as 1
	movi r9, 30		# r9 as 30, the ending condition
	movi r12, 0		# r12 to store the sum
	

myloop: add r12, r12, r8		# add r8 to the sum everytime
		addi r8, r8, 1			# add 1 to r8 each time
		ble r8, r9, myloop		# if r8 < r9, stop the program
		
done: br done