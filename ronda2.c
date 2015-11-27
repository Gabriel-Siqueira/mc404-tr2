#include "api_robot2.h"

#define SPEED 20 /* velocidade padrao */
#define HSPEED SPEED /* velocidade padrao */
#define TURN_TIME SPEED*300 /* tempo necessario para virar 90 graus */
#define MIM_DIST 10000      /* distancia minima da parede */

/* vira aproximadamente 90 graus para direita */
void turn90();

/* seta um alarme para o proximo valor e chama turn90 */
void tunr90_set_al();
	
/* vira para direita ate nao estar mais de frente para parede */
void turn();

/* indica quanto tempo vai levar ate o procimo alarme */
unsigned int next_al;

unsigned int time;

unsigned short dist[16];

/* o robo se move em uma espiral de dentro para fora e
	 quando encontra uma parede desvia para direita */
int main() {


	/* comeca andando em linha reta */
	set_motors_speed(SPEED, SPEED);
	
	time = get_time() + 1;

	/* a pracima linha reta levara duas unidades de tempo */
	next_al = 2;

	/* fica realizando a ronda */
	while(1) {
		read_sonar(3, &dist[3]);
		read_sonar(4, &dist[4]);
		if(dist[3] <= MIM_DIST || dist[4] <= MIM_DIST) turn();
		if(get_time() <= time) tunr90_set_al();
	}

	
	return 0;
}

void tunr90_set_al() {

	/* vira 90 graus para direita */
	turn90();

	/* adiciona novo alarme */
	time = get_time() + next_al;

	/* atualiza tempo para ate o procimo alarme */
	next_al += 100;
	
}

void turn90() {
	int time = get_time();
	set_motors_speed(0,HSPEED);
	while(get_time() < time + TURN_TIME);
	set_motors_speed(SPEED,SPEED);
}

void turn() {

	unsigned short *dist3, *dist4;
	
	/* passa a andar para direita */
	set_motors_speed(0, HSPEED);

	/* enquanto nao estiver de lado para parede */
	do {
		read_sonar(3, &dist[3]);
		read_sonar(4, &dist[4]);
	} while(dist[3] <= MIM_DIST && dist[4] <= MIM_DIST);

	/* volta a andar para frente */
	set_motors_speed(SPEED, SPEED);
	
}
