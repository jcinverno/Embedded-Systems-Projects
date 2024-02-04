
#include <p24fxxxx.h>
#include <stdio.h>
//#include <stdlib.h>
#include <string.h>
#define MAX_SAMPLE 20

// Configuration Bits
#ifdef PIC24FJ64GA004 //Defined by MPLAB when using 24FJ64GA004 device
_CONFIG1( JTAGEN_OFF & GCP_OFF & GWRP_OFF & COE_OFF & FWDTEN_OFF & ICS_PGx1 & IOL1WAY_ON) 
_CONFIG2( FCKSM_CSDCMD & OSCIOFNC_OFF & POSCMOD_HS & FNOSC_PRI & I2C1SEL_SEC)
#else
_CONFIG1( JTAGEN_OFF & GCP_OFF & GWRP_OFF & COE_OFF & FWDTEN_OFF & ICS_PGx2) 
_CONFIG2( FCKSM_CSDCMD & OSCIOFNC_OFF & POSCMOD_HS & FNOSC_PRI)
#endif

//Variaveis globais
int sample = 0;
int count;
int scaler;
char setup_message[100];
int digital_ports[2];
int virtual_channel[MAX_SAMPLE];

int RA7_direction; 
int RD6_RD7_virtual;  
int sample_frequency;  
int samples_per_input;  
int analog_inputs[4];  
int digital_inputs[2];  
int RA0_value;
int RA1_value;
int AN2values[MAX_SAMPLE];
int AN3values[MAX_SAMPLE];
int AN4values[MAX_SAMPLE];
int AN5values[MAX_SAMPLE];
int AN7values[MAX_SAMPLE];
int RA7values[MAX_SAMPLE];
int RD6values[MAX_SAMPLE];
int RD7values[MAX_SAMPLE];
//----------------



void uartSendChar(char data) {
	while(U2STAbits.UTXBF){};
	U2TXREG = data;
}

void uartSendString(char* data) {
	int i;
	for(i=0; data[i]!='\0'; i++){
		uartSendChar(data[i]);
	}
}

char uartReceiveChar(){
	while(!U2STAbits.URXDA);
	return U2RXREG;
}

void uartReceiveString(char* received_string){
	int i = 0;
	received_string[i] = uartReceiveChar();

	while (received_string[i] != '\n'){
		i++;
		received_string[i] = uartReceiveChar();
	}
	received_string[i] = '\0';
}


void config_timer(){
	T1CON = 0x00; //Stops the Timer1 and reset control reg.
	TMR1 = 0x00; //Clear contents of the timer register
	PR1 = 0xFFFF;; //Load the Period register with the value 0xFFFF		PR1 = (Input clock frequency = 4k / (Desired timer frequency = 1 * TMR Prescale Value = 1)) - 1
	IPC0bits.T1IP = 0x01; //Setup Timer1 interrupt for desired priority level
	//(This example assigns level 1 priority)
	IFS0bits.T1IF = 0; //Clear the Timer1 interrupt status flag
	IEC0bits.T1IE = 1; //Enable Timer1 interrupts
	T1CONbits.TON = 1; //Start Timer1 with prescaler settings at 1:1 and 
	//clock source set to the internal instruction cycle
	scaler = 1;
}



void readPorts(int pos){
	char debugMessage[60];
	int j=0;
	int i=0;
	int analog_values [5];

	sprintf(debugMessage, "Debug- Reading Ports \n\0"); uartSendString(debugMessage);
	for (i=2;i<6;i++){
		AD1CHS = i;
		AD1CON1bits.SAMP = 1; // start sampling...
		for (j = 0 ; j < 20000 ; j++); // Ensure the correct sampling time has elapsed
		// before starting conversion.
		AD1CON1bits.SAMP = 0; // start converting
		// Wait for ADC conversion to complete
		while (!AD1CON1bits.DONE);

		analog_values[i-2] = ADC1BUF0;
	}

	AN2values[pos] = analog_values[0];
	//sprintf(debugMessage, "Debug- ReadPorts %d - \0", AN2values[0]); uartSendString(debugMessage);
	AN3values[pos] = analog_values[1];
	AN4values[pos] = analog_values[2];
	AN5values[pos] = analog_values[3];

	if(RA7_direction){
		RA7values[pos] = analog_values[4];
	}

	RD6values[pos]=!PORTDbits.RD6;
	RD7values[pos]=!PORTDbits.RD7;
}


void output_message(){

	int have_written = 0; //to check if there needs to be a comma before the text
	char message[200];
	int i; 
	int j;
	//sprintf(debugMessage, "Debug- Inside Output%d-\n\0", analog_inputs[3]); uartSendString(debugMessage);
	sprintf(message, "{");
	if (analog_inputs[0] || analog_inputs[1] || analog_inputs[2] || analog_inputs[3]){
		//sprintf(debugMessage, "Debug- Entered analog print!\n\0"); uartSendString(debugMessage);
		have_written = 1;
		for(i=2; i<=5; i++ ){
			if (analog_inputs[i-2]){
				sprintf(message, "%s'AN", message);
				sprintf(message, "%s%d':[", message, i);
				for (j= 0; j<samples_per_input; j++){
					switch(i){
						case 2: 
							sprintf(message, "%s%d", message, AN2values[j]); 
							break;
						case 3: 
							sprintf(message, "%s%d", message, AN3values[j]); 
							break; 
						case 4: 
							sprintf(message, "%s%d", message, AN4values[j]); 
							break; 
						case 5: 
							sprintf(message, "%s%d", message, AN5values[j]); 
							break; 
						default:
							break;
					}
					if (j!=samples_per_input-1){
						sprintf(message, "%s,", message);
					}
				}
				sprintf(message, "%s]", message);
			}
			if (i==2 && (analog_inputs[0]) && (analog_inputs[1] || analog_inputs[2] || analog_inputs[3])){
				sprintf(message, "%s,", message);
			}
			if (i==3 && (analog_inputs[1]) && (analog_inputs[2] || analog_inputs[3])){
				sprintf(message, "%s,", message);
			}
			if (i==4 && (analog_inputs[2]) && (analog_inputs[3])){
				sprintf(message, "%s,", message);
			}
		}
	}
	//sprintf(debugMessage, "Debug- 1\0"); uartSendString(debugMessage);
	if (digital_inputs[0] || digital_inputs[1]){
		if (have_written){
			sprintf(message, "%s,", message);
		}
		for(i=6;i<=7; i++ ){
			if (digital_inputs[i-6]){
				sprintf(message, "%s'RD", message);
				sprintf(message, "%s%d':[", message, i);
				for (j= 0; j<samples_per_input; j++){
					if (i==6){
						sprintf(message, "%s%d", message, RD6values[j]);
					}else{
						sprintf(message, "%s%d", message, RD7values[j]);
					}
					if (j!=samples_per_input-1){
						sprintf(message, "%s,", message);
					}
				}
				sprintf(message, "%s]", message);
			}
			if (i==6 && (digital_inputs[1])){
				sprintf(message, "%s,", message);
			}
		}
	}
	if (RA7_direction){
		if (have_written){
			sprintf(message, "%s,", message);
		}
		sprintf(message, "%s'DB':[", message);
		for (j= 0; j<samples_per_input; j++){
			sprintf(message, "%s%d", message, AN7values[j]);	
			if (j!=samples_per_input-1){
				sprintf(message, "%s,", message);
			}
		}
		sprintf(message, "%s]", message);
	}
	//sprintf(debugMessage, "Debug- 2\n\0"); uartSendString(debugMessage);
	if (RD6_RD7_virtual ){
		if (have_written){
			sprintf(message, "%s,", message);
		}
		sprintf(message, "%s'DV':[", message);
		for (j= 0; j<samples_per_input; j++){
			sprintf(message, "%s%d", message, virtual_channel[j]);
			if (j!=samples_per_input-1){
				sprintf(message, "%s,", message);
			}
		}
		sprintf(message, "%s]", message);
	}
	sprintf(message, "%s}\n\0", message);
	uartSendString(message);
}




void process_message(char* message) {

	int i;
	//sprintf(debugMessage, "Debug- Processing\n\0"); uartSendString(debugMessage);
  	for (i = 0; i < strlen(message); i++) {
		if (message[i] == '{' || message[i] == '}' || message[i] == ',' || message[i] == ':') {
		
		continue;
		} else if (message[i] == '"') {

			i++;
			int start_index = i;
			while (message[i] != '"') {
				i++;
			}
			int end_index = i;


			i += 2; 
			int value_start_index = i;
			while (i < strlen(message) && message[i] != ',' && message[i] != '}') {
				i++;
			}

			
			int value = message[value_start_index] - '0';

			
			if (strncmp(message + start_index, "b", end_index - start_index) == 0) {
				RA7_direction = value;
			} else if (strncmp(message + start_index, "v", end_index - start_index) == 0) {
				RD6_RD7_virtual = value;
			} else if (strncmp(message + start_index, "f", end_index - start_index) == 0) {
				sample_frequency = value;
			} else if (strncmp(message + start_index, "n", end_index - start_index) == 0) {
				samples_per_input = value;
			} else if (strncmp(message + start_index, "A2", end_index - start_index) == 0) {
				analog_inputs[0] = value;
			} else if (strncmp(message + start_index, "A3", end_index - start_index) == 0) {
				analog_inputs[1] = value;
			} else if (strncmp(message + start_index, "A4", end_index - start_index) == 0) {
				analog_inputs[2] = value;
			} else if (strncmp(message + start_index, "A5", end_index - start_index) == 0) {
				analog_inputs[3] = value;
			} else if (strncmp(message + start_index, "DB", end_index - start_index) == 0) {
				digital_inputs[0] = value;
			} else if (strncmp(message + start_index, "DV", end_index - start_index)== 0) {
				digital_inputs[1] = value;
			} else if (strncmp(message + start_index, "A0", end_index - start_index) == 0) {
				RA0_value = value;
			} else if (strncmp(message + start_index, "A1", end_index - start_index) == 0) {
				RA1_value = value;
			}
		}
	}
}

void config(){
	LATAbits.LATA0=1;
	char debugMessage[60];sprintf(debugMessage, "Debug- Entered config mode\n\0"); uartSendString(debugMessage);
	uartReceiveString(setup_message);
	process_message(setup_message);
	scaler = sample_frequency;
	LATAbits.LATA0=0;
}




int main(void){

	int i = 0;
	int config_change = 0;
	int hasBeenConfigured = 0;

	TRISDbits.TRISD6 = 1;		//1 input
	TRISAbits.TRISA0 = 0;		//0 output
	TRISAbits.TRISA1 = 0;		//0 output 


	AD1PCFG = 0xFFC3; // AN2-AN5 as analog, all other pins are digital    0xFFF0
	AD1CON1 = 0x0000; // SAMP bit = 0 ends sampling and starts converting wms
	AD1CSSL = 0;
	AD1CON3 = 0x0002;
	AD1CON2 = 0; // Scan AN2-AN5, 4 samples per interrupt   0x0400
	AD1CON1bits.ADON = 1; // turn ADC ON


	U2BRG = 25; //Set Baudrate 
	U2STA = 0;
	U2MODE = 0x8000; //Enable Uart for 8-bit data
	U2STAbits.UTXEN = 1; //Enable Transmit

	config_timer();


	while ( 1 ){
		if (!PORTDbits.RD6) {
			config();
			hasBeenConfigured = 1;
		}
		if (hasBeenConfigured){
			for (i = 0; i<samples_per_input; i++){
				while(!sample){
					if (!PORTDbits.RD6) {
						config();
						config_change = 1;		//in case the configs are changed we dont want to print the output message, we want the cycle to restart
					}
				}
				LATAbits.LATA0=1;
				//sprintf(debugMessage, "Debug- Before Read%d\n\0", i); uartSendString(debugMessage);
				readPorts(i);
				if (RD6_RD7_virtual){	//Create virtual chanel, convert binary of RD6 and RD7 to int 
					virtual_channel[i] = (digital_ports[0]*2)+digital_ports[1];
				}
				sample = 0;
				LATAbits.LATA0=0;
			}	
			//sprintf(debugMessage, "Debug- Before Output\n\0"); uartSendString(debugMessage);
			if(!config_change){
				output_message();
			}
			config_change = 0;
		}
		}
}



void __attribute__((__interrupt__, __shadow__)) _T1Interrupt(void)
{
	IFS0bits.T1IF = 0; //Reset Timer1 interrupt flag and Return from ISR
	//Interrupt Service Routine code goes here 
	if(64*scaler == count){
		count = 0;
		sample = 1;
	}
	count++;
}




//SETUP MESSAGE
//{"A2":0,"A3":0,"A4":0,"A5":1,"D6":0,"D7":0,"DB":1,"DV":1,"n":5,"f":10,"b":1,"v":1,"D0":1}

