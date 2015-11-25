@ ======================================================== 
@ Programa principal da camada soul, responsavel pela
@ inicaializacao do sistema e tratamento das interrupcoes,
@ gerenciando os subprogramas dessa camada.
@=========================================================

.data
@*---------------------- dados ---------------------------

@ reserva espaco das pilhas
.skip 100
USR_SP:
.skip 100
SVC_SP:
.skip 100
IRQ_SP:

@ indica que as callback estao sendo checadas ou executadas
alarms_on:		.word 0
	
@ indica que os alarmes estao sendo checados ou executados
callbacks_on:	.word 0
	
@---------------------------------------------------------

.section .iv,"a"
	
@*----------------- Vetor de interrupcoes ----------------

_start:		

interrupt_vector:

	b		RESET_HANDLER
	b   UNTREATED
	b   SVC_HANDLER
	b   UNTREATED
	b   UNTREATED
	b   UNTREATED
	b		IRQ_HANDLER
	b   UNTREATED

@---------------------------------------------------------
	
.text
.align 4
	
@*----------------------- Reset ---------------------------
	
RESET_HANDLER:
	
	@ Zera o contador
	ldr r2, =CONTADOR
	mov r0, #0
	str r0, [r2]

	@ Ajusta o endereço do vetor de interrupçoes
	ldr r0, =interrupt_vector
	mcr p15, 0, r0, c12, c0, 0

	@ configura o GPT
	ldr r0, =CONFIG_GPT
	blx r0

	@ configurar o TZIC
	ldr r0, =CONFIG_TZIC
	blx r0

	@ configurar o GPIO
	ldr r0, =CONFIG_GPIO
	blx r0

	@ inicializa estruturas de alarmes e callbacks
	ldr r0, =CONFIG_AL_CALL
	blx r0

	@ inicializa pilhas

	@ inicialisa pilha do modo de supervisor
	ldr sp, =SVC_SP

	@ muda para modo de sistema
	mrs r0, cpsr
	orr r0, r0, #0x1F     @ seleciona bits para modo de sistema
	msr cpsr_c, r0 
	
	@ inicialisa pilha do modo de usuario
	ldr sp, =USR_SP

	@ muda para modo de interrupcao
	mrs r0, cpsr
	bic r0, r0, #0x1F     @ limpa bites de modo
	orr r0, r0, #0x12     @ seleciona bits para mode de interrupcao
	msr cpsr_c,r0 
	
	@ inicialisa pilha do modo de interrupcao
	ldr sp, =IRQ_SP
	
	@ habilita interrupcoes e entra em modo de usuario
	msr  CPSR_c, #0x10

	@ transfere fluxo para aplicacao de controle

	ldr  r0, =0x77802000
	bx   r0

@---------------------------------------------------------


@*----------------- insterrupcoes por software -----------

SVC_HANDLER:
	stmfd sp!,{r0-r12,lr}

	cmp   r7, #16
	ldreq r5, =read_sonar
	blxeq r5

	cmp   r7, #17
	ldreq r5, =register_proximity_callback
	blxeq r5

	cmp   r7, #18
	ldreq r5, =set_motor_speed
	blxeq r5

	cmp   r7, #19
	ldreq r5, =set_motors_speed
	blxeq r5

	cmp   r7, #20
	ldreq r5, =get_time
	blxeq r5

	cmp   r7, #21
	ldreq r5, =set_time
	blxeq r5

	cmp   r7, #22
	ldreq r5, =set_alarm
	blxeq r5
	
	@ fim do tratamento
	ldmfd sp!,{r0-r12,pc}
	sub   lr, lr, #4
	movs  pc, lr 							@ retorna

@---------------------------------------------------------


@*----------------- insterrupcoes por hardware -----------

IRQ_HANDLER:
	stmfd sp!,{r0-r6,lr}

	ldr   r0, =GPT
	blx   r0

	@ verifica se ja existe alguma callback sendo executada ou checada 
	ldr   r4, =callbacks_on
	ldr   r0, [r4]
	cmp   r0, #1
	beq   SKIP
	
	@ verifica se ja existe algum alarme sendo executado ou checado 
	ldr   r5, =alarms_on
	ldr   r1, [r5]
	cmp   r1, #1
	beq   SKIP

	@ salva spsr para o caso de outra interrupcao
	mov   r6, spsr

	@ habilita interrupcoes
	msr  CPSR_c, #0x12

	@ checa callbacks que deven ser executadas
	mov   r1, #1
	str   r1, [r4]
	ldr   r0, =CHECK_CALLBACK
	blx   r0
	mov   r1, #0
	str   r1, [r4]
	
	@ checa alarmes que devem ser executados
	mov   r1, #1
	str   r1, [r5]
	ldr   r0, =CHECK_ALARM
	blx   r0
	mov   r1, #0
	str   r1, [r5]

	mov   spsr, r6
	
SKIP:	
	
	@ fim do tratamento
	ldmfd sp!, {r0-r3,lr}
	sub   lr,  lr, #4
	movs  pc,  lr              @ retorna

@---------------------------------------------------------
	
@*----------------- interrupcaoes nao tratadas -----------
	
UNTREATED:	b UNTREATED
	
@---------------------------------------------------------
