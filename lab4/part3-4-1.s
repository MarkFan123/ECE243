.global _start
		.equ TIMER_BASE, 0xFF202000
		.equ LEDs, 0xff200000
		.equ BUTTON, 0xff200050

_start: movia r20, TIMER_BASE      # base address of timer
	stwio r0, 0(r20)         # clear the TO (Time Out) bit in case it is on
    
	movia r8, 25000000
	srli  r9, r8, 16           # shift right by 16 bits
    andi  r8, r8, 0xFFFF       # mask to keep the lower 16 bits
    stwio r8, 0x8(r20)         # write to the timer period register (low)
    stwio r9, 0xc(r20)         # write to the timer period register (high)
    
	movi r8, 0b0110           # enable continuous mode and start timer
    stwio r8, 0x4(r20)         # write to the timer control register to 
	
	movia r21,LEDs
	movi r10, 0			# r10 stores the number to be output
	movi r11, 0xff		# maximum value 255
	movia r12, BUTTON	# r12 is the address of button
	
start: ldwio r13, 0xc(r12)		# load button edge capture value
	beq r13, r0, start
	
	# Clear the button edge capture register
	movi r14, 0xf
	stwio r14, 0xc(r12)

	# If counting is active, jump to increment, else jump to button
	br increment
	
stop: ldwio r13, 0xc(r12)		# load button edge capture value
	beq r13, r0, increment
	
	# Clear the button edge capture register
	movi r14, 0xf
	stwio r14, 0xc(r12)

	# If counting is active, jump to increment, else jump to button
	br start
			
increment: stwio r10, 0(r21)		# write into LED
	bge r10, r11, reset
	addi r10, r10, 1
	br ploop

reset: movi r10, 0
	br ploop

ploop: ldwio r8, 0x0(r20)         # read the timer status register
	andi r8, r8, 0b1          # mask the TO bit
	beq r8, r0, ploop     # if TO bit is 0, wait
	stwio r0, 0x0(r20)         # clear the TO bit
	br stop
			
			