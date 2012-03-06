
void leftWing(int repeat, int speed) {
    
  int l = WING_L_LOWER;
  int u = WING_L_UPPER;
  
    for(int j=0; j<repeat; j++) {
    
        for(int i=l; i<u; i++) {
            leftwing.write(i);
        }
        delay(speed);
        
        for(int i=u; i>l; i--) {
            leftwing.write(i);
        }
        delay(speed);
        
    }
}


void rightWing(int repeat, int speed) {
    
    int l = WING_R_LOWER;
    int u = WING_R_UPPER;
    
    for(int j=0; j<repeat; j++) {
        
        for(int i=u; i<l; i++) {
            rightwing.write(i);
        }
        delay(speed);
        
        for(int i=l; i>u; i--) {
            rightwing.write(i);
        }
        delay(speed);
        
    }
}

void bothWings(int repeat, int speed) {
    
  Serial << "hello" << endl;
  
    int rl = WING_R_LOWER;
    int ll = WING_L_LOWER;
    
    for(int j=0; j<repeat; j++) {
        
        for(int i=0; i<40; i++) {
            leftwing.write(rl-20-i);
            rightwing.write(ll+i);
        }
        delay(speed);
        
        for(int i=40; i>0; i--) {
            leftwing.write(rl-20-i);
            rightwing.write(ll+i);
        }
        delay(speed);
        
    }
}

void moveLeftWing(boolean goUp) {

  int up = 60; // 60
  int down = 120; // 0

    if(goUp) {

    for(int i=up; i<down; i++) {
      leftwing.write(i);
      //delay(100);
    }

  } 
  else {

    for(int i=down; i>up; i--) {
      leftwing.write(i);
      //delay(100);
    }

  }

}

void moveRightWing(boolean goUp) {

  int up = 0;
  int down = 60;

  if(!goUp) {

    for(int i=up; i<down; i++) {
      rightwing.write(i);
      //delay(200);
      //Serial << i << endl;
    }

  } 
  else {

    for(int i=down; i>up; i--) {
      rightwing.write(i);
      //delay(200);
      //Serial << i << endl;
    }

  }

}


