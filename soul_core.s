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
	@ldr r2, =CONTADOR
	@mov r0, #0
	@str r0, [r2]

	@ Ajusta o endereço do vetor de interrupçoes
	ldr r0, =interrupt_vector
	mcr p15, 0, r0, c12, c0, 0

	@ configura o GPT
	@ldr r0, =CONFIG_GPT
	@blx r0

	@ configurar o TZIC
	@ldr r0, =CONFIG_TZIC
	@blx r0

	@ configurar o GPIO
	@ ldr r0, =CONFIG_GPIO
	@ blx r0

	@ configura chamadas de sistema
	@ldr r0, =CONFIG_SVC
	@blx r0

	@ inicializa pilhas

	@ inicialisa pilha do modo de supervisor
	@ldr sp, =SVC_SP

	@ muda para modo de sistema
	@mrs r0, cpsr
	@orr r0, r0, #0x1F     @ seleciona bits para modo de sistema
	@msr cpsr_c, r0 
	
	@ inicialisa pilha do modo de usuario
	@ldr sp, =USR_SP

	@ muda para modo de interrupcao
	@mrs r0, cpsr
	@bic r0, r0, #0x1F     @ limpa bites de modo
	@orr r0, r0, #0x12     @ seleciona bits para mode de interrupcao
	@msr cpsr_c,r0 
	
	@ inicialisa pilha do modo de interrupcao
	@ldr sp, =IRQ_SP
	
	@ habilita interrupcoes e entra em modo de usuario
	@msr  CPSR_c, #0x10

	@ transfere fluxo para aplicacao de controle

	@teste
end:
	b end
	@end test

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
	stmfd sp!,{r0-r12,lr}

	ldr   r0,=GPT
	blx   r0

	@ fim do tratamento
	ldmfd sp!,{r0-r12,lr}
	sub   lr, lr, #4
	movs  pc, lr              @ retorna

@---------------------------------------------------------
	
@*----------------- interrupcaoes nao tratadas -----------
	
UNTREATED:	b UNTREATED
	
@---------------------------------------------------------
