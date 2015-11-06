/*----------------------------------------------------------------------------
 Interrupts C file
 *----------------------------------------------------------------------------*/
#include "interrupts.h"

void init_interrupts(void){
	//Start clock for the SYSCFG
	RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
	
	//Enable debug in low-power modes
	DBGMCU->CR |= DBGMCU_CR_DBG_SLEEP | DBGMCU_CR_DBG_STOP | DBGMCU_CR_DBG_STANDBY;
	
		
	//Setup interrupt configuration register for interrupts
	SYSCFG->EXTICR[1] |= SYSCFG_EXTICR2_EXTI4_PA; //SWITCH 1
	SYSCFG->EXTICR[0] |= SYSCFG_EXTICR1_EXTI0_PC; //SWITCH 2
	SYSCFG->EXTICR[1] |= SYSCFG_EXTICR2_EXTI5_PB; //SWITCH 3
	SYSCFG->EXTICR[0] |= SYSCFG_EXTICR1_EXTI1_PC; //SWITCH 4
			
	EXTI->IMR |= (0x1 << JOY_UP) | (0x1 << JOY_RIGHT) | (0x1 << JOY_CENTER) | (0x1 << JOY_LEFT); //set the interrupt mask
	EXTI->RTSR |= (0x1 << JOY_UP) | (0x1 << JOY_RIGHT) | (0x1 << JOY_CENTER) | (0x1 << JOY_LEFT); //trigger on rising edge
	
	__enable_irq();
	
	//Set priority
	NVIC_SetPriority(EXTI0_IRQn, 0);
	NVIC_SetPriority(EXTI1_IRQn, 0);
	NVIC_SetPriority(EXTI4_IRQn, 0);
	NVIC_SetPriority(EXTI9_5_IRQn, 0);

	
	//Clear pending interrupts
	NVIC_ClearPendingIRQ(EXTI0_IRQn);
	NVIC_ClearPendingIRQ(EXTI1_IRQn);
	NVIC_ClearPendingIRQ(EXTI4_IRQn);
	NVIC_ClearPendingIRQ(EXTI9_5_IRQn);
	
	//Enable interrupts
	NVIC_EnableIRQ(EXTI0_IRQn);
	NVIC_EnableIRQ(EXTI1_IRQn);
	NVIC_EnableIRQ(EXTI4_IRQn);
	NVIC_EnableIRQ(EXTI9_5_IRQn);
}

// *******************************ARM University Program Copyright (c) ARM Ltd 2014*************************************
