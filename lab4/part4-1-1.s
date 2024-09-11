.global _start
		.equ TIMER_BASE, 0xFF202000
		.equ LEDs, 0xff200000
		.equ BUTTON, 0xff200050

_start: movia r20, TIMER_BASE      # base address of timer
	stwio r0, 0(r20)         # clear the TO (Time Out) bit in case it is on
    
	movia r8, 1000000
	srli  r9, r8, 16           # shift right by 16 bits
    andi  r8, r8, 0xFFFF       # mask to keep the lower 16 bits
    stwio r8, 0x8(r20)         # write to the timer period register (low)
    stwio r9, 0xc(r20)         # write to the timer period register (high)
    
	movi r8, 0b0110           # enable continuous mode and start timer
    stwio r8, 0x4(r20)         # write to the timer control register to 
	
	movia r21,LEDs
	movi r10, 0			# r10 stores the hundreds of seconds
	movi r11, 0			# r11 stores the seconds
	movi r12, 99		# maximum value 99
	movi r13, 7
	movia r14, BUTTON	# r13 is the address of button
	
start: ldwio r15, 0xc(r14)		# load button edge capture value
	beq r15, r0, start
	
	# Clear the button edge capture register
	movi r16, 0xf
	stwio r16, 0xc(r14)

	# If counting is active, jump to increment, else jump to button
	br increment
	
stop: ldwio r15, 0xc(r14)		# load button edge capture value
	beq r15, r0, increment
	
	# Clear the button edge capture register
	movi r16, 0xf
	stwio r16, 0xc(r14)

	# If counting is active, jump to increment, else jump to button
	br start
			
increment: slli r17, r11, 7
	add r17, r17, r10		
	stwio r17, (r21)		# write into LED
	bge r10, r12, increment_seconds
	addi r10, r10, 1
	br ploop
	
increment_seconds: movi r10, 0
	bge r11, r13, reset
	addi r11, r11, 1
	br ploop

reset: movi r11, 0
	br ploop

ploop: ldwio r8, 0x0(r20)         # read the timer status register
	andi r8, r8, 0b1          # mask the TO bit
	beq r8, r0, ploop     # if TO bit is 0, wait
	stwio r0, 0x0(r20)         # clear the TO bit
	br stop
			
			