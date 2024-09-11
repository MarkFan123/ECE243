/******************************************************************************
 * Write an interrupt service routine
 *****************************************************************************/

.section .exceptions, "ax"

IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 16          # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
		stw     r20, 8(sp)        
        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 12(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        call    KEY_ISR             # if yes, call the pushbutton ISR

END_ISR:
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     ea, 12(sp)
        addi    sp, sp, 16         # restore stack pointer
        eret   # return from exception
		
KEY_ISR:
		subi    sp, sp, 32
		stw     r4, 0(sp)
		stw     r5, 4(sp)
		stw		ra, 8(sp)
		stw 	r3, 12(sp)
		stw     r11, 16(sp)
		stw     r12, 20(sp)
		stw		r13, 24(sp)
		stw 	r14, 28(sp)
		movi r11, 1
		movi r12, 2
		movi r13, 4
		movi r14, 8
		movia r3, 0xFF200050 /* Address of switches. */
		ldwio r4, 0xC(r3)
		beq r4, r11, loop1
		beq r4, r12, loop2
		beq r4, r13, loop3
		beq r4, r14, loop4
		br endkey
		
loop1:
	movia r11, HEX_BASE1
	ldwio r12, (r11)
	andi  r13, r12, 0b1111111
	bne r13, r0, fuk1
	movi r14,0
	movi r4, 0
	movi r5, 0
	CALL HEX_DISP
	br endkey
	
loop2:
	movia r11, HEX_BASE1
	ldwio r12, (r11)
	andi  r13, r12, 0b111111100000000
	bne r13, r0, fuk2
	movi r4, 1
	movi r5, 1
	CALL HEX_DISP
	br endkey
loop3:
	movia r11, HEX_BASE1
	ldwio r12, (r11)
	srli r12, r12, 16 
	andi  r13, r12, 0b1111111
	bne r13, r0, fuk3
	movi r4, 2
	movi r5, 2
	CALL HEX_DISP
	br endkey
loop4:	
	movia r11, HEX_BASE1
	ldwio r12, (r11)
	srli r12, r12, 24 
	andi  r13, r12, 0b1111111
	bne r13, r0, fuk4
	movi r4, 3
	movi r5, 3
	CALL HEX_DISP
	br endkey
	
fuk1:
	movi r4, 0b10000
	movi r5, 0
	CALL HEX_DISP
	br endkey
	
fuk2:
	movi r4, 0b10000
	movi r5, 1
	CALL HEX_DISP
	br endkey
	
fuk3:
	movi r4, 0b10000
	movi r5, 2
	CALL HEX_DISP
	br endkey
	
fuk4:
	movi r4, 0b10000
	movi r5, 3
	CALL HEX_DISP
	br endkey
	
endkey:
		ldw 	r4, 0(sp)
		ldw 	r5, 4(sp)
		ldw 	ra, 8(sp)
		ldw 	r3, 12(sp)
		ldw     r11, 16(sp)
		ldw     r12, 20(sp)
		ldw		r13, 24(sp)
		ldw 	r14, 28(sp)
		addi	sp, sp, 32
		ret		
		

HEX_DISP:
		subi    sp, sp, 28
		stw    r2, 0(sp)
		stw    r4, 4(sp)
		stw    r5, 8(sp)
		stw    r6, 12(sp)
		stw    r8, 16(sp)
		stw    ra, 20(sp)
		stw     r7, 24(sp)
		
		movia    r8, BIT_CODES         # starting address of the bit codes
	    andi     r6, r4, 0x10	   # get bit 4 of the input into r6
	    beq      r6, r0, not_blank 
	    mov      r2, r0
	    br       DO_DISP
not_blank:  andi     r4, r4, 0x0f	   # r4 is only 4-bit
            add      r4, r4, r8            # add the offset to the bit codes
            ldb      r2, 0(r4)             # index into the bit codes

#Display it on the target HEX display
DO_DISP:    
			
			movia    r8, HEX_BASE1         # load address
			movi     r6,  4
			blt      r5,r6, FIRST_SET      # hex4 and hex 5 are on 0xff200030
			sub      r5, r5, r6            # if hex4 or hex5, we need to adjust the shift
			addi     r8, r8, 0x0010        # we also need to adjust the address
FIRST_SET:
			slli     r5, r5, 3             # hex*8 shift is needed
			addi     r7, r0, 0xff          # create bit mask so other values are not corrupted
			sll      r7, r7, r5 
			addi     r4, r0, -1
			xor      r7, r7, r4  
    		sll      r4, r2, r5            # shift the hex code we want to write
			ldwio    r5, 0(r8)             # read current value       
			and      r5, r5, r7            # and it with the mask to clear the target hex
			or       r5, r5, r4	           # or with the hex code
			stwio    r5, 0(r8)		       # store back
END:		
			movia r2, KEYs
			movi r4, 0b1111
			stwio r4, 12(r2)	
			ldw    r2, 0(sp)
			ldw    r4, 4(sp)
			ldw    r5, 8(sp)
			ldw    r6, 12(sp)
			ldw    r8, 16(sp)
			ldw    ra, 20(sp)
			ldw     r7, 24(sp)
			addi    sp, sp, 28
			
			ret

/*********************************************************************************
 * set where to go upon reset
 ********************************************************************************/
.section .reset, "ax"
        movia   r8, _start
        jmp    r8

/*********************************************************************************
 * Main program
 ********************************************************************************/
.equ LEDs, 0xff200000
.equ KEYs, 0xff200050
.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030
.text
.global  _start
_start:
	movia sp, 0x20000 # initialize the stack pointer (used in interrupt handler)
	movia r2, KEYs # address of key pushbuttons in r2
	movi r14, 0xf # need to affect bit 0 using r4 of several registers!
	stwio r14, 0xC(r2) # this clears the edge capture bit for KEY0 if it was on, writing into the edge capture register
	stwio r14, 8(r2) # turn on the interrupt mask register bit 0 for KEY 0 so that this causes
	movi r5, 0x2 # used to turn on bit 1 below
	movi r6, 0x1
	wrctl ctl3, r5 # ctl3 also called ienable reg - bit 1 enables interupts for IRQ1 which is the key buttons
	wrctl ctl0, r6 # ctl 0 also called status reg - bit 0 is Proc Interrupt Enable (PIE) bit - set it to 1.
	
	br IDLE


        /*
        1. Initialize the stack pointer
        2. set up keys to generate interrupts
        3. enable interrupts in NIOS II
        */
IDLE:   br  IDLE

			
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001
.end