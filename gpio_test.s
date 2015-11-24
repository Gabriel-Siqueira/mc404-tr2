.section .iv,"a"
	
_start:		

interrupt_vector:

	b		RESET_HANDLER

.text
.align 4

RESET_HANDLER:
.set GPIO_BASE, 0x53F84000
.set GPIO_DR,		0x0
.set GPIO_GDIR, 0x4
.set GPIO_PSR,  0x8

@ insere em r1 o endereco base para configurar o GPIO
	ldr  r1, =GPIO_BASE

	@ configura corretamente os pinos de entrada e saida
	ldr r0, =0xFFFC003E
	str r0, [r1, #GPIO_GDIR]

	mov r0, #30

	@ Seta MOTOR0_WRITE para inicializar a escrita
	ldr  r2, [r1, #GPIO_DR]
	orr  r2, r2,  #0x00040000
	str  r2, [r1, #GPIO_DR]
	
	@ Grava novo valor de velocidade do motor
	ldr  r2, [r1, #GPIO_DR]
	bic  r2, r2,  #0x01F80000
	orr  r2, r2,  R0, LSR #19 
	str  r2, [r1, #GPIO_DR]
	
	@ Habilita novo valor
	ldr  r2, [r1, #GPIO_DR]
	and  r2, r2,  #0xFFFBFFFF
	str  r2, [r1, #GPIO_DR]

end:
	b end
