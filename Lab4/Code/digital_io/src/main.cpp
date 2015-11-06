/*----------------------------------------------------------------------------
LAB EXERCISE 4 - DIGITAL INPUTS AND OUTPUTS
PROGRAMMING USING MBED API
----------------------------------------
In this exercise you need to use the mbed API functions to:
 
    1) Define BusIn, BusOut interfaces for inputs and outputs
	2) The RGB LED is controlled by the joystick:
			+ JOY_LEFT   - light RED
			+ JOY_RIGHT  - light GREEN
			+ JOY_UP     - light BLUE
			+ JOY_CENTER - light WHITE (RED, GREEN, and BLUE at the same time)
			
	GOOD LUCK!
*----------------------------------------------------------------------------*/

#include "mbed.h"

#define JOY_UP PA_4
#define JOY_RIGHT PC_0
#define JOY_CENTER PB_5
#define JOY_LEFT PC_1

#define RED_LED PB_4
#define GREEN_LED PC_7
#define BLUE_LED PA_9

//Define input bus
//Write your code here
BusIn JoyStick_In(JOY_LEFT, JOY_RIGHT, JOY_UP, JOY_CENTER);

//Define output bus for the RGB LED
//Write your code here
BusOut LED_out(RED_LED, GREEN_LED, BLUE_LED);


/*----------------------------------------------------------------------------
MAIN function
*----------------------------------------------------------------------------*/

int main(){
	
    while(1){		
        
			//Check which switch was pressed and light up the corresponding LED(s)
			//Write your code here
			
			switch(JoyStick_In) {
				case (1 << 0):																	// If JOY_LEFT (bit-0) pressed 
					LED_out = ~(1 << 0);													// Red (bit-0)
					break;
				case (1 << 1):																	// If JOY_RIGHT (bit-1) pressed
					LED_out = ~(1 << 1);													// Green (bit-1)
					break;
				case (1 << 2):																	// If JOY_UP (bit-2)
					LED_out = ~(1 << 2);													// Blue (bit-2)
					break;
				case (1 << 3):																	// If JOY_CENTER (bit-3)
					LED_out = ~((1 << 0) | (1 << 1) | (1 << 2));	// All LEDs
					break;
				default:																				// No buttons pressed
					LED_out = ((1 << 0) | (1 << 1) | (1 << 2));		// LEDs OFF
			}        
	}
    
}

// *******************************ARM University Program Copyright (c) ARM Ltd 2014*************************************
