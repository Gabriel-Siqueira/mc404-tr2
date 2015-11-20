@=========================================================
@ Programa principal da camada soul, responsavel pela
@ inicaializacao do sistema e tratamento das interrupcoes,
@ gerenciando os subprogramas dessa camada.
@=========================================================

.data
@*---------------------- dados ---------------------------

@ reserva espaco das pilhas
USR_SP:	.skip 100
SVC_SP:	.skip 100
IRQ_SP:	.skip 100
	
@---------------------------------------------------------

.section .iv,"a"
	
@*----------------- Vetor de interrupcoes ----------------


_start:		

interrupt_vector:

	b		RESET_HANDLER
	b   UNTREATED                      @ UND_HANDLER
	b   SVC_HANDLER
	b   UNTREATED                      @ ABT_INST_HANDLER
	b   UNTREATED                      @ ABT_DATA_HANDLER
	.org 0x18
	b		IRQ_HANDLER
	b   UNTREATED 										 @ FIQ_HANDLER

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
	bl  CONFIG_GPT

	@ configurar o TZIC
	bl  CONFIG_TZIC

	@ configurar o GPIO
	bl  CONFIG_GPIO

	@ configura chamadas de sistema
	bl  CONFIG_SVC

	@ inicializa pilhas

	@ inicialisa pilha do modo de supervisor
	ldr sp, =SVC_SP

	@ muda para modo de sistema
	mrs r0, cpsr
	orr r0, r0, #0x1F     @ seleciona bits para mode de sistema
	msr cpsr_c, r0 
	
	@ inicialisa pilha do modo de usuario
	ldr sp, =USR_SP

	@ muda para modo de interrupcao
	mrs r0, cpsr
	bic r0, r0, #0x1F     @ limpa bites de modo
	orr r0, r0, #0x12       @ seleciona bits para mode de interrupcao
	msr cpsr_c,r0 
	
	@ inicialisa pilha do modo de interrupcao
	ldr sp, =IRQ_SP
	
	@ habilita interrupcoes e entra em modo de usuario
	msr  CPSR_c, #0x10

	@ transfere fluxo para aplicacao de controle
	@ bl _start
	
end:	 b end

@---------------------------------------------------------

@*----------------- insterrupcoes por software -----------

SVC_HANDLER:
	stmfd sp!,{r0-r12,lr}

	cmp  r7, #16
	bleq read_sonar
	cmp  r7, #17
	bleq register_proximity_callback
	cmp  r7, #18
	bleq set_motor_speed
	cmp  r7, #19
	bleq set_motors_speed
	cmp  r7, #20
	bleq get_time
	cmp  r7, #21
	bleq set_time
	cmp  r7, #22
	bleq set_alarm
	
	@ fim do tratamento
	ldmfd sp!,{r0-r12,lr}
	sub   lr, lr, #4
	movs  pc, lr 							@ retorna

@---------------------------------------------------------

@*----------------- insterrupcoes por hardware -----------

IRQ_HANDLER:
	stmfd sp!,{r0-r12}

	bl    GPT

	@ fim do tratamento
	ldmfd sp!,{r0-r12}
	sub   lr, lr, #4
	movs  pc, lr              @ retorna

@---------------------------------------------------------
	
@*----------------- interrupcaoes nao tratadas -----------
	
UNTREATED:	b UNTREATED
	
@---------------------------------------------------------
