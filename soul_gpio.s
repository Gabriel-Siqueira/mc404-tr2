@=========================================================
@ Codigo responsavel por inicializar o GPIO e
@ realizar qualquer alteracao em seus valores
@=========================================================

@ Constantes de controle
.set DELAY_VALUE, 100000
.set DELAY_VALUE_1, DELAY_VALUE * 3
.set DELAY_VALUE_2, DELAY_VALUE * 2

@ declara rotulos globais
.global CONFIG_GPIO	
.global CHANGE_SPEEDS
.global SONAR	
.global speeds	

.data
	
@ variavel que armazena as velocidades do motor
speeds:	 .word  0
	
@ Constantes para os enderecos do GPIO
.set GPIO_BASE, 0x53F84000
.set GPIO_DR,		0x0
.set GPIO_GDIR, 0x4
.set GPIO_PSR,  0x8

.text
.align 4
	
@*--------------------- Inicializa -------------------------
	
CONFIG_GPIO:

	@ insere em r1 o endereco base para configurar o GPIO
	ldr  r1, =GPIO_BASE

	@ configura corretamente os pinos de entrada e saida
	ldr r0, =0xFFFC003E
	str r0, [r1, #GPIO_GDIR]

	@ zera DR
	mov r0, #0
	str r0, [r1,#GPIO_DR]
	
	mov pc, lr
	
@------------------------------------------------------
	
@*--------------------- Motores -------------------------
	
@ altera velocidades dos motores
@ recebe: r0 - mascara com velocidades
CHANGE_SPEEDS:

	@ insere em r1 o endereco base para configurar o GPIO
	ldr  r1, =GPIO_BASE

	@ Seta MOTOR0_WRITE e MOTOR1_WRITE para inicializar a escrita
	ldr  r2, [r1, #GPIO_DR]
	orr  r2, r2,  #0x02040000
	str  r2, [r1, #GPIO_DR]
	
	@ Grava novo valor de velocidade do motor
	ldr  r2, [r1, #GPIO_DR]
	ldr  r3, =0xFDF80000
	bic  r2, r2, r3  
	orr  r2, r2,  R0
	str  r2, [r1, #GPIO_DR]
	
	@ Habilita novo valor
	ldr  r2, [r1, #GPIO_DR]
	and  r2, r2,  #0xFDFBFFFF
	str  r2, [r1, #GPIO_DR]

	@ Volta da rotina
	mov  pc, lr

@------------------------------------------------------
	

@*--------------------- Sonar -------------------------
	
@ realiza leitura do valor do sonar requerido
@ recebe: r0 - sonar, retorna: r0 - valor
SONAR:

	@ insere em r3 o endereco base para configurar o GPIO
	ldr  r3, =GPIO_BASE
	
	@ grava valor de SONAR_MUX e zera o TRIGGER
	ldr  r2, [r3, #GPIO_DR]
	bic  r2, r2,  #0x0000003C
	orr  r2, r2,  r0, LSL #2     @ grava valor 
	and  r2, r2,  #0xFFFFFFFD    @ zera TRIGGER
	str  r2, [r3, #GPIO_DR]
	
	@ tempo de espera nescessario para setar o TRIGGER
	ldr  r2, =DELAY_VALUE_1
DELAY1:
	subs r2, r2, #1
	bne  DELAY1

	@ Seta TRIGGER
	ldr  r2, [r3, #GPIO_DR]
	orr  r2, r2,  #0x00000002
	str  r2, [r3, #GPIO_DR]
	
	@ tempo de espera nescessario para zerar o TRIGGER
	ldr  r2, =DELAY_VALUE_1
DELAY2:
	subs r2, r2, #1
	bne  DELAY2

	@ Zera TRIGGER
	ldr  r2, [r3, #GPIO_DR]
	and  r2, r2,  #0xFFFFFFFD
	str  r2, [r3, #GPIO_DR]

WAIT_FLAG:	
	@ Espera ate FLAG estar com valor 1
	ldr  r2, [r3, #GPIO_DR]
	tst  r2, #1
	bne  READY

	@ Tempo de espera entre checagens da FLAG
	ldr  r2, =DELAY_VALUE_2
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

@------------------------------------------------------	










