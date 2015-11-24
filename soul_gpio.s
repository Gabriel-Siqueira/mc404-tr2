@=========================================================
@ Codigo responsavel por inicializar o GPIO e
@ realizar qualquer alteracao em seus valores
@=========================================================
	
@ declara rotulos globais
.global CONFIG_GPIO	
.global MOTOR0	
.global MOTOR1
.global SONAR	
	
@ Constantes para os enderecos do GPIO
.set GPIO_BASE, 0x53F84000
.set GPIO_DR,		0x0
.set GPIO_GDIR, 0x4
.set GPIO_PSR,  0x8

.text
.align 4

@ Constantes de controle
.set DELAY_VALUE, 1000
	
CONFIG_GPIO:

	@ insere em r1 o endereco base para configurar o GPIO
	ldr  r1, =GPIO_BASE

	@ configura corretamente os pinos de entrada e saida
	ldr r0, =0xFFFC003E
	str r0, [r1, #GPIO_GDIR]

	@ zera DR
	mov r0, #0
	str r0, [r1, #GPIO_DR]
	
	mov pc, lr

@ altera velocidade do motor 0
@ recebe: R0 - velocidade
MOTOR0:

	@ insere em r1 o endereco base para configurar o GPIO
	ldr  r1, =GPIO_BASE

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

	@ Volta da rotina
	mov pc, lr
	
@ altera velocidade do motor 1
MOTOR1:

	@ insere em r1 o endereco base para configurar o GPIO
	ldr  r1, =GPIO_BASE

	@ Seta MOTOR1_WRITE para inicializar a escrita
	ldr  r2, [r1, #GPIO_DR]
	orr  r2, r2,  #0x02000000
	str  r2, [r1, #GPIO_DR]
	
	@ Grava novo valor de velocidade do motor
	ldr  r2, [r1, #GPIO_DR]
	bic  r2, r2,  #0xFC000000
	orr  r2, r2,  R0, LSR #26 
	str  r2, [r1, #GPIO_DR]
	
	@ Habilita novo valor
	ldr  r2, [r1, #GPIO_DR]
	and  r2, r2,  #0xFDFFFFFF
	str  r2, [r1, #GPIO_DR]

	@ Volta da rotina
	mov pc, lr
	
@ realiza leitura do valor do sonar requerido
@ recebe: r0 - sonar, retorna: r0 - valor
SONAR:

	@ insere em r1 o endereco base para configurar o GPIO
	ldr  r3, =GPIO_BASE
	
	@ grava valor de SONAR_MUX
	ldr  r2, [r3, #GPIO_DR]
	bic  r2, r2,  #0x0000007C
	orr  r2, r2,  R0, LSR #2 
	str  r2, [r3, #GPIO_DR]
	
	@ Zera TRIGGER
	ldr  r2, [r3, #GPIO_DR]
	and  r2, r2,  #0xFFFFFFFD
	str  r2, [r3, #GPIO_DR]

	@ tempo de espera nescessario para setar o TRIGGER
	ldr  r1, =DELAY_VALUE
	mov  r3, #3
	mul  r2, r1, r3
DELAY1:
	subs r2, r2, #1
	bne  DELAY1

	@ Seta TRIGGER
	ldr  r2, [r3, #GPIO_DR]
	orr  r2, r2,  #0x00000002
	str  r2, [r3, #GPIO_DR]
	
	@ tempo de espera nescessario para zerar o TRIGGER
	ldr  r1, =DELAY_VALUE
	mov  r3, #3
	mul  r2, r1, r3
DELAY2:
	subs r2, r2, #1
	bne  DELAY2

	@ Zera TRIGGER
	ldr  r2, [r3, #GPIO_DR]
	and  r2, r2,  #0xFFFFFFFD
	str  r2, [r3, #GPIO_DR]

WAIT_FLAG:	
	@ Espera ate FLAG estar com valor 1
	ldr  r2, [r3, #GPIO_PSR]
	tst  r2, #1
	bne  READY

	@ Tempo de espera entre checagens da FLAG
	ldr  r1, =DELAY_VALUE
	mov  r3, #2
	mul  r2, r1, r3
DELAY3:
	subs r2, r2, #1
	bne  DELAY3
	b    WAIT_FLAG

	@ Le o valor da distancia
READY:
	ldr  r2, [r3, #GPIO_PSR]
	ldr  r1, =0xFFFC003F
	bic  r2, r2, r1
	mov  r0, r2, lsr #6

	@ Volta da rotina
	mov pc, lr
