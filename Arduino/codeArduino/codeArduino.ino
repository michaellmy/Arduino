#include <math.h>
const int buzzPin = 12; 
const int lightPin = A1;
const int heatPin = A0;
int hotTemp=27; //Temperature threshold in which buzzer buzzes

void setup() {
 Serial.begin(9600); 
 pinMode(buzzPin,OUTPUT);
}

//FROM EXAMPLE CODE IN MOODLE
double getTemperature(int rawADC) {
 rawADC -= 200; 
 double temp;
 temp = log(((10240000/rawADC) - 10000));
 temp = 1 / (0.001129148 +
 (0.000234125 + (0.0000000876741 * temp * temp ))* temp );
 return temp - 273.15; 
}

double getLight(double rawLight){ //Measures light in a scale of 1-10
 return rawLight/100.0;
}

void loop() {
 int input;
 double temperature;
 input = analogRead(heatPin);
 temperature = getTemperature(input);

 double lightInput;
 double light;
 lightInput = analogRead(lightPin); 
 light = getLight(lightInput); 
 
 Serial.print(temperature); 
 Serial.print("\t");
 Serial.print(light);
 Serial.println();

 if(temperature >= hotTemp){ //Buzzes when temp reaches threshold
   tone(buzzPin, 600);
   noTone(buzzPin);
   tone(buzzPin,600);
 }
 else {
   noTone(buzzPin);
 }
}
