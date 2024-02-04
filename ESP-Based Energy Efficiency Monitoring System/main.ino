#include <SPI.h>
#include <SD.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>
#include <math.h>
#include "FS.h"

#define SAMPLING_RATE_OLED 25000
#define CS_PIN 5 // change this to the CS pin of your SD card module
#define SPI_SPEED SD_SCK_MHZ(4)


#define SCREEN_WIDTH 64 // OLED display width, in pixels
#define SCREEN_HEIGHT 128 // OLED display height, in pixels

// Declaration for an SSD1306 display connected to I2C (SDA, SCL pins)
#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
Adafruit_SH1107 display = Adafruit_SH1107(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire);
#define NUMFLAKES 10 // Number of snowflakes in the animation example
#define LOGO_HEIGHT 16
#define LOGO_WIDTH  16
#define TEMP_PIN 35
#define LUM_PIN 34
#define MOV_PIN 25


const float RL10 = 50.0; // resistance of the LDR at 10 lux
const float GAMMA = 0.7; // gamma value of the LDR
const float R_ref = 13000;     // Reference resistance at a known temperature (in ohms)
const float T_ref = 24;        // Reference temperature (in degrees Celsius)
const float B_value = 3950;    // Beta value of the NTC thermistor
const float V_supply = 3.3;    // Supply voltage (in volts)
const float R_series = 4700;  // Series resistor value (in ohms)

double time_DHT = 0;
double time_OLED = 0;
int lux;
int mov;
int temp;


File myFile;

void WriteFile(const char * path, const char * message){
  // open the file. note that only one file can be open at a time,
  // so you have to close this one before opening another.
  myFile = SD.open(path, FILE_WRITE);
  // if the file opened okay, write to it:
  if (myFile) {
    Serial.printf("Writing to %s ", path);
    myFile.println(message);
    myFile.close(); // close the file:
    Serial.println("completed.");
  } 
  // if the file didn't open, print an error:
  else {
    Serial.println("error opening file ");
    Serial.println(path);
  }
}

float calculateTemperature(float V_th) {
  V_th = map(V_th, 0, 4095, 0, 3300) / 1000.0;
  float R_th = R_series * (V_supply / V_th - 1);  // Calculate resistance of thermistor
  if (V_th == V_supply) {
    return 0;
  }
  if (R_th <= 0) {
    return 0;
  }
  float temperature = 1 / (1 / (T_ref + 273.15) + (1 / B_value) * log(R_th / R_ref)) - 273.15;
  return temperature;
}

void setup() {
  Serial.begin(115200);
  pinMode(TEMP_PIN, INPUT);
  pinMode(MOV_PIN, INPUT);
  pinMode(LUM_PIN, INPUT);
  
  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if(!display.begin(0x3C, true)) { 
    Serial.println(F("SSD1306 allocation slayed"));
    for(;;); // Don't proceed, loop forever
  }

  display.display();
  delay(2000); // Pause for 2 seconds
  display.clearDisplay();
  display.setRotation(1);
  delay(1000); // Pause for 2 seconds
  display.setTextSize(2);
  display.setTextColor(SH110X_WHITE);

  time_DHT = micros();
  time_OLED = micros();
}

void loop() {
  // put your main code here, to run repeatedly:
  int mode = 0;
  bool motionDetected;
  File file;
  float voltage;
  char message[30];
 
  while (true) {
    lux = map(analogRead(LUM_PIN), 4095, 0, 0, 100);
    if (analogRead(MOV_PIN) > 100){
      mov = 1;
    }else{
      mov = 0;
    }

    voltage = analogRead(TEMP_PIN);
    temp = calculateTemperature(voltage);

    if ((micros() - time_OLED) >= SAMPLING_RATE_OLED) { 
      display.clearDisplay();
        // Show all sensors:
        display.println("Lux:" + String(lux));
        display.println("Temp:" + String(temp));
        display.print("Move:");
        display.println(mov ? "yes" : "no");
      
      display.setCursor(2, 2);
      display.display();
      time_OLED = micros();
    }
    sprintf(message, "%lu,%.1f,%.1f,%d\n", micros(), temp, lux, mov);
    WriteFile("/data.txt", message);
    delay(250);
  }
}