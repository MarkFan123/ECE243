.text
/* Program to Count the number of 1’s in a 32-bit word,
located at InputWord */
.global _start
_start:
/* Your code here */
	movi r11, InputWord	# r11 store the address of input word
	ldw r4, (r11)		# r4 has the input word
	call ONES
	movi r12, Answer
	stw r2, (r12)

endiloop: br endiloop

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
InputWord: .word 0x4a01fead
Answer: .word 0