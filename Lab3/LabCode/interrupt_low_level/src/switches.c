/*----------------------------------------------------------------------------
 Switches C file
 *----------------------------------------------------------------------------*/
#include "switches.h"

void init_switches(void){
	//Start clocks for ports A, B & C
	RCC->AHB1ENR |= RCC_PORTC_MASK  | RCC_PORTB_MASK | RCC_PORTA_MASK;
	
	//Set pins to input mode:
	GPIOA->MODER &= ~MODER(JOY_UP);
	GPIOC->MODER &= ~(MODER(JOY_RIGHT) | MODER(JOY_LEFT));
	GPIOB->MODER &= ~MODER(JOY_CENTER);
	
	//Set pins to pull-up mode
	GPIOA->PUPDR |= PUPDR_0(JOY_UP);
	GPIOC->PUPDR |= PUPDR_0(JOY_RIGHT) | PUPDR_0(JOY_LEFT);
	GPIOB->PUPDR |= PUPDR_0(JOY_CENTER);
}

// *******************************ARM University Program Copyright (c) ARM Ltd 2014*************************************
