.equ KEY, 0xFF200050
.equ LED, 0xFF200000

.global _start
_start:
	movia r8, KEY

poll: ldwio r9, (r8)
	andi r11, r9, 0x1
	bne r11, r0, reset		# KEY0
	andi r11, r9, 0x2
	bne r11, r0, increment	# KEY1
	andi r11, r9, 0x4
	bne r11, r0, decrement	# KEY2
	andi r11, r9, 0x8
	bne r11, r0, blank		# KEY3
	br poll
	
reset: movi r12, 0x1
	br display

increment: movi r13, 15
	bgt r12, r13, display
	addi r12, r12, 0x1
	br display

decrement: movi r13, 1
	blt r12, r13, display
	subi r12, r12, 0x1
	br display

blank: movi r12, 0x0
	br display

display: movia r20, LED
	stwio r12, (r20)
	
	ldwio r9, (r8)
	beq r9, r0, poll
	br display
	
	