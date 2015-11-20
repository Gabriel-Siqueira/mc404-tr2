@=========================================================
@ Codigo responsavel por inicializar o GPT e atualizar
@ o contador a cada interrupcao gerada por ele	
@=========================================================
	
@ declara rotulos globais
.global CONFIG_GPT
.global GPT	
.global CONTADOR
	
@ periodo da interrupcao
.set TIME_SZ, 100
	
.data
	
CONTADOR:	.word 0

.text
	
CONFIG_GPT:

	@ Constantes para os enderecos do GPT
	.set GPT_BASE, 0x53FA0000
	.set GPT_CR,   0x0
	.set GPT_PR,   0x4
	.set GPT_OCR1, 0x10
	.set GPT_IR,   0xC
	.set GPT_SR,   0x8

	@ insere em r1 o endereco base para configurar o GPT
	ldr  r1, =GPT_BASE

	@ habilita o GPT e configura o clock_src para periferico
	mov  r0, #0x00000041  
	str  r0, [r1, #GPT_CR]

	@ zera o prescaler	
	mov  r0, #0  
	str  r0, [r1, #GPT_PR]

	@ ajusta o valor no qual a interrupcao sera gerada
	mov  r0, #TIME_SZ  
	str  r0, [r1, #GPT_OCR1]
	
	@ habilita interrupção 'Output Compare Channel 1'
	mov  r0, #1  
	str  r0, [r1, #GPT_IR]

	mov pc, lr


GPT:	

	@ indica que a interrupcao ja esta sendo tratada
	ldr   r1, =GPT_SR
	mov   r0, #1  
	str   r0, [r1]

	@ incremento do contador
	ldr   r1, =CONTADOR
	ldr   r0, [r1]
	add   r0, r0, #1  
	str   r0, [r1]

	mov pc, lr
