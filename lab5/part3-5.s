/******************************************************************************
* Write an interrupt service routine
*****************************************************************************/
.section .exceptions, "ax"
IRQ_HANDLER:
	# save registers on the stack (et, ra, ea, others as needed)
	subi sp, sp, 16 		# make room on the stack
	stw et, 0(sp)
	stw ra, 4(sp)
	stw r20, 8(sp)
	
	rdctl et, ctl4 			# read exception type
	beq et, r0, SKIP_EA_DEC # not external?
	subi ea, ea, 4 			# decrement ea by 4 for external interrupts

SKIP_EA_DEC:
	stw ea, 12(sp)
	andi r20, et, 0x2 		# check if interrupt is from pushbuttons
	beq r20, r0, TIME_DEC 	# if not, ignore this interrupt
	call KEY_ISR 			# if yes, call the pushbutton ISR
	br END_ISR

TIME_DEC:
	andi r20, et, 0x1 		# check if interrupt is from TIMER
	beq r20, r0, END_ISR 	# if not, ignore this interrupt
	call TIME_ISR
	br END_ISR      # if yes, call the pushbutton ISR
	
END_ISR:
	ldw et, 0(sp) 			# restore registers
	ldw ra, 4(sp)
	ldw r20, 8(sp)
	ldw ea, 12(sp)
	addi sp, sp, 16 		# restore stack pointer
	eret 					# return from exception
	
TIME_ISR:
	subi sp, sp, 32
	stw r4, 0(sp)
	stw r5, 4(sp)
	stw ra, 8(sp)
	stw r3, 12(sp)
	stw r11, 16(sp)
	stw r12, 20(sp)
	stw r13, 24(sp)
	stw r14, 28(sp)
	
	movia r3, LEDs
	movia r4, COUNT
	movia r14, TIMER_BASE      # base address of timer
    stwio r0, 0(r14)         # clear the TO (Time Out) bit in case it is on
	ldw r5, (r4)
	movia r11, RUN
	ldw r12, (r11)
	bne r12, r0, increment
	br endtime

increment:
	addi r5, r5, 1
	br endtime

endtime:
	stw r5, (r4)
	stw r5, (r3)
	
	ldw r4, 0(sp)
    ldw r5, 4(sp)
	ldw ra, 8(sp)
	ldw r3, 12(sp)
	ldw r11, 16(sp)
	ldw r12, 20(sp)
	ldw r13, 24(sp)
	ldw r14, 28(sp)
	addi sp, sp, 32
	ret	
	 
KEY_ISR:
	subi    sp, sp, 32
	stw     r4, 0(sp)
	stw     r5, 4(sp)
	stw		ra, 8(sp)
	stw		r3, 12(sp)
	stw		r11, 16(sp)
	stw		r12, 20(sp)
	stw		r13, 24(sp)
	stw		r14, 28(sp)
	movia	r3, 0xFF200050 /* Address of switches. */
	ldwio	r4, 0xC(r3)
	bne	r4, r0, loop1
	br endkey
	
loop1:
		movia r11, RUN
		ldw r12, (r11)
		xori r12, r12, 1
		stw r12, (r11)
		br endkey
		
endkey:
		movia r2, BUTTON
		movi r4, 0b1111
		stwio r4, 12(r2)
		ldw		r4, 0(sp)
		ldw		r5, 4(sp)
		ldw		ra, 8(sp)
		ldw		r3, 12(sp)
		ldw		r11, 16(sp)
		ldw		r12, 20(sp)
		ldw		r13, 24(sp)
		ldw		r14, 28(sp)
		addi	sp, sp, 32
		ret
/*********************************************************************************
* set where to go upon reset
********************************************************************************/
.section .reset, "ax"
	movia r8, _start
	jmp r8
/*********************************************************************************
* Main program
********************************************************************************/
.text
.global  _start
		.equ TIMER_BASE, 0xFF202000
		.equ LEDs, 0xff200000
		.equ BUTTON, 0xff200050
_start:
    /* Set up stack pointer */
    call    CONFIG_TIMER        # configure the Timer
    call    CONFIG_KEYS         # configure the KEYs port
    /* Enable interrupts in the NIOS-II processor */

    movia   r8, LEDs        	# LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
	movia 	r12, BUTTON			# r12 is the address of button

LOOP:
    ldw     r10, 0(r9)          # global variable
    stwio   r10, 0(r8)          # write to the LEDR lights
    br      LOOP

CONFIG_TIMER: movia r20, TIMER_BASE      # base address of timer
	stwio r0, 0(r20)         # clear the TO (Time Out) bit in case it is on
    
	movia r8, 25000000
	srli  r9, r8, 16           # shift right by 16 bits
    andi  r8, r8, 0xFFFF       # mask to keep the lower 16 bits
    stwio r8, 0x8(r20)         # write to the timer period register (low)
    stwio r9, 0xc(r20)         # write to the timer period register (high)
    
	movi r8, 0b0111            # enable continuous mode and start timer
    stwio r8, 0x4(r20)         # write to the timer control register to 
	
	movi r5, 0x3 # used to turn on bit 1 below
	movi r6, 0x1
	wrctl ctl3, r5 # ctl3 also called ienable reg - bit 1 enables interupts for IRQ1 which is the key buttons
	wrctl ctl0, r6 # ctl 0 also called status reg - bit 0 is Proc Interrupt Enable (PIE) bit - set it to 1.
	ret

CONFIG_KEYS: movia sp, 0x20000 # initialize the stack pointer (used in interrupt handler)
	movia r2, BUTTON # address of key pushbuttons in r2
	movi r14, 0xf # need to affect bit 0 using r4 of several registers!
	stwio r14, 0xC(r2) # this clears the edge capture bit for KEY0 if it was on, writing into the edge capture register
	stwio r14, 8(r2) # turn on the interrupt mask register bit 0 for KEY 0 so that this causes
	movi r5, 0x3 # used to turn on bit 1 below
	movi r6, 0x1
	wrctl ctl3, r5 # ctl3 also called ienable reg - bit 1 enables interupts for IRQ1 which is the key buttons
	wrctl ctl0, r6 # ctl 0 also called status reg - bit 0 is Proc Interrupt Enable (PIE) bit - set it to 1.
	ret
	

.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.end