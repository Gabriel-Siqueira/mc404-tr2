#include "api_robot2.h"

#define SPEED    30        /* velocidade do robo */
#define HSPEED   SPEED/2   /* velocidade lenta */
#define MIM_DIST 200       /* distancia minima da parede */

/* vira aproximadamente 90 graus para direita */
void turn90();

/* seta um alarme para o proximo valor e chama turn90 */
void tunr90_set_al();
	
/* vira para direita ate nao estar mais de frente para parede */
void turn();

/* indica quanto tempo vai levar ate o procimo alarme */
unsigned int next_al;

/* o robo se move em uma espiral de dentro para fora e
	 quando encontra uma parede desvia para direita */
int main() {

	/* cria proximity call back para quando estiver proximo da parede */
	register_proximity_callback(3, MIM_DIST, turn);
	register_proximity_callback(4, MIM_DIST, turn);
	
	/* comeca andando em linha reta */
	set_motors_speed(SPEED, SPEED);
	
	/* adiciona novo alarme */
	add_alarm(tunr90_set_al, get_time() + 1);

	/* o procimo alarme sera em duas unidades de tempo */
	next_al = 2;

	/* fica realizando a ronda */
	while(1);
	
	return 0;
}

void tunr90_set_al() {

	/* vira 90 graus para direita */
	turn90();

	/* adiciona novo alarme */
	add_alarm(tunr90_set_al, get_time() + next_al);

	/* atualiza tempo para ate o procimo alarme */
	next_al++;
	if(next_al == 51) {
		next_al = 1;
	}
	
}

void turn90() {
}

void turn() {

	unsigned short *dist3, *dist4;
	
	/* passa a andar para direita */
	set_motors_speed(0, HSPEED);

	/* enquanto nao estiver de lado para parede */
	do {
		read_sonar(3, dist3);
		read_sonar(4, dist4);
	} while(*(dist3) <= MIM_DIST && *(dist4) <= MIM_DIST);

	/* volta a andar para frente */
	set_motors_speed(SPEED, SPEED);
	
}
