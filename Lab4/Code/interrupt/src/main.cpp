/*----------------------------------------------------------------------------
LAB EXERCISE 4 - INTERRUPT IN/OUT
PROGRAMMING USING MBED API
----------------------------------------
In this exercise you need to use the mbed API functions to:
 
	1) Define InterruptIn and ISR for each switch press
	2) In the interrupt service routine, the RGB LED is used to indicate when a
	switch was pressed:
			+ JOY_LEFT   - light RED
			+ JOY_UP     - light BLUE
			+ JOY_RIGHT  - light GREEN
			+ JOY_CENTER - light WHITE (RED, GREEN, and BLUE at the same time)
			
	3) Put the processor into sleep mode upon exiting from the ISR
			
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

//Define outputs
//Write your code here
BusOut LED_out(RED_LED, GREEN_LED, BLUE_LED);

//Define interrupt inputs
//Write your code here
InterruptIn joy_left_press(JOY_LEFT);
InterruptIn joy_right_press(JOY_RIGHT);
InterruptIn joy_up_press(JOY_UP);
InterruptIn joy_center_press(JOY_CENTER);

//Define ISRs for the interrupts
void joy_left_handler(){	
	//Write your code here
	LED_out = ~(1 << 0);				// Joy Left, Red LED	
}

void joy_right_handler(){	
	//Write your code here
	LED_out = ~(1 << 1);				// Joy Right, Green LED
}

void joy_up_handler(){	
	//Write your code here
	LED_out = ~(1 << 2);			// Joy Up, Blue LED
}

void joy_center_handler(){	
	//Write your code here
	LED_out = ~((1 << 0) | (1 << 1) | (1 << 2));			// Joy Center, All LED
}

/*----------------------------------------------------------------------------
MAIN function
*----------------------------------------------------------------------------*/

int main(){
	
	__enable_irq();			//enable interrupts
	
	//initially turn off all LEDs
	//Write your code here
	LED_out = ((1 << 0) | (1 << 1) | (1 << 2));
	
	//Interrupt handlers
	//Attach the address of the ISR to the rising edge
  //Write your code here
	joy_left_press.rise(&joy_left_handler);
	joy_right_press.rise(&joy_right_handler);
	joy_up_press.rise(&joy_up_handler);
	joy_center_press.rise(&joy_center_handler);
	
	//Sleep on exit
	while(1){
		
		//Write your code here
		__wfi();
		
	}
}

// *******************************ARM University Program Copyright (c) ARM Ltd 2014*************************************
