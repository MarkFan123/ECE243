.text
/* Program to Count the number of 1’s in a 32-bit word,
located at InputWord */
.global _start
_start:
/* Your code here */
	movi r10, 0			# store the answer in r10
	movi r11, InputWord	# r11 store the address of input word
	ldw r8, (r11)		# r8 has the input word
	
loop:
	andi r9, r8, 1
	add r10, r10, r9	# add r9 (the and result) to r13 (which stores the final answer)
	srli r8, r8, 1
	beq r8, r0, finished
	br loop
	
finished:
	movi r12, Answer
	stw r10, (r12)

endiloop: br endiloop
.data
InputWord: .word 0x4a01fead
Answer: .word 0