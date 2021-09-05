

	area	tcd,code,readonly
	export	__main
__main
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU	0xE0028010
MEM	EQU 0x40000000 ;memory

	; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5		; UM, Table 58

; Initialise the VIC , most of this is yoinked from lab code
	ldr	r0,=VIC			; looking at you, VIC!

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   	; remove any pending interrupt (may not be needed)
	
	ldr r0,=IO1DIR ; lets set it all as an output 
	mov r1, #0xFFFFFFFF 
	str r1, [r0]	;  

; Initialise Timer 0
	ldr	r0,=T0			; looking at you, Timer 0!

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]

	ldr	r1,=(14745600/1600)-1	 ; 625 us = 1/1600 second , ticks that often
	;ldr	r1,=(18432000)-1
	;ldr	r1,=(14745600/3) - 2
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]

;from here, initialisation is finished, so it should be the main body of the main program
loop
	bl btoBCD
	bl display
	
	b loop 



fin	b fin



btoBCD
	stmfd	sp!,{r0-r1}
	ldr r0,=MEM ; check ticks from the memory
	ldr r1,[r0]
	cmp r1,#1600 ; at one second, increment and set memory value to 0
	addeq r4,#1
	moveq r1,#0
	streq r1,[r0]
	
	cmp r4,#10	;seconds
	addeq r5,#1
	moveq r4,#0
	
	
	cmp r5,#6
	addeq r6,#1
	moveq r5,#0
	
	cmp r6,#10 ;minutes
	addeq r7,#1
	moveq r6,#0
	
	cmp r7,#6
	addeq r8,#1
	moveq r7,#0
	
	cmp r8, #10 ;hours
	addeq r9,#1
	moveq r8,#0
	
	cmp r9,#2 ; if 24 hours reset
	cmpeq r8,#4
	moveq r8,#0
	moveq r9,#0
	
	ldmfd	sp!,{r0-r1}
	bx lr
	
display
	stmfd	sp!,{r0-r1}
	
	ldr r0,=IO1CLR ;clear all
	mov r1,#0xFFFFFFFF
	str r1,[r0]
	
	mov r10,r9 ;hours
	lsl r10,#4
	add r10,r8
	lsl r10,#4
	add r10,#0xF
	lsl r10,#4
	
	add r10,r7 ;minutes
	lsl r10,#4
	add r10,r6
	lsl r10,#4
	
	add r10,#0xF ;seconds
	lsl r10,#4 ;adding all into a settable no
	add r10,r5
	lsl r10,#4
	add r10,r4
	
	
	ldr r0,=IO1SET
	str r10,[r0] ;set output on GPIO
	
	
	ldmfd	sp!,{r0-r1}
	bx lr
	
	area	InterruptStuff, CODE, READONLY
irqhan	
	sub	lr,lr,#4
	stmfd	sp!,{r0-r1,lr}	; the lr will be restored to the pc

;this is the body of the interrupt handler
	ldr r0,=MEM
	ldr r1,[r0]
	add r1,#1	;ticks 1600 times a second
	str r1,[r0] ;stores ticks in memory
	
;here you'd put the unique part of your interrupt handler
;all the other stuff is "housekeeping" to save registers and acknowledge interrupts
	
	
;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC

	ldmfd	sp!,{r0-r1,pc}^	; return from interrupt, restoring pc from lr
				; and also restoring the CPSR
	
	area	tcdrodata,data,readonly
 
	

	area tcddata,DATA,readwrite

	
	
	
		

	end