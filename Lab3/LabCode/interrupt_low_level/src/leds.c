/*----------------------------------------------------------------------------
 LED C file
 *----------------------------------------------------------------------------*/
#include "leds.h"

void init_RGB(void){
	//Start clocks for Port A, Port B and Port C
	RCC->AHB1ENR |= RCC_PORTA_MASK | RCC_PORTB_MASK | RCC_PORTC_MASK;
  
	//Set the pins to output mode
	GPIOB->MODER &= ~MODER(RED_LED);
	GPIOC->MODER &= ~MODER(GREEN_LED);
	GPIOA->MODER &= ~MODER(BLUE_LED);
	
	GPIOB->MODER |= MODER_0(RED_LED);
	GPIOC->MODER |= MODER_0(GREEN_LED);
	GPIOA->MODER |= MODER_0(BLUE_LED);
	
	//Set pins to push-pull output state
	GPIOB->OTYPER &= ~OTYPER(RED_LED);
	GPIOC->OTYPER &= ~OTYPER(GREEN_LED);
	GPIOA->OTYPER &= ~OTYPER(BLUE_LED);
	
	//Set pins to pull-down mode
	GPIOB->PUPDR &= ~PUPDR(RED_LED);
	GPIOC->PUPDR &= ~PUPDR(GREEN_LED);
	GPIOA->PUPDR &= ~PUPDR(BLUE_LED);
	
	GPIOB->PUPDR |= PUPDR_1(RED_LED);
	GPIOC->PUPDR |= PUPDR_1(GREEN_LED);
	GPIOA->PUPDR |= PUPDR_1(BLUE_LED);
	
	//Set pins to 50MHz
	GPIOB->OSPEEDR &= ~OSPEEDR(RED_LED);
	GPIOC->OSPEEDR &= ~OSPEEDR(GREEN_LED);
	GPIOA->OSPEEDR &= ~OSPEEDR(BLUE_LED);
	
	GPIOB->OSPEEDR |= OSPEEDR_1(RED_LED);
	GPIOC->OSPEEDR |= OSPEEDR_1(GREEN_LED);
	GPIOA->OSPEEDR |= OSPEEDR_1(BLUE_LED);
	
	//Set outputs high
	GPIOB->ODR |= ODR(RED_LED);
	GPIOC->ODR |= ODR(GREEN_LED);
	GPIOA->ODR |= ODR(BLUE_LED);
}

//Toggle state of all LEDs
void toggle_all(void){
	
	toggle_r();
	toggle_g();
	toggle_b();
}

//Toggle state of red LED
void toggle_r(void){
	GPIOB->ODR ^= ODR(RED_LED);
}

//Toggle state of green LED
void toggle_g(void){
	GPIOC->ODR ^= ODR(GREEN_LED);	
}

//Toggle state of blue LED
void toggle_b(void){
	GPIOA->ODR ^= ODR(BLUE_LED);	
}

// *******************************ARM University Program Copyright (c) ARM Ltd 2014*************************************
