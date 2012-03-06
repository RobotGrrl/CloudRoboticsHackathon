/*

 Green RoboBrrd
 robotgrrl.com/robobrrd
 
 @ Cloud Robotics Hackathon
 March 3, 2012
 
 notes--
 point of view origin:
 left/right wings from the back of robobrrd
 
 */

#include <Time.h>
#include <Servo.h> 
#include <Streaming.h>

boolean debug = false;

// Servos
Servo mouth, leftwing, rightwing, leftright, updown;

int WING_L_LOWER = 80;
int WING_L_UPPER = 160;
int WING_L_HOME = 140;

int WING_R_LOWER = 160;
int WING_R_UPPER = 80;
int WING_R_HOME = 100;

// Sensors
int pir(A0), tiltFB(1), tiltLR(2), ldrL(3), ldrR(4);

// Servo pins
int mouthPin(8), leftwingPin(7), rightwingPin(6);
int leftrightPin(5), updownPin(4);

// LED pins
int redR(3), greenR(9), blueR(10);
int redL(11), greenL(12), blueL(13);

// LED Values
int L1R = 255;
int L1G = 255;
int L1B = 255;
int R1R = 255;
int R1G = 255;
int R1B = 255;
int L2R = 255;
int L2G = 255;
int L2B = 255;
int R2R = 255;
int R2G = 255;
int R2B = 255;
int preL1R = 0;
int preL1G = 0;
int preL1B = 255;
int preR1R = 0;
int preR1G = 0;
int preR1B = 255;
int preL2R = 0;
int preL2G = 0;
int preL2B = 255;
int preR2R = 0;
int preR2G = 0;
int preR2B = 255;

// Misc.
boolean alternate = true;
int pirCount = 1;
int thresh = 200;
int ldrStable = 0;
int currentDir = 1;
int ldrLprev = 0;
int ldrRprev = 0;

// All the pins
int interruptIncomming = 0; // on pin 2
int interruptOutgoing = 22;

// Counters
int triggerAttemptCount = 0;
int commAttemptCount = 0;

// Trigger flag
volatile boolean triggerFlag = false;

int pos = 0;

int flagPin = 24;

int spkr = 26;



//---

int IDENTITY = 4;

#define MAX_BUFFER_LENGTH 64
int MAX_BUFFER_LENGTHS = 64;
int MAX_PACKET_LENGTHS = 64;
#define MAX_PACKET_LENGTH 64
#define PAYLOAD_LENGTH 32
int PAYLOAD_LENGTHS = 32;
#define HOST_LENGTH 16
int HOST_LENGTHS = 16;
#define SERIAL_LENGTH 12
int SERIAL_LENGTHS = 12;

uint32_t INTERVAL_USER_DATA = 50;
int ENABLE_PACKET_ENGINE = 1;
int MY_PACKET_DELINEATOR = 38;

uint32_t checkTime, serialNumber, discardPackets, inPackets;

int packetFlag, packetType, forwardPacket, bufferlen, parsePosition;
int packetLength, packetPositionPointer, foundDelineator, processingPacket, packetlen;
int z, f, s, x, y, c, a, i, b;

char buffer1[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH], packetbuffer[MAX_PACKET_LENGTH], buffer3[MAX_BUFFER_LENGTH];
char MY_ROUTER_ID[HOST_LENGTH], CONTROL_ROUTER[HOST_LENGTH], serialnum[HOST_LENGTH], psource[HOST_LENGTH], destination[HOST_LENGTH], pdest[HOST_LENGTH], source[HOST_LENGTH];
char payload[PAYLOAD_LENGTH], ppayload[PAYLOAD_LENGTH];

long MasterCount, serialNumberOffset;

//---

char mathcommand;
char mathaction;

boolean recu = false;
int repcount = 0;
int lastpulse = 0;
int count = 0;

// Initialize
void setup() {

  // Communication
  Serial.begin(9600);
  Serial1.begin(9600);

  // Interrupts
  pinMode(interruptOutgoing, OUTPUT);
  digitalWrite(interruptOutgoing, LOW);

  attachInterrupt(interruptIncomming, trigger, RISING);
  digitalWrite(2, LOW);

  pinMode(flagPin, OUTPUT);
  digitalWrite(flagPin, LOW);

  pinMode(spkr, OUTPUT);

  // LEDs
  pinMode(redR, OUTPUT);
  pinMode(greenR, OUTPUT);
  pinMode(blueR, OUTPUT);
  pinMode(redL, OUTPUT);
  pinMode(greenL, OUTPUT);
  pinMode(blueL, OUTPUT);

  // Sensors
  pinMode(pir, INPUT);
  pinMode(tiltFB, INPUT);
  pinMode(tiltLR, INPUT);
  pinMode(ldrL, INPUT);
  pinMode(ldrR, INPUT);

  // Servos
  leftwing.attach(leftwingPin);
  rightwing.attach(rightwingPin);
  leftright.attach(leftrightPin);
  updown.attach(updownPin);

  // Home positions
  leftwing.write(WING_L_HOME); // 90
  rightwing.write(WING_R_HOME); // 20
  leftright.write(90);
  updown.write(95);
  
  delay(500);
  
  leftwing.write(WING_L_UPPER);
  rightwing.write(WING_R_UPPER);
  delay(1000);
  leftwing.write(WING_L_LOWER);
  rightwing.write(WING_R_LOWER);
  delay(1000);

  leftwing.write(WING_L_HOME); // 90
  rightwing.write(WING_R_HOME); // 20
  
  delay(500);

  /*
  rightwing.write(20);
  leftwing.write(90);
  */

   XNPsetHostsFile(); 


  //randomChirp();

}

boolean fadingRainbow = true;

void loop() {

  //diagnosticProgram();


  /*
  Serial << "left" << endl;
  leftWing(3, 100);
  
  delay(1000);
  
  Serial << "right" << endl;
  rightWing(3, 100);
  
  delay(1000);
  */
  
  /*
  rightwing.write(WING_R_UPPER);
  delay(1000);
  rightwing.write(WING_R_LOWER);
  delay(1000);
  */
  
  /*
  for(int i=0; i<3; i++) {
  leftwing.write(WING_L_UPPER);
  rightwing.write(WING_R_UPPER);
  delay(500);
  leftwing.write(WING_L_LOWER);
  rightwing.write(WING_R_LOWER);
  delay(500);
  }
  
  leftwing.write(WING_L_HOME);
  rightwing.write(WING_R_HOME);
  delay(1000);
  */
  
  `
  if(ENABLE_PACKET_ENGINE == 1) {

    XNPreadSerialBus();

    if(recu) {

      if(mathcommand == 'A') {

        int resultaction = atoi(&mathaction);

        Serial << "|RED;A" << resultaction << "#" << endl;

        switch(resultaction) {
        case 0: 
          {
            // left
            //if(command == 0) leftWing(3, 100);
            break; 
          }
        case 1: 
          {
            // right
            //if(command == 0) rightWing(3, 100);
            break; 
          }
        case 2: 
          {
            // open beak
            //if(command == 0) openBeak(10, 5);
            break; 
          }
        case 3: 
          {
            // close beak
            //if(command == 0) closeBeak(10, 5);
            break; 
          }
        case 4: 
          {
            // shake
            //if(command == 0) shake(2);
            break;
          }
        case 5: 
          {
            // eyes
            //if(command == 0) updateLights();
            break;  
          }
        case 6: 
          {
            // victory
            doVictory();
            break;
          }
        case 7: 
          {
            // match
            doMatch();
            break; 
          }
        case 8: 
          {
            // wrong
            doWrong();
            break; 
          }
        }

        //delay(140);

        //updateLights();

        /*
        switch(hat) {
         case 0:
         bothWings(1, 150);
         break;
         case 1:
         bothWings(1, 150);
         break;
         case 2:
         bothWings(1, 150);
         break;
         case 3:
         beakServo.write(BEAK_OPEN);
         quickChirp();
         beakServo.write(BEAK_CLOSED);
         break;
         case 4:
         shakeNo();
         break;
         }
         */

        //Serial.print("!");

        //wingsWave();
        //quickChirp();
        //delay(100);

        lastpulse = repcount;

      }

      recu = false;

    } 
    else {

      /*
      if(repcount-lastpulse >= 1000) {
       shakeNo();
       repcount = 0;
       lastpulse = 0;
       }
       */

    }

    repcount++;

    delay(10);

  }  
  
  updateLights(false);
  
}


void doVictory() {
  Serial << "victory!" << endl;
  
  for(int ii=0; ii<3; ii++) {
    leftwing.write(WING_L_UPPER);
    rightwing.write(WING_R_UPPER);
    delay(500);
    leftwing.write(WING_L_LOWER);
    rightwing.write(WING_R_LOWER);
    delay(500);
  }
  
  for(int ii=0; ii<3; ii++) {
    openBeak();
    delay(100);
    overbiteCloseBeak();
    delay(100);
  }
  
  for(int ii=0; ii<3; ii++) {
    leftwing.write(WING_L_UPPER);
    rightwing.write(WING_R_UPPER);
    delay(500);
    leftwing.write(WING_L_LOWER);
    rightwing.write(WING_R_LOWER);
    delay(500);
  }
  
}

void doMatch() {
  Serial << "match!" << endl;
  
  for(int ii=0; ii<3; ii++) {
    leftwing.write(WING_L_UPPER);
    rightwing.write(WING_R_UPPER);
    delay(500);
    leftwing.write(WING_L_LOWER);
    rightwing.write(WING_R_LOWER);
    delay(500);
  }
  
}

void doWrong() {
 Serial << "wrong!" << endl;
  
    openBeak();
    delay(500);
    overbiteCloseBeak();
    delay(100);
  
}


void diagnosticProgram() {
  
   leftWing(3, 100);
   rightWing(3, 100);
  
   openBeak();
   delay(100);
   underbiteCloseBeak();
   delay(100);
   
   goMiddle(100);
   goRight(100);
   goMiddle(100);
   goLeft(100);
   goMiddle(100);
   
   for(int i=0; i<5; i++) {
     updateLights(true);
     delay(100);
   }
   
   leftWing(3, 100);
   rightWing(3, 100);
   
}



void rainbowFade() {

  // Main loop for the fading. All the LEDs start
  // off at dim (15), and end at dim... they never
  // go completely off since it is easier to make
  // the colours fade in and out
  // You can probably adjust the i+=1 for a faster 
  // fading rate
  
  int j = 0;
  
  for(i=15; i<=255; i+=1) { 

    // For fading the rainbow, it cycles from 
    // red to blue then to white and repeat
    if(fadingRainbow) {

      // Red: 0,1,5,6
      if(j == 0 || j == 1 || j == 5 || j == 6) {
        analogWrite(redR, i);
        analogWrite(redL, i);
      } 
      else {
        analogWrite(redR, 15);
        analogWrite(redL, 15);
      }

      // Green: 1,2,3,6
      if(j == 1 || j == 2 || j == 3 || j == 6) {
        analogWrite(greenR, i);
        analogWrite(greenL, i);
      } 
      else {
        analogWrite(greenR, 15);
        analogWrite(greenL, 15);
      }

      // Blue: 3,4,5,6
      if(j == 3 || j == 4 || j == 5 || j == 6) {
        analogWrite(blueR, i);
        analogWrite(blueL, i);
      } 
      else {
        analogWrite(blueR, 15);
        analogWrite(blueL, 15);
      }

      // Or you can just do classic white
    } 
    else {

      analogWrite(redR, i);
      analogWrite(greenR, i);
      analogWrite(blueR, i);

      analogWrite(redL, i);
      analogWrite(greenL, i);
      analogWrite(blueL, i);

    }

    // Here's the hardcoded part that does the
    // specific delays for the specific times
    if (i > 150) {
      delay(4);
    }
    if ((i > 125) && (i < 151)) {
      delay(5);
    }
    if (( i > 100) && (i < 126)) {
      delay(7);
    }
    if (( i > 75) && (i < 101)) {
      delay(10);
    }
    if (( i > 50) && (i < 76)) {
      delay(14);
    }
    if (( i > 25) && (i < 51)) {
      delay(18);
    }
    if (( i > 1) && (i < 26)) {
      delay(19);
    }
  }

  for(i = 255; i >=15; i-=1)
  {

    if(fadingRainbow) {

      // Red: 0,1,5,6
      if(j == 0 || j == 1 || j == 5 || j == 6) {
        analogWrite(redR, i);
        analogWrite(redL, i);
      } 
      else {
        analogWrite(redR, 15);
        analogWrite(redL, 15);
      }

      // Green: 1,2,3,6
      if(j == 1 || j == 2 || j == 3 || j == 6) {
        analogWrite(greenR, i);
        analogWrite(greenL, i);
      } 
      else {
        analogWrite(greenR, 15);
        analogWrite(greenL, 15);
      }

      // Blue: 3,4,5,6
      if(j == 3 || j == 4 || j == 5 || j == 6) {
        analogWrite(blueR, i);
        analogWrite(blueL, i);
      } 
      else {
        analogWrite(blueR, 15);
        analogWrite(blueL, 15);
      }

    } 
    else {

      analogWrite(redR, i);
      analogWrite(greenR, i);
      analogWrite(blueR, i);

      analogWrite(redL, i);
      analogWrite(greenL, i);
      analogWrite(blueL, i);

    }

    if (i > 150) {
      delay(4);
    }
    if ((i > 125) && (i < 151)) {
      delay(5);
    }
    if (( i > 100) && (i < 126)) {
      delay(7);
    }
    if (( i > 75) && (i < 101)) {
      delay(10);
    }
    if (( i > 50) && (i < 76)) {
      delay(14);
    }
    if (( i > 25) && (i < 51)) {
      delay(18);
    }
    if (( i > 1) && (i < 26)) {
      delay(19);
    }
  }

  j++;
  if(j == 7) j=0;

  delay(970);


}

void ledTest1() {

  Serial << "Red" << endl;
  digitalWrite(redR, HIGH);
  digitalWrite(redL, HIGH);
  delay(2000);
  digitalWrite(redR, LOW);
  digitalWrite(redL, LOW);

  Serial << "Green" << endl;
  digitalWrite(greenR, HIGH);
  digitalWrite(greenL, HIGH);
  delay(2000);
  digitalWrite(greenR, LOW);
  digitalWrite(greenL, LOW);

  Serial << "Blue" << endl;
  digitalWrite(blueR, HIGH);
  digitalWrite(blueL, HIGH);
  delay(2000);
  digitalWrite(blueR, LOW);
  digitalWrite(blueL, LOW);

}

void trigger() {
  triggerFlag = true;
}

byte nextByte() {
  while(1) {
    if(Serial.available() > 0) {
      byte b = Serial1.read();
      //if(debug) Serial << "Received byte: " << b << endl;
      return b;
    }


    if(commAttemptCount >= 100) {
      commAttemptCount = 0;
      break;
    }

    commAttemptCount++;

    //if(debug) Serial << "Waiting for next byte" << endl;
  }

}

// Example of sending data to the comm. board
// Originally used in MANOI
void periodicSend() {

  // Send some data to the communication board
  if(millis()%30 == 0 || millis()%60 == 0) {

    //digitalWrite(STATUS, LOW);

    //digitalWrite(LED, HIGH);
    delay(500);
    //digitalWrite(LED, LOW);

    // Signal that we want to send data
    digitalWrite(interruptOutgoing, HIGH);

    while(!triggerFlag) {
      // Waiting for trigger to send the data
      if(debug) Serial << "Waiting for the trigger" << endl;
      //digitalWrite(LED, HIGH);
      delay(50);
      //digitalWrite(LED, LOW);
      delay(50);
      // TODO: Make it give up at some point

      if(triggerAttemptCount >= 100) {
        triggerAttemptCount = 0;
        break;
      }

      triggerAttemptCount++;

    }

    // Ready to send data
    if(triggerFlag) {

      if(debug) Serial << "Going to send the message now" << endl;

      Serial1 << "E*";

      //digitalWrite(LED, HIGH);
      delay(1000);
      //digitalWrite(LED, LOW);

    }

    digitalWrite(interruptOutgoing, LOW);
    triggerFlag = false;

  }

}



void sendToComm(char c) {

  digitalWrite(interruptOutgoing, HIGH);

  while(!triggerFlag) {
    // Waiting for trigger to send the data
    if(debug) Serial << "Waiting for the trigger" << endl;
    //digitalWrite(LED, HIGH);
    //delay(50);
    //digitalWrite(LED, LOW);
    //delay(50);

    if(triggerAttemptCount >= 100) {
      triggerAttemptCount = 0;
      break;
    }

    triggerAttemptCount++;

  }

  // Ready to send data
  if(triggerFlag) {

    if(debug) Serial << "Going to send the message now" << endl;

    Serial1 << c << "*";

    //digitalWrite(LED, HIGH);
    //delay(1000);
    //digitalWrite(LED, LOW);

  }

  digitalWrite(interruptOutgoing, LOW);
  triggerFlag = false;

}

void sendPToComm() {

  digitalWrite(interruptOutgoing, HIGH);

  while(!triggerFlag) {
    // Waiting for trigger to send the data
    if(debug) Serial << "Waiting for the trigger" << endl;
    //digitalWrite(LED, HIGH);
    delay(50);
    //digitalWrite(LED, LOW);
    delay(50);
    // TODO: Make it give up at some point

    if(triggerAttemptCount >= 100) {
      triggerAttemptCount = 0;
      break;
    }

    triggerAttemptCount++;

  }

  // Ready to send data
  if(triggerFlag) {

    if(debug) Serial << "Going to send the message now" << endl;

    Serial1 << "P*";

    //digitalWrite(LED, HIGH);
    delay(1000);
    //digitalWrite(LED, LOW);

  }

  digitalWrite(interruptOutgoing, LOW);
  triggerFlag = false;

}


