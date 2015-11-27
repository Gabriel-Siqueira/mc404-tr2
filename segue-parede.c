#include "api_robot2.h"

#define SPEED  30        /* velocidade do robo */
#define HSPEED SPEED/2   /* velocidade lenta */
#define MIM_DIST 200     /* distancia minima da parede */
#define MAX_DIST 400     /* distancia maxima da parede */

/* indica se esta no modo busca-parede(0) ou segue-parede(1) */
int mode;

/* indica para onde o robo esta se movendo no seque-parede */
/* 0 = reto, 1 = direita. 2 = esquerda */
int dir;

/* muda de modo quando encontra a parede */
void found();

/* O robo anda em linha reta ate encontrar uma parede e
   entao passa a seguir a parede estando com ela sempre 
	 em seu lado direito */
int main() {

	unsigned short *dist[16];
	
	/* inicia no modo busca-parede */
	mode = 0;
	
	/* cria proximity call back para quando estiver proximo da parede */
	register_proximity_callback(3, MIM_DIST, found);
	register_proximity_callback(4, MIM_DIST, found);

	/* comeca andando em linha reta */
	set_motors_speed(SPEED, SPEED);

	/* enquanto estiver no modo busca-parede */
	while(mode == 0);

	/* passa a andar para esquerda */
	set_motors_speed(HSPEED, 0);

	/* enquanto nao estiver de lado para parede */
	do {
		read_sonar(3, dist[3]);
		read_sonar(4, dist[4]);
	} while(*(dist[3]) <= MIM_DIST && *(dist[4]) <= MIM_DIST);

	/* volta a andar para frente */
	set_motors_speed(SPEED, SPEED);
	dir = 0;
	
	/* fica seguindo a parede */
	while(mode) {
		read_sonar(7, dist[7]);
		read_sonar(8, dist[8]);
		if ( *(dist[7]) <= MIM_DIST || *(dist[8]) <= MIM_DIST ) {
			if(dir != 2) {
				set_motor_speed(1, HSPEED);
			}
		} else if ( *(dist[7]) >= MAX_DIST || *(dist[8]) >= MAX_DIST ) {
			if(dir != 1) {
				set_motor_speed(0, HSPEED);
			}
		} else {
			if(dir != 0) {
				set_motors_speed(SPEED, SPEED);
			}
		}
	}
	
	return 0;
}

void found() {
	mode = 1;
}
