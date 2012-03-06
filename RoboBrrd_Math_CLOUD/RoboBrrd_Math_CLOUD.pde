
import processing.net.*;
import processing.serial.*;

Serial arduino;

String SERVER = "bots.myrobots.com"; // MyRobots or ThingSpeak
String APIKEY = "5EE8A490BB6F4CFA"; // your channel's API key


int FREQ = 15; // update every 15s

Client c;
String data;

int sec_0 = 88; // previous second, silly value
int sec; // time counter


String[] fields = { 
  "field1", "field2", "field3", "field4", "field5", "field6"
};
float[] datum = new float[6];

float combinedEnthusiasm = 0;
float previousEnthusiasm = 0;
int ce_count = 0;


int hat;
int tries;
int correct;
int levels;
float brainpower;
String statusUpdate;
boolean randomStatusUpdate;

void setup() {
  size(200, 200);
  frameRate(60);

  int port = 0;

  for (int i=0; i<Serial.list().length; i++) {
    println(Serial.list()[i]);
    if (Serial.list()[i].equals("/dev/tty.usbserial-A900F5IY")) {
      println("ding!");
      port = i;
    }
  }

  arduino = new Serial(this, Serial.list()[port], 9600);

  println("Hi!");
}


void draw() {

  if (arduino.available() > 0) {
    while (arduino.available () > 0) {
      char crx = arduino.readChar();
      print(crx);
      parsePacket(crx);
    }
  }


  if (c != null) {
    if (c.available() > 0) {
      data = c.readString();
      println("entry_id: " + data + "\n");
    }
  }

  sec = second();

  if (sec%FREQ == 0 && sec_0 != sec) {
    println("\n\nding!");
    sec_0 = sec;

    float ratio = 0.0;
    if(tries == 0) {
      ratio = 0.0;
    } else {
      ratio = (correct/tries); 
    }

    datum[0] = ratio+combinedEnthusiasm+(100*levels);
    datum[1] = combinedEnthusiasm;
    datum[2] = correct;
    datum[3] = tries;
    datum[4] = levels;
    datum[5] = hat;

    combinedEnthusiasm = 0;
    ce_count = 0;

    if(randomStatusUpdate) {
    
    int randomstatus = (int)random(0, 3);
    
    switch(randomstatus) {
      case 0:
        statusUpdate = "I <3 MATH!";
        break;
      case 1:
        statusUpdate = "cool";
        break;
      case 3:
        statusUpdate = ("I just put on hat #" + hat);
        break;
    }

    } else {
      randomStatusUpdate = true; 
    }

    sendDatum(fields, datum, statusUpdate);
    println("done");
  } 
  else {
    if (sec != sec_0) {
      print(sec + " ");
      sec_0 = sec;
    }
  }
}

void sendData(String field, float num) {

  String url = ("GET /update?key="+APIKEY+"&"+field+"=" + num + "\n");
  print("sending data: " + url);

  c = new Client(this, SERVER, 80);
  if (c != null) c.write(url);
}

void sendDatum(String fields[], float num[], String statusupdate) {

  String url = ("GET /update?key="+APIKEY);
  StringBuffer sb = new StringBuffer(url);

  for (int i=0; i<fields.length; i++) {
    String s = ("&"+fields[i]+"="+datum[i]);
    sb.append(s);
  }

  sb.append("&status=" + statusupdate + "\n");

  String finalurl = sb.toString();
  print("sending data: " + finalurl);

  c = new Client(this, SERVER, 80);
  if (c != null) c.write(finalurl);
}


void enthusiasmParse(char numnum) {

  int plus = 0;

  plus = gimmieNumber(numnum);

  combinedEnthusiasm += plus;

  println("::::::::::::::::::::::: " + combinedEnthusiasm);
}

void actionParse(char numnum) {
  
  int res = gimmieNumber(numnum);
  println(":::::::::::: action: " + res);
  
  switch(res) {
       case 0: {
         // left
         //if(command == 0) leftWing(3, 100);
         break; 
        }
        case 1: {
          // right
          //if(command == 0) rightWing(3, 100);
          break; 
        }
        case 2: {
          // open beak
          //if(command == 0) openBeak(10, 5);
          break; 
        }
        case 3: {
          // close beak
          //if(command == 0) closeBeak(10, 5);
          break; 
        }
        case 4: {
          // shake
          //if(command == 0) shake(2);
          break;
        }
        case 5: {
          // eyes
          //if(command == 0) updateLights();
          break;  
        }
        case 6: {
          // victory
          //if(command == 0) doVictory();
          levels++;
          tries++;
          randomStatusUpdate = false;
          statusUpdate = ("LEVEL UP WOOT WOOT! Now on level " + levels);
          break;
        }
        case 7: {
          // match
          //if(command == 0) doMatch();
          correct++;
          tries++;
          break; 
        }
        case 8: {
          // wrong
          //if(command == 0) doWrong();
          tries++;
          break; 
        }
     }
  
}

void hatParse(char numnum) {
  
  hat = gimmieNumber(numnum);
  println(":::::::::::: hat: " + hat);
  
}

void parsePacket(char crx) {

  if (crx == '|') {
    byte[] buff = new byte[7];
    
    while(arduino.available() < 10) {
      //;
    }
    
    arduino.readBytesUntil('#', buff);
    println("yes");
    if (buff != null && buff.length > 4) {

      String myString = new String(buff);
      print("the buffer: ");
      println(myString);

      if (buff[0] == 'R' && buff[1] == 'E' && buff[2] == 'D') {
        println("red");
        if (buff[3] == ';') {

          if (buff[4] == 'E') {
            enthusiasmParse((char)buff[5]);
          } 
          else if (buff[4] == 'A') {
            actionParse((char)buff[5]);
          } else if(buff[4] == 'H') {
            hatParse((char)buff[5]);
          }
        } 
        else {
          println("no ;e");
        }
      } 
      else {
        println("no red");
      }
    } 
    else {
      if (buff != null) println(buff.length);
    }
  }
}


int gimmieNumber(char charnum) {

  int res = 0;
  
  switch(charnum) {
  case '0':
    res=0;
    break;
  case '1':
    res= 1;
    break;
  case '2':
    res= 2;
    break;
  case '3':
    res= 3;
    break;
  case '4':
    res= 4;
    break;
  case '5':
    res= 5;
    break;
  case '6':
    res= 6;
    break;
  case '7':
    res= 7;
    break;
  case '8':
    res= 8;
    break;
  case '9':
    res= 9;
    break;
  }
  
  return res;
  
}

