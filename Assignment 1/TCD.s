
	area	tcd,code,readonly
	export	__main
__main
	
	mov r0,#0x1;
	ldr r3,=nums
	ldr r7,=0x40000000
	ldr r7,=sixtyfour
	ldr r0, [r3] ,#4
	
loop	
	bl fact
	bl store
	mov r0,#1
	mov r1,#0
	ldr r0, [r3] ,#4
	cmp r0, #0
	bne loop
	
fin		b fin


store
	
	str r1, [r7], #4
	str r0, [r7], #4
	;stmia r7, {r1,r0}
	
	bx lr

fact ; part of fact that initialises neccessary registers 
	stmfd sp!,{r6}
	mov r6,#0
	
	
fact2		;fact2 is a part of fact 
	stmfd sp!,{r2,r5,r14} ; we modify these registers, so save them in advance
	cmp r0,#0 ; this sets the c bit anyway sooooo
	addseq r0,r0,r0 ;this clears the c bit
	moveq r0,#1
	bxeq lr
	mov r5,r0
	sub r0,#1
	bl fact2
	umull r6,r8,r5,r6
	umull r0,r1,r5,r0
	add r1, r6
	mov r6, r1
	cmp r8,#1;	sets carry flag if it has been determined that it will overflow
	movcs r0,#0 ; if overflow sets r0,r1 to 0
	movcs r1,#0
	ldmfd sp!,{r2,r5,r14} ; restore the original contents of the registers
	bx lr
	
	
	

	
	area	tcdrodata,data,readonly
nums dcd	5
	dcd	14
	dcd	20
	dcd	30
	dcd 0 ; i used a 0 to terminate data reading 
	

	area tcddata,DATA,readwrite
sixtyfour	space 4 * 8

	
	
	
		

	end