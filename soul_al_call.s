@=========================================================
@ Codigo que implementa as entruturas usadas pelas chamadas
@	de sistma de registro de callback e alarmes, tambem e
@	responsavel por chamar as funcoes registrados pelo
@	usuario nessas chamadas
@=========================================================
	
@ constantes de controle
.set MAX_CALLBACKS, 8
.set MAX_ALARMS, 8

@ declara rotulos globais
.global CONFIG_AL_CALL
.global alarms_count
.global callbacks_count
.global alarms_on
.global callbacks_on	
.global MAX_ALARMS
.global MAX_CALLBACKS
.global NEW_ALARM
.global NEW_CALLBACK
.global CHECK_ALARM
.global CHECK_CALLBACK
.global return_to_al
.global return_to_call	

.data

@*--------------------- Dados -------------------------
	
@ indica que as callback estao sendo checadas ou executadas
alarms_on:		.word 0
	
@ indica que os alarmes estao sendo checados ou executados
callbacks_on:	.word 0

@ contadors
alarms_count:	 		.word 0
callbacks_count:	.word 0

@ vetores

.set ativo, 	0 		@ 1 byte (1 = ativo, 0 = ultrapassado)
.set funcao,  1 		@ 4 bytes
.set tempo ,  5 		@ 4 bytes
alarms_vec:				.skip MAX_ALARMS * 9
.set alarms_end,  alarms_vec + MAX_ALARMS * 9  @ posicao final do vetor
	
.set sonar,      0   @ 1 byte
.set distancia,  1   @ 2 bytes
.set funcao,     3   @ 4 bytes
callbacks_vec:	  .skip MAX_CALLBACKS * 7

@------------------------------------------------------


.text
.align 4
	
@*--------------------- Inicializa -------------------------
	
@ inicializa enstruturas para armazenar alarmes e callbacks
CONFIG_AL_CALL:
	mov r0, #0

	@ zera contadores de callbacks e alarms
	ldr r1, =callbacks_count
	str r0, [r1]

	ldr r1, =alarms_count
	str r0, [r1]

	@ zera indicadores de callbacks e alarms
	ldr r1, =callbacks_on
	str r0, [r1]

	ldr r1, =alarms_on
	str r0, [r1]
	
	@ Inicialmente nenhum alarme esta ativo
	ldr  r0, =alarms_vec
	ldr  r1, =alarms_end
	
loop_con_al:
	
	@ condicao de parada
	cmp  r0, r1
	beq  end_loop_con_al

	@ zera ativo
	mov  r2, #0
	strb r2, [r0, #ativo]
	
	@ incremento
	add r0, r0, #9
	b		loop_con_al

end_loop_con_al:

	@ retorna da rotina
	mov pc, lr

@-----------------------------------------------------------


@*--------------------- Insercoes -------------------------

@ registra novo callback
@ recebe: R0 - sonar, R1 - distancia, R2 - endereco da funcao
NEW_CALLBACK:

	stmfd sp!, {r4,r5}

	@ Obtem endereco onde serao salvos os valores da nova callback
	ldr r4, =callbacks_count
	ldr r4, [r4]
	mov r5, #7
	mul r3, r4, r5
	ldr r4, =callbacks_vec
	add r3, r3, r4
	
	@ Adiciona callback ao vetor
	strb r0, [r3, #sonar]
	strh r1, [r3, #distancia]
	str  r2, [r3, #funcao]
	
	@ Incrementa o numero de callbacks
	ldr r2, =callbacks_count
	ldr r1,	[r2]
	add r1, #1
	str r1,	[r2]

	@ Retorna da rotina
	ldmfd sp!, {r4,r5}
	mov pc, lr
	
@ registra novo alarme
@ recebe: R0 - endereco da funcao, R1 - tempo
NEW_ALARM:	

	stmfd sp!, {r4}
	
	@ Obtem endereco onde serao salvos os valores da nova callback
	@ sera o primeiro sem um alarme ativo
	ldr r3, =alarms_vec
loop_na:
	ldrb r4, [r3,#ativo]
	cmp  r4, #0
	beq  end_loop_na
	add  r3, r3, #9
	b    loop_na
end_loop_na:
	
	@ Adiciona alarme ao vetor
	str  r0, [r3, #funcao]
	str  r1, [r3, #tempo]
	mov  r0, #1
	strb r0, [r3, #ativo]

	@ incrementa o numero de alarmes
	ldr r2, =alarms_count
	ldr r1,	[r2]
	add r1, #1
	str r1,	[r2]

	@ Retorna da rotina
	ldmfd sp!, {r4}
	mov pc, lr

@----------------------------------------------------------
	

@*--------------------- Checagens/execucoes -------------------------
	
@ verifica se existe alguma callback para ser executada
CHECK_CALLBACK:
	
	stmfd sp!, {r4,r5,r7,lr}

	ldr r4, =callbacks_vec
	ldr r0, =callbacks_count
	ldr r0, [r0]
	mov r7, #7
	mul r5, r0, r7
	add r5, r5, r4 
	
@ verifica cada um dos callbacks
loop_call:

	@ condicao de parada
	cmp  r4, r5
	beq  end_loop_call

	@ verifica se a funcao sera chamada
	ldrb r0, [r4, #sonar]
	ldr  r2, =read_sonar
	blx  r2
	ldrh r1, [r4, #distancia]
	cmp  r1, r0
	bhi  skip_call
	
call_user_fun:
	
	@ muda para modo de usuario
	mrs r0, cpsr
	bic r0, r0, #0x1F     @ limpa bites de modo
	orr r0, r0, #0x10     @ seleciona bits para modo de usuario
	msr cpsr_c,r0

	@ chama funcao do usuario
	ldr r0, [r4, #funcao]
	blx r0

	@ usa syscall para voltar ao modo de supervisor
	mov r7, #23
	svc 0
	
return_to_call:

	@ muda de modo de supervisor para o de interrupcao
	mrs r0, cpsr
	bic r0, r0, #0x1F     @ limpa bites de modo
	orr r0, r0, #0x12     @ seleciona bits para modo de interrupcao
	msr cpsr_c, r0

skip_call:	
	
	@ incremento
	add r4, r4, #7
	b		loop_call

end_loop_call:	

	@ Retorna da rotina
	ldmfd sp!, {r4,r5,r7,pc}
	
@ verifica se existe algum alarme para ser executado
CHECK_ALARM:	
	
	stmfd sp!, {r4,r5,r7,lr}

	ldr  r4, =alarms_vec
	ldr  r5, =alarms_end
	
@ verifica cada um dos alarmes
loop_al:

	@ condicao de parada
	cmp  r4, r5
	beq  end_loop_al

	@ verifica se o alarme esta ativo
	ldrb r1, [r4, #ativo]
	cmp  r1, #0
	beq  skip_al
	
	@ verifica se a funcao sera chamada
	@ ldr  r2, =get_time
	@ blx  r2
	mov  r0, #100
	ldr  r1, [r4, #tempo]
	cmp  r1, r0
	bhi  skip_al
	
call_user_al:
	
	@ indica que o alame ja foi usado
	mov  r1, #0
	strb r1, [r4, #ativo]
	
	@ muda para modo de usuario
	mrs r0, cpsr
	bic r0, r0, #0x1F     @ limpa bites de modo
	orr r0, r0, #0x10     @ seleciona bits para modo de usuario
	msr cpsr_c,r0

	@ chama funcao do usuario
	ldr r0, [r4, #funcao]
	blx r0

	@ usa syscall para voltar ao modo de supervisor
	mov r7, #23
	svc 0
	
return_to_al:

	@ muda de modo de supervisor para o de interrupcao
	mrs r0, cpsr
	bic r0, r0, #0x1F     @ limpa bites de modo
	orr r0, r0, #0x12     @ seleciona bits para modo de interrupcao
	msr cpsr_c, r0
	
skip_al:	

	@ incremento
	add r4, r4, #9
	b		loop_al
	
end_loop_al:	

	@ Retorna da rotina
	ldmfd sp!, {r4,r5,r7,pc}

@--------------------------------------------------------------------
