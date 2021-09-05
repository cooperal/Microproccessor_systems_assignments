
	area	tcd,code,readonly
	export	__main
__main
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU	0xE0028010

	;str r1,[r0]		;seems to only set set anyway
	ldr r0,=IO1DIR
	mov r1,#0x00FF0000	;mask for bits 23-16
	str r1,[r0]			; set as outputs
	ldr	r0,=IO1PIN; point to the pin register of GPIO1
	mov r4,#0x0F000000 ;mask for input pins
	mov r10,#0 ;D
	mov r12,#0x1
	
loop
	ldmfd sp!,{r5,r6,r7,r8}; recall last pin value

	bl getpinvals
	stmfd sp!,{r5,r6,r7,r8} ;remember last pin value
	
	b loop ; poll time 
	
fin		b fin


getpinvals
	
	ldr r2,[r0] ; current value of pin
	and r3,r2,r4 ; gets input pins
	stmfd sp!,{r4,r14}
	
	lsr r4,r3,#24
	and r3,r4,r12
	mov r11,#24
	mov r9, r5
	bl checkpinvals
	mov r5,r3 ;stores for last state
	
	lsr r4,#1
	and r3,r4,r12 ;r12 is a mask to remove upper bits while checking
	mov r11,#25
	mov r9, r6
	bl checkpinvals
	mov r6,r3 ;stores for last state
	
	lsr r4,#1
	and r3,r4,r12
	mov r11,#26
	mov r9, r7
	bl checkpinvals
	mov r7,r3 ;stores for last state
	
	lsr r4,#1
	and r3,r4,r12
	mov r11,#27
	mov r9, r8
	bl checkpinvals
	mov r8,r3 ;stores for last state
	
	ldmfd sp!,{r4,r14};
	bx lr

	
checkpinvals
	stmfd sp!,{r14}
	
	cmp r3,r9	;if (r3!= r9 && r3 == 0)
	blne nestedif 
	ldmfd sp!,{r14};
	bx lr

nestedif
	stmfd sp!,{r14}
	cmp r3,#0
	bleq displayup
	ldmfd sp!,{r14};
	bx lr 
	
displayup
	stmfd sp!,{r0,r4,r14}
	
	cmp r11,#24 ;control flow for button24
	addeq r10,#1
	
	cmp r11,#25;control flow for button25
	subeq r10,#1
	
	cmp r11,#26;control flow for button26
	lsleq r10,#1
	cmp r10,#0x100	;limits to 8 bits
	subcs r10,#0x100
	
	cmp r11,#27;control flow for button27
	lsreq r10,#1
	
	ldr r0,=IO1CLR ;clears set pin first 
	mov r4,#0xFFFFFFFF
	str r4,[r0]
	
	ldr r0,=IO1SET 
	lsl r4,r10,#16
	str r4,[r0] ; puts D on set pit to output
	ldmfd sp!,{r0,r4,r14};
	bx lr
	
	area	tcdrodata,data,readonly
 
	

	area tcddata,DATA,readwrite

	
	
	
		

	end