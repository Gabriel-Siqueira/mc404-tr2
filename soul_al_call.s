@=========================================================
@ Codigo que implementa as entruturas usadas pelas chamadas
@	de sistma de registro de callback e alarmes, tambem e
@	responsavel por chamar as funcoes registrados pelo
@	usuario nessas chamadas
@=========================================================
	
@ declara rotulos globais
.global alarms_count
.global callbacks_count
.global MAX_ALARMS
.global MAX_CALLBACKS
.global CONFIG_AL_CALL
.global NEW_ALARM
.global NEW_CALLBACK
	
@ constantes de controle
.set MAX_CALLBACKS, 20
.set MAX_ALARMS, 20

	
.data

@ contadors
alarms_count:	 		.word 0
callbacks_count:	.word 0

@ vetores

.set ativo 	 0 		@ 1 byte (1 = ativo, 0 = ultrapassado)
.set funcao  1 		@ 4 bytes
.set tempo   5 		@ 4 bytes
alarms_vec:				.skip MAX_ALARMS * 9

.set sonar      0   @ 1 byte
.set distancia  1   @ 2 bytes
.set funcao     3   @ 4 bytes
callbacks_vec:	  .skip MAX_CALLBACKS * 7

@ inicializa enstruturas para armazenar alarmes e callbacks
CONFIG_AL_CALL:
	@ zera contadores de callbacks e alarms
	ldr r1, =callbacks_count
	mov r0, #0
	str r0, [r1]

	ldr r1, =alarms_count
	mov r0, #0
	str r0, [r1]

	@ retorna da rotina
	mov pc, lr

@ registra novo callback
@ recebe: R0 - sonar, R1 - distancia, R2 - endereco da funcao
NEW_CALLBACK:

	stmfd sp!, {r4}

	@ Obtem endereco onde serao salvos os valores da nova callback
	ldr r4, =callbacks_count
	mul r3, r4, #7
	ldr r4, =callbacks_vec
	add r3, r3, r4
	
	@ Adiciona callback ao vetor
	strb r0, [r3, #sensor_id]
	strh r1, [r3, #distancia]
	str  r2, [r3, #funcao]
	
	@ Incrementa o numero de callbacks
	ldr r2, =callbacks_count
	ldr r1,	[r2]
	add r1, #1
	str r1,	[r2]

	@ Retorna da rotina
	ldmfd sp!, {r4}
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

@ verifica se existe alguma callback para ser executada
CHECK_CALLBACK:
	
	stmfd sp!, {r4,lr}

	ldr r4, =alarms_vec
	
@ verifica cada um dos callbacks
loop_call:
	
	ldrb r0, [r4, #sonar]
	ldr  r2, =read_sonar
	blx  r2
	ldrb r1, [r4, #distancia]
	cmp  r1, r0
	bhi  return_to_call
	
call_user_fun:
	
return_to_call:
	
end_loop_call:	

	@ Retorna da rotina
	ldmfd sp!, {r4,pc}
	
@ verifica se existe algum alarme para ser executado
CHECK_ALARM:	
