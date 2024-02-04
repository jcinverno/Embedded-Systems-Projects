// Sensores Materiais e Aplicações

#include <Adafruit_MAX31865.h>
#include <AutoPID.h>
#include <Wire.h> 
#include <LiquidCrystal_I2C.h>

//PT100
#define RREF      430.0 // Valores para a resistência de referência 
#define RNOMINAL  100.0 // Resistencia nominal a 0ºC 

//PID settings and gains
#define OUTPUT_MIN 0
#define OUTPUT_MAX 255
#define KP 50
#define KI 0
#define KD 0
#define control 9
#define TEMP_READ_DELAY 800 //can only read digital temp sensor every ~750ms
double temperature, setPoint = 40, outputVal;
unsigned long current = 0;
unsigned long last = 0;
int mode;
unsigned long lastTempUpdate; //tracks clock time of last temp update

Adafruit_MAX31865 thermo = Adafruit_MAX31865(10, 11, 12, 13);  
AutoPID myPID(&temperature, &setPoint, &outputVal, OUTPUT_MIN, OUTPUT_MAX, KP, KI, KD); //input/output variables passed by reference, so they are updated automatically
LiquidCrystal_I2C lcd(0x27,2,16);  // set the LCD address to 0x27 for a 16 chars and 2 line display

void setup() {
  pinMode(control,OUTPUT);
  Serial.begin(9600); 

  thermo.begin(MAX31865_2WIRE); 
  int temperatura = 0;  
  lcd.init();                    
  lcd.backlight();
  
  while (!updateTemperature()) {} //wait until temp sensor updated
//if temperature is more than 4 degrees below or above setpoint, OUTPUT will be set to min or max respectively
  myPID.setBangBang(4);
  //set PID update interval to 4000ms
  myPID.setTimeStep(4000);
  last = millis();
}

void loop() {
  
    uint16_t rtd = thermo.readRTD();    
    float ratio = rtd;      
    ratio /= 32768;         
    lcd.clear();
    lcd.setCursor(0,0);
    lcd.print(" 18 < Temp < 20");
    lcd.setCursor(1,1);
    lcd.print("    ");lcd.print(thermo.temperature(RNOMINAL, RREF));lcd.print("C");
    delay(1000);
    updateTemperature();
    myPID.run(); //call every loop, updates automatically at certain time interval
    analogWrite(control, outputVal);
}

bool updateTemperature() {
  if ((millis() - lastTempUpdate) > TEMP_READ_DELAY) {
    temperature = thermo.temperature(RNOMINAL, RREF); //get temp reading
    lastTempUpdate = millis();
    return true;
  }
  return false;
}
