@=========================================================
@ Codigo responsavel por inicializar o GPIO e
@ realizar qualquer alteracao em seus valores
@=========================================================
	
@ declara rotulos globais
.global CONFIG_GPIO	
	
.text
	
CONFIG_GPIO:
	
	@ Constantes para os enderecos do GPIO
	.set GPIO_BASE, 0x53F84000
	.set GPIO_DR,		0x0
	.set GPIO_GDIR, 0x4
	.set GPIO_PSR,  0x8

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
MOTOR0:

@ altera velocidade do motor 1
MOTOR1:

@ realiza leitura do valor do sonar requerido
@ recebe: r0 - sonar, retorna: r0 - valor
SONAR:
