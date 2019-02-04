/*
Real-time graph that displays temperature and corresponding light levels, and warns us when a certain temperature 
is exceeded. Each time the graph exceeds canvas width, a new cycle refreshes and shows us the average temperature 
of the previous cycle. 
*/

import processing.serial.*;

Serial port;
String input;
String portName;

boolean filter = true;
int cycle=1;
int startX=50; 
int posX = startX;    
float posHeat;        //Y position of heat   
float posLight;
int scaleHeat = 19;   //Controls sensitivity and range(best values between 16-25)
int scaleLight = 12;  
float temp;
float light;
float totalTemp=0; 
float totalLight=0;
float averageTemp;
float averageLight;
int hotTemp = 27;    //Warning if temperature exceeds this value(°C)

int GRAPH_WIDTH = 930; 

void setup(){
  portName = Serial.list()[0]; 
  port=new Serial(this, portName, 9600);
  port.readStringUntil('\n');
  port.bufferUntil('\n');
  size(1000, 500); 
  
  background(95,158,160);
  fill(0);
  textSize(21);
  text(("Previous Cycle Average: (Determined Next Cycle)"),10,68);
}

//Responds to change in readings for port.
void serialEvent(Serial port){
  input = port.readStringUntil('\n');
  input = trim(input);
  String[] values = splitTokens(input);   //Takes in heat and light as a string array
  if(values.length>=2){                   //and separates them by index through a tab
      temp = float(values[0]);
      light = float(values[1]);  
  }
}

void textHeader(){ 
  textSize(29);
  fill(0,76,153);
  text("Temperature(°C)/", 10, 35); 
  fill(200,200,0);
  text(" Light Intensity" ,255,35);
  fill(0);
  text("Cycle: " + cycle,600,35);
}

void textWarning(){  //Draws Text for heat detection
  textHeader();
  fill(0);
  rect(580,50,350,35);
  fill(234,34,34);
  text("HIGH HEAT DETECTED!", 600,78);
}

void plotGraph(){ 
  posHeat = 800-(temp*scaleHeat); 
  rect(posX,posHeat,1.8,1.8);  //Plot 1.8x1.8 points one by one
  
  float lightShade = (55+light*18); //Changes shade of light line
  stroke(lightShade,lightShade,0);
  fill(lightShade,lightShade,0);
  posLight = (250-light*scaleLight);
  rect(posX,posLight,1.8,1.8);
  
  posX+=1; 
  if(posX%150==0){  //Marks temperature every 150 points
    markPoints();
  }
  totalTemp = totalTemp + temp; //Used for average
  totalLight = totalLight + light;
  
  if(posX>=GRAPH_WIDTH){  //When graph goes over canvas width, continues as a new cycle
    reCycle();
  }
}

void reCycle(){
  background(95,158,160);
  posX=startX;
  averageTemp = totalTemp/(GRAPH_WIDTH - posX);  
  averageLight = totalLight/(GRAPH_WIDTH - posX);
  
  cycle++;
  totalTemp=0;
  totalLight=0;
  if(cycle>=2){ //Display previous cycle average
    fill(0);
    textSize(21);
    text(("Previous Cycle Average: "+ averageTemp + "°C / " + averageLight),10,68);
  }
}

void markPoints(){
  stroke(0);
  fill(0);
  textSize(24);
  text(light, posX+5, posLight-20);
  rect(posX, posLight-10, 2, 20);
  text(temp+"°", posX+5, posHeat-20);
  rect(posX, posHeat-10, 2, 20);
}

void tempAxis(){ 
  fill(0);
  stroke(0);
  rect(startX, 100, 2, 470);
  triangle(startX,80,35,100,65,100);
}

void timeAxis(){ 
  fill(0);
  stroke(0);
  rect(10,470,900,2);//463
  triangle(910,460,910,478,930,470);
  textSize(24);
  text("Time",935,480);
}

void labelHot(){
  int posLabel;
  posLabel = 800-(hotTemp*scaleHeat);
  fill(234,34,34);
  stroke(234,34,34);
  rect(startX-8, posLabel,15,2);
  text("Hot",startX-49, posLabel+8);
}

void allAxis(){ //Draws all of the axis and HOT label
  tempAxis();
  timeAxis();
  labelHot();
}

void draw() {
  println(temp); 
  println(light);
  allAxis();
  if(cycle == 1 && posX <=145 && filter==true){ //To filter out delay on first few seconds of first cycle
    textHeader();
    posX++;
    if(posX>=145){
      posX = startX;
      filter = false;
    }
  }
  else{
    if(temp<hotTemp){ //Colours the heat line according to temperature
      textHeader();
      fill(95,158,160); //Colour to remove warning if temp <hotTemp
      stroke(95,158,160);
      rect(580,50,400,35);
      
      fill(0,76,153);
      stroke(0,76,153);
    }
    else{ 
      textWarning();
      fill(234,34,34);
      stroke(234,34,34); 
    }
    plotGraph();
  }
}
