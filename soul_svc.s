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
	ldmeqfd sp!,{r4,r5,pc}

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

	stmfd sp!,{lr}

	@ caso o indentificador do motor seja invalido retorna -1
	cmp   	r0, #2
	movhs 	r0, #-1
	ldmhsfd sp!,{pc}
	
	@ caso a velocidade seja invalida retorna -2
	cmp   r1, #0x40
	movhs r0, #-2
	ldmhsfd sp!,{pc}

	@ realiza alteracao no motor requerido
	cmp   r0, #0
	mov   r0, r1
	ldreq r2, =MOTOR0 
	bleq  MOTOR0
	ldrne r2, =MOTOR1 
	blne  MOTOR1

	@ como os valores eram validos retorna 0
	mov r0, #0
	ldmfd sp!,{pc}

@ ajusta velocidade dos motores
@ recebe: R0 - Velocidade motor 0, R1 - velocidade motor 1
@ retorna: R0 - (0: sucesso, -1: velocidade 0 invalida,
@ -2: velocidade 1 invalida)
set_motors_speed:

	stmfd sp!,{r4,lr}

	@ caso a velocidade do motor 0 seja invalida retorna -1
	cmp  	 	r0, #0x40
	movhs 	r0, #-1
	ldmhsfd sp!,{r4,pc}

	@ caso a velocidade do motor 1 seja invalida retorna -2
	cmp   	r1, #0x40
	movhs 	r0, #-2
	ldmhsfd sp!,{r4,pc}

	@ realiza alteracao das velocidades
	mov r4, r0
	mov r0, #1
	bl  set_motor_speed
	
	mov r1, r4
	mov r0, #0
	bl  set_motor_speed

	@ como os valores eram validos retorna 0
	mov 	r0, #0
	ldmfd sp!,{r4,pc}
	
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
	cmp 		r0, r5
	movlo 	r0, #-2
	ldmlofd sp!,{r4,r5,pc}
	
	@ caso o numero de alarmes se torne maior que o valor maximo retorna -1
	ldr 		r0, =MAX_ALARMS			@ constante declarada em soul_al_call.s
	ldr 		r2, =alarms_count		@ variavel declarada em soul_al_call.s
	ldr     r1, [r2]
	cmp 		r1, r0
	moveq   r0, #-1 
	ldmeqfd sp!,{r4,r5,pc}

	@ recupera r0 r r1
	mov r0, r4
	mov r1, r5
	
	@ registra o alarme
	ldr r4, =NEW_ALARM
	blx r4

	@ como os valores eram validos retorna 0
	mov r0, #0
	ldmfd sp!,{r4,r5,pc}
