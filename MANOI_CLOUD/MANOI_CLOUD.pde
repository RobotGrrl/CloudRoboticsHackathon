/*
 * MANOI @ cloud robotics hackathon
 * March 3 2012
 *
 * robotgrrl.com
 *
 */

#include <NewSoftSerial.h>
#include <Streaming.h>
#include <SSC32.h>
#include <stdio.h>
#include <Wire.h>
#include <Time.h>

boolean debug = true;

// Home positions
int HOME0 = 1800;
int HOME1 = 1500;
int HOME2 = 1100;
int HOME3 = 1300;
int HOME4 = 1200;   // 1300 for hockey, 800 for normal
int HOME5 = 1600+100;
int HOME6 = 1300+100;
int HOME16 = 1550;
int HOME17 = 1250;
int HOME18 = 1000;
int HOME19 = 1600+15;//+35;
int HOME20 = 1600;
int HOME21 = 1500;
int HOME22 = 1250;
int HOME23 = 1000;
int HOME24 = 1580+15;//35;
int HOME25 = 1600;

int redL1 = 30;//3;
int redR1 = 6;
int greenL1 = 31;//4;
int greenR1 = 7;
int blueL1 = 32;//2;
int blueR1 = 5;
int redL2 = 9;
int redR2 = 12;
int greenL2 = 10;
int greenR2 = 13;
int blueL2 = 8;
int blueR2 = 11;

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

int z_accel(0), y_accel(1), x_accel(2), gyro(3), fsr(4), ir(5);
int xval(0), yval(0), zval(0), gyroval(0), fsrval(0), irval(0);

int homeFrame[17] = {
	HOME0,
	HOME1,
	HOME2,
	HOME3,
	HOME4,
	HOME5,
	HOME6,
	HOME16,
	HOME17,
	HOME18,
	HOME19,
	HOME20,
	HOME21,
	HOME22,
	HOME23,
	HOME24,
	HOME25
};

int leftArmOut = 100;
int leftArmForward = 500;
int leftWristMovement = 200;
int rightArmOut = 100;
int rightArmForward = 500;
int rightWristMovement = 200;

// Nunchuck
int joy_x_axis;
int joy_y_axis;
int accel_x_axis; 
int accel_y_axis;
int accel_z_axis;
int z_button;
int c_button;

// Hockey stick
int stickLEDs(22), rightLDR(7), leftLDR(8), rightLDRval(0), leftLDRval(0);

// Logics
int lastMove;

int rightLDRevaluation(0);
int leftLDRevaluation(0);

int rightLDRhome(0);
int leftLDRhome(0);

SSC32 ssc(true);

bool receivedMessage = false;
int messageLength = 0;
char fsrCmd[] = {'F', 'S', 'R'};
char irCmd[] = {'I', 'R'};
char ledCmd[] = {'L', 'E', 'D'};
char bothArmJngl[] = {'B', 'A', 'J', 'N', 'G', 'L' };
char ftJngl[] = { 'F', 'T', 'J', 'N', 'G', 'L' };
char shotCmd[] = {'s', 'h', 'o', 't'};
char idnrCmd[] = {'i', 'd', 'n', 'r'};
int it = 0;
byte newByte = 0;
int said = 0;
bool validCmd = true;
int ii = 0;


// All the pins
int interruptIncomming = 2;
int interruptOutgoing = 23;
int LED = 24; // blue
int STATUS = 25; // green
int triggerAttemptCount = 0;

// Trigger flag
volatile boolean triggerFlag = false;



//---

int IDENTITY = 2;

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



// necklace bling
int blingR[5] = {28, 31, 34, 37, 40};
int blingG[5] = {29, 32, 35, 38, 41};
int blingB[5] = {30, 33, 36, 39, 42};

int bling[5][5] = { 28, 31, 34, 37, 40,
                    29, 32, 35, 38, 41, 
                    30, 33, 36, 39, 42 };


char mathcommand;
char mathaction;

boolean recu = false;
int repcount = 0;
int lastpulse = 0;
int count = 0;

// Initialize
void setup() {
    
	// Communication
	Serial1.begin(9600);
	
	// Outputs
	pinMode(LED, OUTPUT);
	pinMode(STATUS, OUTPUT);
	
	// Interrupts
	pinMode(interruptOutgoing, OUTPUT);
	attachInterrupt(0, trigger, RISING);
	
        XNPsetHostsFile(); 

	Serial2.begin(9600);
	
	for(int i=0; i<7; i++) {
		ssc.servoMode(i, true);
	}
	
	for(int i=16; i<25; i++) {
		ssc.servoMode(i, true); 
	}
	
	ssc.servoMode(31, true);
	
	ssc.setFrame(homeFrame, 100, 100);
	
	pinMode(z_accel, INPUT);
	pinMode(y_accel, INPUT);
	pinMode(x_accel, INPUT);
	pinMode(gyro, INPUT);
	pinMode(ir, INPUT);
	pinMode(fsr, INPUT);
	
	//pinMode(redL1, OUTPUT);
	//pinMode(greenL1, OUTPUT);
	//pinMode(blueL1, OUTPUT);
	pinMode(redL2, OUTPUT);
	pinMode(greenL2, OUTPUT);
	pinMode(blueL2, OUTPUT);
	pinMode(redR1, OUTPUT);
	pinMode(greenR1, OUTPUT);
	pinMode(blueR1, OUTPUT);
	pinMode(redR2, OUTPUT);
	pinMode(greenR2, OUTPUT);
	pinMode(blueR2, OUTPUT);
	
	Serial.begin(9600);
	Serial3.begin(9600);
	
	updateLights();
	
	fade2( preL1R,    preL1G,      preL1B,  // L1 Start
		  12,         0,           255,     // L1 Finish
		  preR1R,    preR1G,      preR1B,   // R1 Start
		  12,         0,           255,     // R1 Finish
		  preL2R,    preL2G,      preL2B,   // L2 Start
		  12,         0,           255,     // L2 Finish
		  preR2R,    preR2G,      preR2B,   // R2 Start
		  12,         0,           255,     // R2 Finish
		  1);
	
	//initializeStick();
	//nunchuck_init();
	
	ssc.setFrame(homeFrame, 100, 100);
    
    initializeStick();
    
    // necklace bling
    /*
    for(int i=0; i<5; i++) {
      pinMode(blingR[i], OUTPUT);
      pinMode(blingG[i], OUTPUT);
      pinMode(blingB[i], OUTPUT);
    }
    */
    
    for(int j=0; j<3; j++) {
      for(int i=0; i<5; i++) {
        pinMode(bling[j][i], OUTPUT);
      }
    }
	
}

void loop() {
    
  XNPreadSerialBus();
  
  //ssc.setFrame(homeFrame, 100, 0);
  
  int blinky = count%8;
  
  switch(blinky) {
    case 0:
  blingFlash(4, 50, true, true, true);
  break;
  case 1:
  blingFlash(4, 50, true, true, true);
  break;
  case 2:
  blingMarquee(5, 100, 
               true, true, false,
               true, false, true);
  break;
  case 3:
  blingMarquee(5, 100, 
               false, false, true,
               true, true, false);
  break;
  case 4:
  blingMarquee(5, 100, 
               false, true, false,
               false, true, true);
  break;
  case 5:
  blingChaseRainbow(1, 50);
  break;
  case 6:
  blingMarquee(10, 100, 
               true, true, true,
               true, false, false);
  break;
  case 7:  
  blingChase(3, 50, false, true, false);
  break;
  }
  
  //ssc.setFrame(homeFrame, 100, 0);
  
  /*
  blingFlash(4, 50, true, true, true);
  
  blingFlash(4, 50, true, true, true);
  
  blingMarquee(5, 100, 
               true, true, false,
               true, false, true);
  
  blingMarquee(5, 100, 
               false, false, true,
               true, true, false);
  
  blingMarquee(5, 100, 
               false, true, false,
               false, true, true);
  
  blingChaseRainbow(1, 50);
  
  blingMarquee(10, 100, 
               true, true, true,
               true, false, false);
               
  blingChase(3, 50, false, true, false);
  */
  
  count++;
  
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
  
}

void doVictory() {
  Serial << "victory!" << endl;
  bothArmJingle(1);
  feetJingle(2);
}

void doMatch() {
  Serial << "match!" << endl;
  bothArmJingle(2);
}

void doWrong() {
 Serial << "wrong!" << endl;
  headshake(3, 100, 100);
}


void blingLED(int led, boolean r, boolean g, boolean b) {
  
  if(r) {
    digitalWrite(bling[0][led], HIGH);
  } else {
    digitalWrite(bling[0][led], LOW);
  }
  
  if(g) {
    digitalWrite(bling[1][led], HIGH);
  } else {
    digitalWrite(bling[1][led], LOW);
  }
  
  if(b) {
    digitalWrite(bling[2][led], HIGH);
  } else {
    digitalWrite(bling[2][led], LOW);
  }
  
}

void blingChase(int repeat, int del, boolean r, boolean g, boolean b) {
 
 for(int rep=0; rep<repeat; rep++) {
  
 for(int i=0; i<5; i++) {
    int l = i%5;
    blingLED(l, r, g, b);
    
    if(i > 0) {
      blingLED(l-1, false, false, false);
    }
    
    delay(del);
  }
  
  for(int i=4; i>0; i--) {
    int l = (i-1)%5;
    blingLED(l, r, g, b);
    
    if(i < 5) {
      blingLED(l+1, false, false, false);
    }
    
    delay(del);
  }
  
  }
  
}

void blingChaseRainbow(int repeat, int del) {
  
  for(int rep=0; rep<repeat; rep++) {
    
    blingChase(1, del, true, false, false);
    blingChase(1, del, true, true, false);
    blingChase(1, del, false, true, false);
    blingChase(1, del, false, true, true);
    blingChase(1, del, false, false, true);
    blingChase(1, del, true, false, true);
    
  }
  
}

void blingMarquee(int repeat, int del, 
                  boolean r1, boolean g1, boolean b1,
                  boolean r2, boolean g2, boolean b2)
{
  
  for(int rep=0; rep<repeat; rep++) {
  for(int i=0; i<5; i+=2) {
    
    if(rep%2 == 0) {
     blingLED(i, r1, g1, b1);
     if(i<(5-1)) blingLED(i+1, r2, g2, b2); 
    } else {
     blingLED(i, r2, g2, b2);
     if(i<(5-1)) blingLED(i+1, r1, g1, b1); 
    }
    
  }

    delay(del);  
  }
               
}

void blingFlash(int repeat, int del, boolean r, boolean g, boolean b) {
  
  for(int rep=0; rep<repeat; rep++) {
           
  for(int i=0; i<5; i++) {    
    blingLED(i, r, g, b);
  }
  
  delay(del);
  
  for(int i=0; i<5; i++) {    
    blingLED(i, false, false, false);
  }
  
  delay(del);
  
  }
  
}


void robotpartydemoProgram() {
 
  float volts = analogRead(A9)*0.0048828125;
  float distance = 65*pow(volts, -1.10);
  Serial.println(distance);
  
  float thresh = 15.0;
  
  if(distance < (thresh+10)) {
    updateLights();
  }
  
  if(distance > (thresh-2.5) && distance < (thresh+2.5)) {
    rightHandShake(3);
  }
  
}


void makerFaireProgram() {
    
    while(!LDRclear()) {
		slapShot(1, 80, 0);
	}
    
}


void fftProgram() {
    
    
	while(!triggerFlag) {
		if(debug) Serial << "Trigger flag is false..." << endl;
		digitalWrite(STATUS, !digitalRead(STATUS));
		
        if(millis()%500 == 0) {
            updateLights();
        }
		
		// Send some data to the communication board
		if(second()%30 == 0 || second()%60 == 0) {
			
			digitalWrite(STATUS, LOW);
			
			digitalWrite(LED, HIGH);
			delay(500);
			digitalWrite(LED, LOW);
			
			// Signal that we want to send data
			digitalWrite(interruptOutgoing, HIGH);
			
			while(!triggerFlag) {
				// Waiting for trigger to send the data
				if(debug) Serial << "Waiting for the trigger" << endl;
				digitalWrite(LED, HIGH);
				delay(50);
				digitalWrite(LED, LOW);
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
				
				digitalWrite(LED, HIGH);
				delay(1000);
				digitalWrite(LED, LOW);
				
			}
			
			digitalWrite(interruptOutgoing, LOW);
			triggerFlag = false;
			
		}
		
	}
	
	if(triggerFlag) {
		
		if(debug) Serial << "Trigger flag is set, sending outgoing interrupt" << endl;
		digitalWrite(STATUS, LOW);
		
		digitalWrite(LED, HIGH);
		
		// Send the flag to receive the message
		digitalWrite(interruptOutgoing, HIGH);
		delay(10);
        
        byte y = nextByte();
		
		// Check if it's getting the message
		if(y == 'E') {
			// Show that we received the message
			
			if(debug) Serial << "Received the message" << endl;
			
			leftHandShake(1);
			
		}
        
        // --- Any
        if(y == 'P' || y == 'L' || y == 'R') {
            updateLights();
        }
        
        // --- P
        if(y == 'P') {
            if(debug) Serial << "Received a P!";
            bothArmJingle(1);
            ssc.setFrame(homeFrame, 100, 100);
        }
        
        // --- L
        if(y == 'L') {
            if(debug) Serial << "Received a L!";
            leftHandShake(1);
            ssc.setFrame(homeFrame, 100, 100);
        }
		
        // --- R
        if(y == 'R') {
            if(debug) Serial << "Received a L!";
            rightHandShake(1);
            ssc.setFrame(homeFrame, 100, 100);
        }
        
		
		delay(50);
		digitalWrite(LED, LOW);
		digitalWrite(interruptOutgoing, LOW);
		triggerFlag = false;
		
	}
    
}

void trigger() {
	triggerFlag = true;
}

byte nextByte() {
	while(1) {
		if(Serial1.available() > 0) {
			byte b = Serial1.read();
			if(debug) Serial << "Received byte: " << b << endl;
			return b;
		}
		if(debug) Serial << "Waiting for next byte" << endl;
	}
	
}



boolean LDRclear() {
	if(_leftLDRval() < (leftLDRhome - 10) && _rightLDRval() < (rightLDRhome - 10)) {
		Serial << "Shoot!" << endl;
		return false;
	} else {
		Serial << "No shoot!" << endl;
		return true;
	}
}

int _leftLDRval() {
	leftLDRval = analogRead(leftLDR);
	Serial << "Left LDR: " << leftLDRval << endl;
	return leftLDRval;
}

int _rightLDRval() {
	rightLDRval = analogRead(rightLDR);
	Serial << "Right LDR: " << rightLDRval << endl;
	return rightLDRval;
}


