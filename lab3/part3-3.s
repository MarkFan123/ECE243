.text
/* Program to Count the number of 1’s and Zeroes in a sequence of 32-bit words,
and determines the largest of each */
.global _start
_start:
/* Your code here */
	movia r12, TEST_NUM	# r10 stores the address of input word
	movi r5, 0		# stores the largest ones number
	movi r6, 0		# stores the largest zeros number

inputOne: 
	ldw r4, (r12)
	beq r4, r0, finished	# if we run out of number, go to examine largest ones and zeros
	call ONES
	bge r2, r5, changeOne
	br inputZero
	
inputZero:
	ldw r4, (r12)
	movia r13, 0xffffffff
	xor r4, r4, r13
	call ONES
	addi r12, r12, 4
	bge r2, r6, changeZero
	br inputOne
	
finished: 
	movi r7, LargestOnes
	movi r8, LargestZeroes
	stw r5, (r7)
	stw r6, (r8)

endiloop: br endiloop

changeZero:
	mov r6, r2		# update the max zeros
	br inputOne
	
changeOne:
	mov r5, r2
	br inputZero
	

ONES: # input r4 return r2
	movi r2, 0			# store the answer in r2
	
loop:
	andi r9, r4, 1
	add r2, r2, r9	# add r9 (the and result) to r2 (which stores the final answer)
	srli r4, r4, 1
	beq r4, r0, return
	br loop
	
return: 
	ret


.data
TEST_NUM: .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
.word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
.word 0 # end of list
LargestOnes: .word 0
LargestZeroes: .word 0