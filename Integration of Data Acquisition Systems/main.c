#include <p24fxxxx.h>
#include <stdio.h>
//#include <stdlib.h>
#include <string.h>
#define MAX_SAMPLE 20

// Configuration Bits
#ifdef PIC24FJ64GA004 //Defined by MPLAB when using 24FJ64GA004 device
_CONFIG1(JTAGEN_OFF& GCP_OFF& GWRP_OFF& COE_OFF& FWDTEN_OFF& ICS_PGx1& IOL1WAY_ON)
_CONFIG2(FCKSM_CSDCMD& OSCIOFNC_OFF& POSCMOD_HS& FNOSC_PRI& I2C1SEL_SEC)
#else
_CONFIG1(JTAGEN_OFF& GCP_OFF& GWRP_OFF& COE_OFF& FWDTEN_OFF& ICS_PGx2)
_CONFIG2(FCKSM_CSDCMD& OSCIOFNC_OFF& POSCMOD_HS& FNOSC_PRI)
#endif

//Variaveis globais
int sample;
int count;
int scaler;
int hasBeenConfigured = 0;
int config_change = 0;
int configInterrupt = 0;
char setup_message[100];
int digital_ports[2];
int virtual_channel[MAX_SAMPLE];
int i2 = 0;
int k = 0;

int position = 0;
int RA7_direction;
int RD6_RD7_virtual;
int sample_frequency;
int samples_per_input;
int analog_inputs[4];
int digital_inputs[2];
int arduino_inputs[4];
int RA0_value;
int RA1_value;
int AD1_read;
int AD2_read;
int AN2values[MAX_SAMPLE];
int AN3values[MAX_SAMPLE];
int AN4values[MAX_SAMPLE];
int AN5values[MAX_SAMPLE];
int AN7values[MAX_SAMPLE];
int RA7values[MAX_SAMPLE];
int RD6values[MAX_SAMPLE];
int RD7values[MAX_SAMPLE];
int AD1values[MAX_SAMPLE];
int AD2values[MAX_SAMPLE];
//----------------



void uartSendChar(char data) {
	while (U2STAbits.UTXBF) {};
	U2TXREG = data;
}

void uartSendString(char* data) {
	int i;
	for (i = 0; data[i] != '\0'; i++) {
		uartSendChar(data[i]);
	}
}

char uartReceiveChar() {
	while (!U2STAbits.URXDA);
	return U2RXREG;
}

void uartReceiveString(char* received_string) {
	int i = 0;
	received_string[i] = uartReceiveChar();

	while (received_string[i] != '\n') {
		i++;
		received_string[i] = uartReceiveChar();
	}
	received_string[i] = '\0';
}

void config_timer() {
	T1CON = 0x00; //Stops the Timer1 and reset control reg.
	TMR1 = 0x00; //Clear contents of the timer register
	PR1 = 0xFFFF;; //Load the Period register with the value 0xFFFF		PR1 = (Input clock frequency = 4k / (Desired timer frequency = 1 * TMR Prescale Value = 1)) - 1
	IPC0bits.T1IP = 0x01; //Setup Timer1 interrupt for desired priority level
	//(This example assigns level 1 priority)
	IFS0bits.T1IF = 0; //Clear the Timer1 interrupt status flag
	IEC0bits.T1IE = 1; //Enable Timer1 interrupts
	IEC1bits.U2RXIE = 1;
	T1CONbits.TON = 1; //Start Timer1 with prescaler settings at 1:1 and 
	//clock source set to the internal instruction cycle
	scaler = 1;
}


void master_trx() {
	char debugMessage[60];
	I2C2CONbits.SEN = 1; //Setting the SEN bit starts a Start event.

	while (I2C2CONbits.SEN) {};

	I2C2TRN = (0x48 << 1) + 0;

	while (I2C2STATbits.TBF) {}; //waits until the Transmit Buffer Full bit of the I2C2STAT register is cleared
	while (I2C2STATbits.TRSTAT) {}; //waits until the Transmit/Receive Status bit of the I2C2STAT register is cleared

	if (I2C2STATbits.ACKSTAT) { //ACKEN bit starts an Acknowledge event
		sprintf(debugMessage, "Debug- Nao houve ACKEN do Slave\n\0"); uartSendString(debugMessage);
	}

	I2C2TRN = 0xAC;
	while (I2C2STATbits.TBF) {}; //waits until the Transmit Buffer Full bit of the I2C2STAT register is cleared
	while (I2C2STATbits.TRSTAT) {}; //waits until the Transmit/Receive Status bit of the I2C2STAT register is cleared

	if (I2C2STATbits.ACKSTAT) { //ACKEN bit starts an Acknowledge event
		sprintf(debugMessage, "Debug- Nao houve ACKEN do Slave\n\0"); uartSendString(debugMessage);
	}

	I2C2CONbits.PEN = 1; //Setting the PEN bit starts a master Stop event
	while (I2C2CONbits.PEN) {};
}

void slave_trx()
{
	char debugMessage[60];
	I2C2CONbits.SEN = 1; // Setting the SEN bit starts a Start event.
	while (I2C2CONbits.SEN) {};

	I2C2TRN = (0x48 << 1) + 1; // Send slave address with read bit
	//sprintf(debugMessage, "Debug- SLAVE \n\0"); uartSendString(debugMessage);
	while (I2C2STATbits.TBF) {}; // Wait until the Transmit Buffer Full bit of the I2C2STAT register is cleared
	while (I2C2STATbits.TRSTAT) {}; // Wait until the Transmit/Receive Status bit of the I2C2STAT register is cleared

	if (I2C2STATbits.ACKSTAT) { // ACKEN bit starts an Acknowledge event
		sprintf(debugMessage, "Debug - Nao houve ACKEN do Slave\n\0"); uartSendString(debugMessage);
	}

	for (k=0; k<=4; k++){
		I2C2CONbits.RCEN = 1; // Enable receive mode
		while (I2C2CONbits.RCEN == 1) {};
		
		
		while (!I2C2STATbits.RBF) {}; // Wait until Receive Buffer Full bit is set
		int receivedData = I2C2RCV; // Read the received data
		if (k!=0){
			arduino_inputs[k-1] = receivedData;
		}
		if (k!=4){
			I2C2CONbits.ACKDT = 0;
		}else{
			I2C2CONbits.ACKDT = 1;
		}
		I2C2CONbits.ACKEN = 1; // Send acknowledge
		while (I2C2CONbits.ACKEN) {}; // Wait until the Acknowledge sequence is complete
	}
	I2C2CONbits.PEN = 1; // Setting the PEN bit starts a master Stop event
	while (I2C2CONbits.PEN) {};
	
	
}

void output_message() {
	//char debugMessage [60];
	int have_written = 0; //to check if there needs to be a comma before the text
	char message[200];
	int i;
	int j;
	//sprintf(debugMessage, "Debug- Inside Output%d-\n\0", analog_inputs[3]); uartSendString(debugMessage);
	sprintf(message, "{");
	if(AD1_read){
		have_written = 1;
		sprintf(message, "%s'AD1':[", message);
		for (j = 0; j < samples_per_input; j++) {
			sprintf(message, "%s%u", message, AD1values[j]);
			if (j != samples_per_input - 1) {
				sprintf(message, "%s,", message);
			}
		}
		sprintf(message, "%s]", message, i);
	}
	if (have_written) {
		sprintf(message, "%s,", message);
	}
	if(AD2_read){
		have_written = 1;
		sprintf(message, "%s'AD2':[", message);
		for (j = 0; j < samples_per_input; j++) {
			sprintf(message, "%s%u", message, AD2values[j]);
			if (j != samples_per_input - 1) {
				sprintf(message, "%s,", message);
			}
		}
		sprintf(message, "%s]", message, i);
	}
	sprintf(message, "%s}\n\0", message);
	uartSendString(message);
}

void process_message(char* message) {
	char debugMessage[60];
	// variaveis para armazenar as informacoes da mensagem
	int i;
	sprintf(debugMessage, "Debug- Processing\n\0"); uartSendString(debugMessage);
	// percorre a string caractere a caractere
	for (i = 0; i < strlen(message); i++) {
		if (message[i] == '{' || message[i] == '}' || message[i] == ',' || message[i] == ':') {
			// ignora esses caracteres
			continue;
		}
		else if (message[i] == '"') {
			// comeca um novo parametro, leia o nome do parametro
			i++;
			int start_index = i;
			while (message[i] != '"') {
				i++;
			}
			int end_index = i;

			// leia o valor do parâmetro
			i += 2; // pula os caracteres ":"
			int value_start_index = i;
			while (i < strlen(message) && message[i] != ',' && message[i] != '}') {
				i++;
			}

			// extrai o valor como uma string e converte para inteiro
			int value = message[value_start_index] - '0';

			if (strncmp(message + start_index, "f", end_index - start_index) == 0) {
				sample_frequency = value;
			}
			else if (strncmp(message + start_index, "n", end_index - start_index) == 0) {
				samples_per_input = value;
			}
			else if (strncmp(message + start_index, "AD1", end_index - start_index) == 0) {
				AD1_read = value;
			}
			else if (strncmp(message + start_index, "AD2", end_index - start_index) == 0) {
				AD2_read = value;
			}
		}
	}
	sprintf(debugMessage, "Debug- done Processing\n\0"); uartSendString(debugMessage);
}

process_arduino(){
	int ad1 = (arduino_inputs[0]<<8) + (arduino_inputs[1]);
	int ad2 = (arduino_inputs[2]<<8) + (arduino_inputs[3]);
	AD1values[position] = ad1;
	AD2values[position] = ad2;
}

void config() {
	LATAbits.LATA0 = 1;
	//char debugMessage[60]; sprintf(debugMessage, "Debug- Entered config mode\n\0"); uartSendString(debugMessage);
	uartReceiveString(setup_message);
	//sprintf(debugMessage, "Debug- midle of config mode\n\0"); uartSendString(debugMessage);
	process_message(setup_message);
	scaler = sample_frequency;
	LATAbits.LATA0 = 0;
}

int main(void) {
	int i = 0;
	char debugMessage[60];
	TRISDbits.TRISD6 = 1;		//1 input
	TRISAbits.TRISA0 = 0;		//0 output
	TRISAbits.TRISA1 = 0;		//0 output 
	U2BRG = 25; //Set Baudrate 
	U2STA = 0;
	U2MODE = 0x8000; //Enable Uart for 8-bit data
	U2STAbits.UTXEN = 1; //Enable Transmit
	I2C2BRG = 25;
	I2C2STAT = 0;
	I2C2CON = 0;
	I2C2CONbits.I2CEN = 1;
	position = 0;
	config_timer();
	//sprintf(debugMessage, "Debug- entering while\n\0"); uartSendString(debugMessage);
	while (1) {
		if (hasBeenConfigured) {
			while (!sample){}
			//sprintf(debugMessage, "Debug- entering master while\n\0"); uartSendString(debugMessage);
			master_trx();
			//sprintf(debugMessage, "Debug- e2222222222222222222222\n\0"); uartSendString(debugMessage);
			slave_trx();
			//sprintf(debugMessage, "Debug-333333333333333333333333\n\0"); uartSendString(debugMessage);
			process_arduino();
			position++;

			if (configInterrupt) {
				sprintf(debugMessage, "Debug- interrupt\n\0"); uartSendString(debugMessage);
				process_message(setup_message);
				hasBeenConfigured = 1;
				configInterrupt = 0;
			}
			if ( position == samples_per_input ){
				position = 0;
				if (!config_change) {
					//sprintf(debugMessage, "Debug-OUTPUTTTTTTTTTTTTTTTTT\n\0"); uartSendString(debugMessage);
					output_message();
				}
				if(config_change){
					config_change = 1;
				}

			}

		}else {
			while (!configInterrupt) {
			};
			//sprintf(debugMessage, "Debug- has been configured\n\0"); uartSendString(debugMessage);
			process_message(setup_message);
			hasBeenConfigured = 1;
			configInterrupt = 0;
		}
	}
}

void __attribute__((__interrupt__, shadow)) _T1Interrupt(void)
{
	IFS0bits.T1IF = 0; //Reset Timer1 interrupt flag and Return from ISR
	//Interrupt Service Routine code goes here 
	if (64 * scaler == count) {
		count = 0;
		sample = 1;
	}
	count++;
} 	

void __attribute__((__interrupt__, auto_psv)) _U2RXInterrupt(void)
{
	IFS1bits.U2RXIF = 0;
	setup_message[i2] = U2RXREG;
	if (setup_message[i2] == '\n') {
		configInterrupt = 1;
		if (hasBeenConfigured){
			config_change = 1;
		}
	}
	i2++;
}


//SETUP MESSAGE
//{"A2":0,"A3":0,"A4":0,"A5":1,"D6":0,"D7":0,"DB":1,"DV":1,"n":4,"f":2,"b":1,"v":1,"D0":1,"A0":1,"AD1":1,"AD2":1}
//{"n":4,"f":2,"AD1":1,"AD2":1}