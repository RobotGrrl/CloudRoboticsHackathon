/*
 * Impy RoboBrrd @ Cloud Robotics Hackathon
 * March 3, 2012
 * robotgrrl.com
 *
 */

#include <Servo.h> 
#include <Streaming.h>
#include <PN532.h>

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


#define SCK 13
#define MOSI 11
#define SS 10
#define MISO 12

PN532 nfc(SCK, MISO, MOSI, SS);

Servo beakServo, rwingServo, lwingServo, rotationServo;

// Servos
int BEAK = 9;
int RWING = 8;
int LWING = 7;
int ROTATION = 6;
int HULA = 4;

// LEDs
int RED = A5;
int GREEN = A4;
int BLUE = A3;

// Misc
int SPKR = 5;
int LDR_R = A0;
int LDR_L = A1;

// Positions
int BEAK_OPEN = 75;
int BEAK_CLOSED = 30;
int BEAK_MIDDLE = 53;

int RWING_UP = 130;
int RWING_DOWN = 65;
int RWING_MIDDLE = 80;

int LWING_UP = 70;
int LWING_DOWN = 135;
int LWING_MIDDLE = 110;

int LEFT = 180;
int RIGHT = 0;
int MIDDLE = 90;

int pos = RWING_DOWN;
char c_char;
boolean stopped = false;
boolean forwards = true;

int ledR = 0;
int ledG = 0;
int ledB = 0;

int ledR_0 = 255;
int ledG_0 = 255;
int ledB_0 = 255;

int fadeCount = 0;
int fadeColour = 0;


int turn = 0;
boolean left = false;

int ldrLprev;
int ldrRprev;
int thresh = 30;

int hat = 0;
int phat = 0;

int ldrL_home;
int ldrR_home;
int ldr_thresh = 30;

char pulse = 'n';
boolean recu = false;
int repcount = 0;
int lastpulse = 0;

char mathcommand;
char mathaction;

float ldrl_avg = 0;
float ldrr_avg = 0;
float ldrl_avg0 = 0;
float ldrr_avg0 = 0;
int ldravgcount = 0;

int hatstep = 0;
boolean photovore = false;

void setup()  {

  Serial.begin(9600);

  Serial.println("Jellow!");

  Serial1.begin(9600);

  XNPsetHostsFile(); 

  Serial.println("Hello!");


  nfc.begin();
  Serial.println("nfc begin!");

  uint32_t versiondata = nfc.getFirmwareVersion();
  if (! versiondata) {
    Serial.print("Didn't find PN53x board");
    while (1); // halt
  }
  // Got ok data, print it out!
  Serial.print("Found chip PN5"); 
  Serial.println((versiondata>>24) & 0xFF, HEX); 
  Serial.print("Firmware ver. "); 
  Serial.print((versiondata>>16) & 0xFF, DEC); 
  Serial.print('.'); 
  Serial.println((versiondata>>8) & 0xFF, DEC);
  Serial.print("Supports "); 
  Serial.println(versiondata & 0xFF, HEX);

  // configure board to read RFID tags and cards
  nfc.SAMConfig();
  Serial.println("nfc samconfig!");


  // Attach all the servos
  beakServo.attach(BEAK);
  rwingServo.attach(RWING);
  lwingServo.attach(LWING);
  rotationServo.attach(ROTATION);

  // Set the servos
  beakServo.write(BEAK_MIDDLE);
  rwingServo.write(RWING_MIDDLE+20);
  lwingServo.write(LWING_MIDDLE-20);
  rotationServo.write(MIDDLE);

  // Set up all the other pins
  pinMode(HULA, OUTPUT);
  digitalWrite(HULA, LOW);

  pinMode(LDR_R, INPUT);
  pinMode(LDR_L, INPUT);

  pinMode(SPKR, OUTPUT);
  pinMode(RED, OUTPUT);
  pinMode(BLUE, OUTPUT);
  pinMode(GREEN, OUTPUT);

  // Evaluate LDRs
  evaluateLDRs();

  // Random chirp!
  //randomChirp();

} 


void loop() { 

  XNPreadSerialBus();
  
  checkNFC();

  XNPreadSerialBus();

  if(hat != phat) {

    Serial << "|RED;H" << hat << "#" << endl;
    XNPhatSend();

  }
  
  hatUpdate();

  phat = hat;

  enthusiasmSensors();



  if(ENABLE_PACKET_ENGINE == 1) {

    XNPreadSerialBus();

    Serial.println("\n pulse: " + pulse);

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


  XNPreadSerialBus();

}


void doVictory() {

  digitalWrite(RED, HIGH);
  digitalWrite(GREEN, LOW);
  digitalWrite(BLUE, HIGH);

  beakServo.write(BEAK_OPEN);

  wingsWave();
  rwingWave();
  lwingWave();

  for(int ii=0; ii<5; ii++) {
    rotationServo.write(MIDDLE+100);
    delay(100);
    rotationServo.write(MIDDLE-100);
    delay(100);
  }

  rotationServo.write(MIDDLE);

  beakServo.write(BEAK_CLOSED);

  updateLights();

}

void doMatch() {

  digitalWrite(RED, HIGH);
  digitalWrite(GREEN, LOW);
  digitalWrite(BLUE, HIGH);

  wingsWave();

  updateLights();

}

void doWrong() {

  digitalWrite(RED, LOW);
  digitalWrite(GREEN, HIGH);
  digitalWrite(BLUE, HIGH);

  shakeNo();

  updateLights();

}


void enthusiasmSensors() {

  ldrl_avg += analogRead(LDR_L);
  ldrr_avg += analogRead(LDR_R);

  if(ldravgcount > 4) {

    float enth_l = abs(ldrl_avg0 - ldrl_avg);
    float enth_r = abs(ldrr_avg0 - ldrr_avg);

    float totalenth = (enth_l + enth_r)/2;

    enthusiasmSend(totalenth);

    ldrl_avg0 = ldrl_avg;
    ldrr_avg0 = ldrr_avg;

    ldravgcount = 0; 
  } 
  else {
    ldravgcount++; 
  }

}

void enthusiasmSend(float totalenth) {

  if(totalenth > 500) totalenth = 500;
  if(totalenth < 300) totalenth = 300;

  int finalenth = map(totalenth, 300, 500, 0, 10);

  if(finalenth > 9) finalenth = 9;
  if(finalenth < 0) finalenth = 0;

  Serial << "|RED;E" << finalenth << "#" << endl;

  //Serial.println("!RED;E" + (int)totalenth + "#");
}

void XNPhatSend() {

  Serial.println("sending func"); 
//  delay(50);

  sprintf(destination, "LP");

  sprintf(payload, "H%d", hat);    

  XNPsendDataPacket(destination, payload, 3);

}


void checkNFC() {

  uint32_t id;
  // look for MiFare type cards
  id = nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A);

  if (id != 0) {

    uint8_t keys[]= {
      0xFF,0xFF,0xFF,0xFF,0xFF,0xFF                                };
    if(nfc.authenticateBlock(1, id ,0x08,KEY_A,keys)) //authenticate block 0x08
    {
      //if authentication successful
      uint8_t block[16];
      //read memory block 0x08
      if(nfc.readMemoryBlock(1,0x08,block)) {
        //if read operation is successful

        if(block[0] == 1) {
          //Serial.println("top hat");
          hat = 1;
        } 
        else if(block[0] == 2) {
          //Serial.println("red maker hat");
          hat = 2;
        } 
        else if(block[0] == 3) {
          //Serial.println("purple robot hat");
          hat = 3;
        } 
        else if(block[0] == 4) {
          //Serial.println("green hat");
          hat = 4;
        }

      }
    }
  } 
  else {
    //Serial.println("no hat");
    hat = 0;
  }

}

void hatUpdate() {
 
    switch (hat) {
        case 0:
            eyesWhite();
            break;
        case 1: // top hat
            
            photovore = false;
            //photovoreCheck();
            
            switch (hatstep) {
                case 0:
                    for(int i=0; i<3; i++) {
                        eyesWhite();
                        delay(100);
                        eyesBlue();
                        delay(100);
                    }
                    break;
                case 1:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<5; i++) {
                        playTone(260, 70);
                        playTone(280, 70);
                        playTone(300, 70);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                case 2:
                    rwingWave();
                    break;
                case 3:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<5; i++) {
                        playTone(80, 70);
                        playTone(100, 70);
                        playTone(120, 70);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                case 4:
                    lwingWave();
                    break;
                case 5:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<5; i++) {
                        playTone(160, 70);
                        playTone(180, 70);
                        playTone(200, 70);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                default:
                    break;
            }
            
            hatstep++;
            if(hatstep > 5) hatstep = 0; 
            
            break;
        case 2: // red maker hat
            
            photovore = false;
            //photovoreCheck();
            
            switch (hatstep) {
                case 0:
                    for(int i=0; i<3; i++) {
                        eyesWhite();
                        delay(100);
                        eyesRed();
                        delay(100);
                    }
                    break;
                case 1:
                    wingsExcited();
                    break;
                case 2:
                    for(int i=0; i<3; i++) {
                        beakServo.write(BEAK_OPEN);
                        delay(300);
                        beakServo.write(BEAK_CLOSED);
                        delay(300);
                    }
                    break;
                case 3:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<5; i++) {
                        playTone(200, 70);
                        playTone(300, 140);
                        playTone(100, 70);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                case 4:
                    for(int i=0; i<2; i++) {
                        rotationServo.write(MIDDLE+10);
                        delay(200);
                        rotationServo.write(MIDDLE-10); 
                        delay(200);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                case 5:
                    rwingWave();
                    break;
                default:
                    break;
            }
            
            hatstep++;
            if(hatstep > 5) hatstep = 0;
            
            break;
        case 3: // purple robot hat
            
            photovore = true;
            //photovoreCheck();
            
            switch (hatstep) {
                case 0:
                    for(int i=0; i<3; i++) {
                        eyesWhite();
                        delay(100);
                        eyesPurple();
                        delay(100);
                    }
                    break;
                case 1:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<5; i++) {
                        playTone(150, 100);
                        playTone(100, 70);
                        playTone(200, 80);
                        playTone(300, 70);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                case 2:
                    wingsExcited();
                    break;
                case 3:
                    for(int i=0; i<2; i++) {
                        rotationServo.write(MIDDLE+40);
                        delay(300);
                        rotationServo.write(MIDDLE-40); 
                        delay(300);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                case 4:
                    for(int i=0; i<5; i++) {
                        digitalWrite(HULA, HIGH);
                        delay(5);
                        digitalWrite(HULA, LOW);
                        delay(100);
                    }
                    break;
                case 5:
                    beakServo.write(BEAK_OPEN);
                    delay(300);
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    beakServo.write(BEAK_OPEN);
                    delay(300);
                    beakServo.write(BEAK_MIDDLE);
                    delay(300);
                    beakServo.write(BEAK_OPEN);
                    delay(300);
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                    
                default:
                    break;
            }
            
            hatstep++;
            if(hatstep > 5) hatstep = 0;
            
            break;
        case 4: // green hat
            
            switch (hatstep) {
                case 0:
                    for(int i=0; i<3; i++) {
                        eyesWhite();
                        delay(100);
                        eyesGreen();
                        delay(100);
                    }
                    break;
                case 1:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<3; i++) {
                        playTone(80, 100);
                        playTone(60, 70);
                        playTone(30, 80);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                case 2:
                    for(int i=0; i<5; i++) {
                        rotationServo.write(MIDDLE+60);
                        delay(300);
                        rotationServo.write(MIDDLE-60); 
                        delay(300);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                case 3:
                    for(int i=0; i<5; i++) {
                        rotationServo.write(MIDDLE+40);
                        delay(100);
                        rotationServo.write(MIDDLE-40); 
                        delay(100);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                case 4:
                    for(int i=0; i<5; i++) {
                        rotationServo.write(MIDDLE+60);
                        delay(300);
                        rotationServo.write(MIDDLE-60); 
                        delay(300);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                case 5:
                    for(int i=0; i<5; i++) {
                        rotationServo.write(MIDDLE+40);
                        delay(100);
                        rotationServo.write(MIDDLE-40); 
                        delay(100);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                    
                default:
                    break;
            }
            
            hatstep++;
            if(hatstep > 5) hatstep = 0;
            
            break;
        default:
            break;
    }
  
}








