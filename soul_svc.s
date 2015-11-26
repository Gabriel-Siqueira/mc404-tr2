@=========================================================
@ Codigo que implementa as chamadas de sistema ou apenas
@	a checagem do parametros delas no caso das mais completas
@	que utilizao rotinas em outro codigos
@=========================================================

@ declara rotulos globais

.global read_sonar
.global register_proximity_callback
.global set_motor_speed
.global set_motors_speed
.global get_time
.global set_time
.global set_alarm
.global back_svc
	
.text

@ realiza leitura do valor do sonar requerido
@ recebe: r0 - sonar, retorna: r0 - valor
read_sonar:

	stmfd sp!,{lr}

	@ caso o indentificador do sonar seja invalido retorna -1
	cmp   	r0, #16
	movhs 	r0, #-1
	ldmhsfd sp!,{pc}

	@ chama rotina realiza leitura do sonar
	ldr r1, =SONAR
	blx r1

	@ retorno da rotina
	ldmfd sp!,{pc}
	
@ registra callback
@ recebe: R0 - sonar, R1 - distancia, R2 - endereco da funcao
@ retorna: R0 - (0: sucesso, -1: mais callbacks que o valor maximo
@ -2: sonar invalido)
register_proximity_callback:

	stmfd sp!,{r4,r5,r6,lr}

	@ caso o indentificador do sonar seja invalido retorna -2
	cmp   	r0, #16
	movhs 	r0, #-2
	ldmhsfd sp!,{r4,r5,r6,pc}

	@ salva R0, R1 e R2
	mov     r4, r0
	mov     r5, r1
	mov 		r6, r2

	@ caso o numero de callbacks se torne maior que o valor maximo retorna -1
	ldr 		r0, =MAX_CALLBACKS  	@ constante declarada em soul_al_call.s
	ldr 		r2, =callbacks_count	@ variavel declarada em soul_al_call.s
	ldr     r1, [r2]
	cmp 		r1, r0
	moveq   r0, #-1 
	ldmeqfd sp!,{r4,r5,r6,pc}

	@ recupera r0, r1 e r2
	mov r0, r4
	mov r1, r5
	mov r2, r6

	@ registra callback
	ldr r4, =NEW_CALLBACK
	blx r4

	@ como os valores eram validos retorna 0
	mov r0, #0
	ldmfd sp!,{r4,r5,r6,pc}

@ ajusta velocidade de um dos motores
@ recebe: R0 - identificador, R1 - velocidade
@ retorna: R0 - (0: sucesso, -1: motor invalido, -2: velocidade invalida)
set_motor_speed:

	stmfd 	sp!,{lr}

	@ caso o indentificador do motor seja invalido retorna -1
	cmp   	r0, #2
	movhs 	r0, #-1
	ldmhsfd sp!,{pc}
	
	@ caso a velocidade seja invalida retorna -2
	cmp   	r1, #0x40
	movhs 	r0, #-2
	ldmhsfd sp!,{pc}

	@ realiza alteracao no motor requerido
	cmp   r0, #0
	ldr   r2, =speeds
	ldr   r0, [r2]
	bne   MOTOR1

	@ caso seja uma mudanca no motor 0 
MOTOR0:
	bic   r0, r0, #0x01F80000
	orr   r0, r0, R1, LSL #19
	b     DONE
	
	@ caso seja uma mudanca no motor 1 
MOTOR1:	
	bic   r0, r0, #0xFC000000
	orr   r0, r0, R1, LSL #26

DONE:
	@ salva nova mascara de velocidades
	ldr   r2, =speeds
	str   r0, [r2]

	@ muda velocidades do motor
	ldr 	r2, =CHANGE_SPEEDS 
	blx 	r2

	@ como os valores eram validos retorna 0
	mov 	r0, #0
	ldmfd sp!,{pc}

@ ajusta velocidade dos motores
@ recebe: R0 - Velocidade motor 0, R1 - velocidade motor 1
@ retorna: R0 - (0: sucesso, -1: velocidade 0 invalida,
@ -2: velocidade 1 invalida)
set_motors_speed:

	stmfd sp!,{lr}
	mov r9, lr

	@ caso a velocidade do motor 0 seja invalida retorna -1
	cmp  	 	r0, #0x40
	movhs 	r0, #-1
	ldmhsfd sp!,{pc}

	@ caso a velocidade do motor 1 seja invalida retorna -2
	cmp   	r1, #0x40
	movhs 	r0, #-2
	ldmhsfd sp!,{pc}

	@ realiza alteracao nos motores
	ldr   r2, =speeds
	ldr   r3, [r2]

	@ altera velocidade do motor 0 
	bic   r3, r3, #0x01F80000
	orr   r3, r3, r0, LSL #19

	@ altera velocidade do motor 1 
	bic   r3, r3, #0xFC000000
	orr   r3, r3, r1, LSL #26

	@ salva nova mascara de velocidades
	ldr   r2, =speeds
	str   r3, [r2]

	@ muda velocidades do motor
	mov 	r0, r3
	ldr 	r2, =CHANGE_SPEEDS 
	blx 	r2

	@ como os valores eram validos retorna 0
	mov 	r0, #0
	@ ldmfd sp!,{pc}
	mov pc, r9
	
@ retorna tempo do sistema
@ retorna: R0 - tempo
get_time:

	@ coloca tempo do sistema atual em r0
	ldr r1, =CONTADOR 		@ variavel declarada em soul_gtp.s
	ldr r0, [r1]
	
	@ retorno da rotina
	mov pc, lr
	
@ altera tempo do sistema
@ recebe: R0 - tempo
set_time:	

	@ altera tempo do sistema
	ldr r1, =CONTADOR			@ variavel declarada em soul_gtp.s	
	str r0, [r1]
	
	@ retorno da rotina
	mov pc, lr
	
@ registra alarme
@ recebe: R0 - endereco da funcao, R1 - tempo
@ retorna: R0 - (0: sucesso, -1: mais alarmes que o valor maximo
@ -2: tempo invalido)
set_alarm:

	stmfd sp!,{r4,r5,lr}

	@ caso o  tempo seja menor que o tempo atual do sistema retorna -2
	mov 		r4, r0
	mov 		r5, r1
	bl 			get_time
	cmp 		r5, r0
	movlo 	r0, #-2
	ldmlofd sp!,{r4,r5,pc}
	
	@ caso o numero de alarmes se torne maior que o valor maximo retorna -1
	ldr 		r0, =MAX_ALARMS			@ constante declarada em soul_al_call.s
	ldr 		r2, =alarms_count		@ variavel declarada em soul_al_call.s
	ldr     r1, [r2]
	cmp 		r1, r0
	moveq   r0, #-1 
	ldmeqfd sp!,{r4,r5,pc}

	@ recupera r0 e r1
	mov r0, r4
	mov r1, r5
	
	@ registra o alarme
	ldr r4, =NEW_ALARM
	blx r4

	@ como os valores eram validos retorna 0
	mov   r0, #0
	ldmfd sp!,{r4,r5,pc}

@ Retorna para o modo de sistema depois da chamada de uma funcao
@ de callback ou alarme
back_svc:

	@ se for depois de um alarme
	ldr 	r0, =alarms_on
	ldr		r1, [r0]
	cmp 	r1, #1
	beq 	return_to_al

	@ se for depois de uma callback
	ldr 	r0, =callbacks_on
	ldr		r1, [r0]
	cmp 	r1, #1
	beq 	return_to_call

	@ se nao for nenhum dos casos anteriores nao faz nada
	mov   pc, lr










