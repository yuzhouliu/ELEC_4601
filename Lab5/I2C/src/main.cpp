/*----------------------------------------------------------------------------
ELEC4601 LAB5 Part I - I2C interface and XBEE
SERIAL COMMUNICATION
----------------------------------------
	Access the temperature sensor via I2C interface, send current temperature
	to the XBEE via UART
	
	GOOD LUCK!
*----------------------------------------------------------------------------*/

#include "mbed.h"

//Setup the I2C and UART interfaces using the mbed API
//Write your code here
I2C i2c(I2C_SDA, I2C_SCL);		// I2C_SDA and I2C_SCL are from PinNames.h
Serial pc(SERIAL_TX, SERIAL_RX); 		// USBTX and USBRX are from PinNames.h

//Define the 8 bit I2C address of temperature sensor AD7416
//Write your code here;
const int i2c_addr_temp=0x9E;		// Address 10011110


/*----------------------------------------------------------------------------
MAIN function
*----------------------------------------------------------------------------*/

int main(){
	
	uint16_t temp_val_16;
	float temp_val_float;
	
  //Create an array to store the 16 bit temperature value in
  //Write your code here
	char temp_val[2];				// 8-bit + 8-bit array for temp value
	
	//char cmd[2];						// Temperature Value Register address
	char * cmd;
	*cmd = 0x00;
	//cmd[0] = 0x00;					
	//cmd[1] = 0x00;
	
	pc.baud(9600);
	pc.format(8, Serial::None, 1);
	wait(0.5);
	pc.printf("Hello\n\r");
	
	while(1){
		/*
		Write the Read Temperature command to the sensor
		to Read the 16-bit temperature data
		*/		
		//Write your code here
		i2c.write(i2c_addr_temp, cmd, 1);
				
		if (i2c.read(i2c_addr_temp, temp_val, 2) == 0)
		{
      //Print the temperature value if read is successful
      //Write your code here
			temp_val_16 = (temp_val[0] << 8) | (temp_val[1]);	// Put low byte and high byte together
			temp_val_16 = temp_val_16 >> 6;										// Temp data is only 10 bits, so shift back 6 bits
			temp_val_float =  temp_val_16 * 0.25;							// Scale it by 0.25 since 1 = 0.25
			pc.printf("temp val: %f\n\r", temp_val_float);            
		}
		else
		{
      //Print an error message if read is unsuccessful
      //Write your code here
			pc.printf("Couldn't read from temp sensor\n\r");            
		}
		
    //Add a short time delay
    //Write your code here
		wait(1);        
	}
}
