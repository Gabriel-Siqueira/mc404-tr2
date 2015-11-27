#include "api_robot2.h"

#define LIMIAR 0xbff /* maxima aprocimacao permitida */
#define SPEED 20 /* velocidade padrao */
#define HSPEED SPEED /* velocidade padrao */
#define TURN_TIME SPEED*300 /* tempo necessario para virar 90 graus */

void stop();
void left();
void right();
void turn90();
short unsigned int dist[16];

/* main function */
int main() {
	int i;

	/* register_proximity_callback(3, LIMIAR, right); */
	/* register_proximity_callback(4, LIMIAR, left); */
	set_motors_speed(SPEED,SPEED);
	/* add_alarm(stop, 10); */
	while(1) {
		for(i = 0; i < 1000000; i++)
		turn90();
	}
	return 0;
}

void turn90() {
	int time = get_time();
	set_motors_speed(0,HSPEED);
	while(get_time() < time + TURN_TIME);
	set_motors_speed(SPEED,SPEED);
}

void stop() {
		set_motor_speed(1,0);
		set_motor_speed(0,0);
}

void left() {
	set_motor_speed(1,0);
	set_motor_speed(0,SPEED);
	do {
		read_sonar(4,&(dist[4]));
	} while (dist[4] <= LIMIAR);
	set_motor_speed(1,SPEED);
	set_motor_speed(0,SPEED);

}

void right() {
	set_motor_speed(0,0);
	set_motor_speed(1,SPEED);
	do {
		read_sonar(3,&(dist[3]));
	} while (dist[3] <= LIMIAR);
	set_motor_speed(1,SPEED);
	set_motor_speed(0,SPEED);
}

