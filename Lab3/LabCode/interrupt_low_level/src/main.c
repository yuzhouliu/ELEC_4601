/*----------------------------------------------------------------------------
LAB EXERCISE 3 - Low Level Interrupt Handling
 ----------------------------------------
	In this lab, you need to complete the code to perform the following functions:
	
	+ Control the RGB LED according to the status of buttons
	+ In the interrupt service routine, set a flag which then toggles the LEDs
	+ Enter to sleep mode after exiting from the interrupt

	Inputs: buttons on a breadboard
	Outputs: RGB LED

	GOOD LUCK!
 *----------------------------------------------------------------------------*/
#include "leds.h"
#include "switches.h"
#include "interrupts.h"

volatile int done;

//Simple software debouncing
void delay(float time){
	volatile int i;
	for(i=0; i<1000000*time; i++);
}

/*----------------------------------------------------------------------------
  Interrupt handler functions
 *----------------------------------------------------------------------------*/
void EXTI0_IRQHandler(void){
	//JOY_RIGHT Pressed
	//Clear pending interrupts
	NVIC_ClearPendingIRQ(EXTI0_IRQn);

	if((GPIOC->IDR >> JOY_RIGHT) & 0x1){
		// Toggles Green LED in main function
		done = 2;
		//Clear the EXTI pending register
		EXTI->PR |= (0x01 << JOY_RIGHT);
	}
} 

void EXTI1_IRQHandler(void){
	//JOY_LEFT Pressed
	//Write your code here
	NVIC_ClearPendingIRQ(EXTI1_IRQn);

	if((GPIOC->IDR >> JOY_LEFT) & 0x1){
		// Toggles Red LED in main function
		done = 1;
		//Clear the EXTI pending register
		EXTI->PR |= (0x01 << JOY_LEFT);
	}	
}

void EXTI4_IRQHandler(void){
	//JOY_UP Pressed
	//Write your code here
	NVIC_ClearPendingIRQ(EXTI4_IRQn);

	if((GPIOA->IDR >> JOY_UP) & 0x1){
		// Toggles Blue LED in main function
		done = 3;
		//Clear the EXTI pending register
		EXTI->PR |= (0x01 << JOY_UP);
	}	
}

void EXTI9_5_IRQHandler(void){
	//JOY_CENTER Pressed
	//Write your code here
	NVIC_ClearPendingIRQ(EXTI9_5_IRQn);

	if((GPIOB->IDR >> JOY_CENTER) & 0x1){
		// Toggles All LEDs in main function
		done = 4;
		//Clear the EXTI pending register
		EXTI->PR |= (0x01 << JOY_CENTER);
	}		
}

/*----------------------------------------------------------------------------
  MAIN function
 *----------------------------------------------------------------------------*/
int main(void){
	
	//Initialise LEDs, buttons and interrupts
	init_RGB();
	init_switches();
	init_interrupts();
	done = 0;
	
	while(1){
		switch(done){
			
			//Toggle corresponding bits depending on which button was pressed
			
			case 1:
				toggle_r();
				break;
			case 2:
				toggle_g();
				break;
			case 3:
				toggle_b();
				break;
			case 4:
				toggle_all();
				break;
		}
		
		done = 0;
		delay(1);
		
		if (done == 0) //if done == 0, processor goes to sleep
			__wfi();
	}
}

// *******************************ARM University Program Copyright (c) ARM Ltd 2014*************************************
