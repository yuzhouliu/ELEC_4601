/*----------------------------------------------------------------------------
LAB EXERCISE 4 - TIMER AND PWM
----------------------------------------
Make an audio player to play a music

    Input: 2x potentiometers, one for tuning the music speed, and one for the volume
    Output: PWM Speaker (play the music), and RGB LED (reflect the melody)
	
	GOOD LUCK!
*----------------------------------------------------------------------------*/

#include "mbed.h"

/*
    Define the analog inputs
	Define the PWM output for the RGB LED
	Define the time ticker
*/

#define RED_LED PB_4
#define GREEN_LED PC_7
#define BLUE_LED PA_9
BusOut LED_out(RED_LED, GREEN_LED, BLUE_LED);
	
#define POT1 PA_0
AnalogIn pot1(POT1);

int main(){
	
	float val;
	// Turn all LEDs off
	LED_out = ~((1 << 0) | (1 << 1) | (1 << 2));
	while(1) {
		
		val = pot1.read();
		
		if (val < 0.2f)
			LED_out = ~(1 << 0);								// Red LED
		else if (val >= 0.2f && val < 0.4f)
			LED_out = ~((1 << 0) | (1 << 1));	 	// Green and Red LED (Orange)
		else if (val >= 0.4f && val < 0.6f)
			LED_out = ~(1 << 1);								// Green LED
		else if (val >= 0.6f && val < 0.8f)
			LED_out = ~((1 << 0) | (1 << 2));		// Red and Blue LED (Purple)
		else
			LED_out = ~(1 << 2);								// Blue LED
	}
	
}

// *******************************ARM University Program Copyright (c) ARM Ltd 2014*************************************
