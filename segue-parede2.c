#include "api_robot2.h"

#define SPEED    20        /* velocidade do robo */
#define HSPEED   SPEED/2   /* velocidade meio lenta */
#define TSPEED   SPEED/3   /* velocidade lenta */
#define HHSPEED  SPEED/4   /* velocidade muito lenta */
#define MIM_DIST 1000      /* distancia minima da parede */
#define MAX_DIST 1300      /* distancia maxima da parede */

/* indica se esta no modo busca-parede(0) ou segue-parede(1) */
int mode;

/* O robo anda em linha reta ate encontrar uma parede e
   entao passa a seguir a parede estando com ela sempre 
	 em seu lado direito */
int main() {

	unsigned short dist[16];
	
	/* inicia no modo busca-parede */
	mode = 0;

	/* comeca andando em linha reta */
	set_motors_speed(SPEED, SPEED);

	/* enquanto estiver no modo busca-parede */
	while(mode == 0) {
		read_sonar(3, &dist[3]);
		read_sonar(4, &dist[4]);
		if(dist[3] <= MIM_DIST && dist[4] <= MIM_DIST) mode = 1;
	}

	/* passa a andar para esquerda */
	set_motors_speed(HHSPEED, 0);

	/* enquanto nao estiver de lado para parede */
	do {
		read_sonar(3, &dist[3]);
		read_sonar(4, &dist[4]);
	} while(dist[3] <= MIM_DIST && dist[4] <= MIM_DIST);

	/* volta a andar para frente */
	set_motors_speed(SPEED, SPEED);
	
	/* fica seguindo a parede */
	while(mode) {
		read_sonar(5, &dist[5]);
		read_sonar(6, &dist[6]);
		read_sonar(4, &dist[4]);
		/* se comecar a se aproximar demais */
		if ( dist[5] <= MIM_DIST ) {
				set_motors_speed(HSPEED, TSPEED);
				while(dist[5] <= MIM_DIST) {
					read_sonar(5, &dist[5]);
				}
				set_motors_speed(HSPEED, HSPEED);
		}
		/* se começar a se afastar de mais */
		if ( dist[5] >= MAX_DIST ) {
				set_motors_speed(TSPEED, HSPEED);
				while(dist[5] >= MAX_DIST) {
					read_sonar(5, &dist[5]);
				}
				set_motors_speed(HSPEED, HSPEED);
		}
		/* se tiver uma parede na frente */
		if(dist[4] <= MIM_DIST) {
			set_motors_speed(HSPEED, 0);
			do {
				read_sonar(4, &dist[4]);
			} while(dist[4] <= MIM_DIST);
			set_motors_speed(HSPEED, HSPEED);
		}
	}
	
	return 0;
}
