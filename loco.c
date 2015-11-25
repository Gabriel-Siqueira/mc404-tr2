#include "api_robot2.h"

#define LIMIAR 1000 /* maxima aprocimacao permitida */
#define SPEED 42 /* velocidade padrao */

/* main function */
void _start(void) {
  unsigned int distances[16];
	unsigned short *e,*d;

	/* read_sonar(3,e); */
	/* read_sonar(4,d); */
	/* if(*e <= LIMIAR) { */
	/* 	set_motors_speed(SPEED,0); */
	/* } else if(*d <= LIMIAR) { */
	/* 	set_motors_speed(0,SPEED); */
	/* } else { */
	set_motor_speed(1,SPEED);
	set_motor_speed(0,SPEED);
	/* } */
	while(1)
	{
	}
}
