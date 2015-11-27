.global set_motor_speed
.global set_motors_speed
.global read_sonar
.global read_sonars
.global register_proximity_callback
.global add_alarm	
.global get_time
.global set_time

.text
.align 4
	
@ muda velocidade de um dos motores
@ recebe: r0 - numero do motor, r1 - velocidade
set_motor_speed:
	stmfd sp!,	{r7,lr}
	mov 	r7, 	#18
	svc 	0
	ldmfd sp!,	{r7,pc}

@ muda velocidade de ambos os motores
@ recebe: r0 - velocidade do motor 0, r1 - velocidade do motor 1
set_motors_speed:	
	stmfd sp!, 	{r7,lr}
	mov 	r7, 	#19
	svc 	0
	ldmfd sp!, 	{r7,pc}

@ Le a distancia medida por um dos sonares
@ recebe: r0 - numero do sonar, r1 - endereco que recebera o valor lido
read_sonar:	
	stmfd sp!, {r5,r7,lr}
	mov   r5,  r1
	mov 	r7,  #16
	svc 	0
	strh  r0,  [r5]
	ldmfd sp!, {r5,r7,pc}

@ Le a distancia medida por cada um dos sonares
@ recebe: r0 - endereco do vetor onde as distancias serao salvas
read_sonars:
	stmfd sp!, {r5,r6,r7,lr}
	mov   r5,  r0
	mov   r6,  #0
	mov 	r7,  #16
loop: 											@ de R6 = 0 ate R6 = 16
	cmp   r6,  #16
	beq   end_loop
	svc 	0
	str   r0,  [r5]
	add   r6,  r6, #1
	add   r5,  r5, #4
	b     loop
end_loop:	
	ldmfd sp!, {r5,r6,r7,pc}

@ Registra funcao a ser chamada sempre que o sensor dado
@ registra uma procimidade menor que o valor dado
@ recebe: r0 - numero do sensor, r1 - distancia, r2 - endereco da funcao
register_proximity_callback:
	stmfd sp!, {r7,lr}
	mov   r7,  #17
	svc   0
	ldmfd sp!, {r7,pc}

@ Registra um alarme
@ recebe: r0 - funcao, r1 - tempo do alarme
add_alarm:
	stmfd sp!, {r7,lr}
	mov   r7,  #22
	svc   0
	ldmfd sp!, {r7,pc}

@ Retorna o tempo do sistema
@ retorna: r0 - tempo
get_time:
	stmfd sp!, {r7,lr}
	mov   r7,  #20
	svc   0
	ldmfd sp!, {r7,pc}

@ Altera o tempo do sistema
@ recebe: r0 - tempo
set_time:
	stmfd sp!, {r7,lr}
	mov   r7,  #21
	svc   0
	ldmfd sp!, {r7,pc}
