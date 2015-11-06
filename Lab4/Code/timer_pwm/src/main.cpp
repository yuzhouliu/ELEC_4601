/*----------------------------------------------------------------------------
LAB EXERCISE 4 - TIMER AND PWM
----------------------------------------
Make an audio player to play a music

    Input: 2x potentiometers, one for tuning the music speed, and one for the volume
    Output: PWM Speaker (play the music), and RGB LED (reflect the melody)
	
	GOOD LUCK!
*----------------------------------------------------------------------------*/

#include "mbed.h"

# define Do     0.5
# define Re     0.45
# define Mi     0.4
# define Fa     0.36
# define So     0.33
# define La     0.31
# define Si     0.3
# define No     0 

//Define the beat length (e.g. whole note, half note) 
# define b1     0.5
# define b2     0.25
# define b3     0.125
# define b4     0.075

float note[] = {Mi,No,Mi,No,Mi,No, Mi,No,Mi,No,Mi,No, Mi,No,So,No,Do,No,Re,No,Mi,No, Fa,No,Fa,No,Fa,No,Fa,No, Fa,No,Mi,No,Mi,No,Mi,No,Mi,No, Mi,Re,No,Re,Mi, Re,No,So,No};
float beat[] = {b3,b3,b3,b3,b2,b2, b3,b3,b3,b3,b2,b2, b3,b3,b3,b3,b3,b3,b3,b3,b2,b1, b3,b3,b3,b3,b3,b3,b3,b3, b3,b3,b3,b3,b3,b3,b4,b4,b4,b4, b2,b3,b3,b2,b2, b2,b2,b2,b2};

/*
    Define the analog inputs
	Define the PWM output for the speaker
	Define the PWM output for the RGB LED
	Define the time ticker
*/
	
//Write your code here
#define SPEAKER PB_10
PwmOut speaker(SPEAKER);	

#define RED_LED PB_4
#define BLUE_LED PA_9
PwmOut red_led(RED_LED);
PwmOut blue_led(BLUE_LED);
	
#define POT1 PA_0
#define POT2 PA_1
AnalogIn pot1(POT1);
AnalogIn pot2(POT2);

//Static variable
static int k = 0;

//Define the time ticker
//Write your code here
Ticker timer;


/*----------------------------------------------------------------------------
Interrupt Service Routine
*----------------------------------------------------------------------------*/
void timer_ISR(){ 
	/*
	The time ticker ISR will be periodically triggered after every single note
		+ Update the PWM frequency to the next music note
		+ Update beat length for the next music note (reconfigure the tick interrupt time)
		+ Update the colour of the RGB LEDs to reflect the melody changing
		+ The inputs from the two potentiometers will be used to adjust the volume and the speed
	*/
	//Write your code here
  speaker.period(note[k]/500);
	timer.attach(&timer_ISR, beat[k]*pot2.read());
	speaker.write(pot1.read());
	
	red_led.write(pot1.read());			// Map pot1 (volume) to red LED. Brighter means louder
	blue_led.write(pot2.read());		// Map pot2 (speed) to blue LED. Birghter means faster
	
	k = (k+1)%(sizeof(note)/sizeof(note[0]));			// Advance k, looping once it reaches end
} 
/*----------------------------------------------------------------------------
MAIN function
*----------------------------------------------------------------------------*/

int main(){
	/*
        Initialize the time ticker
        Sleep and wait for interrupts
	*/
  //Write your code here
	timer.attach(&timer_ISR, 1);
			
	while(1) {
		//__wfi();
	}
	
}

// *******************************ARM University Program Copyright (c) ARM Ltd 2014*************************************
