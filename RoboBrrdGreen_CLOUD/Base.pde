
void goLeft(int pause) {
  
  int currentPos = leftright.read();
  
  for(int i=currentPos; i>0; i--) {
    leftright.write(i);
    delay(pause);
  }
  
  currentDir = 0;
  
}

void goRight(int pause) {
  
  int currentPos = leftright.read();
  
  for(int i=currentPos; i<180; i++) {
    leftright.write(i);
    delay(pause);
  }
  
  currentDir = 2;
  
}

void goMiddle(int pause) {
  
  int currentPos = leftright.read();
  
  if(currentPos > 90) {
    
    for(int i=currentPos; i>90; i--) {
      leftright.write(i);
      delay(pause);
    }
    
  } else {
   
   for(int i=currentPos; i<90; i++) {
     leftright.write(i);
     delay(pause);
   }
    
  }
  
  currentDir = 1;
  
}

void leftrightTest() {
 
  int left = 0;
  int right = 180;
  
  for(int i=left; i<right; i++) {
    leftright.write(i);
    delay(100);
  }
  
  for(int i=right; i>left; i--) {
    leftright.write(i);
    delay(100);
  }
  
}

void updownTest(int d) {
 
  int up = 80;
  int down = 105;
  
  for(int i=up; i<down; i++) {
    updown.write(i);
    delay(d);
  }
  
  delay(500);
  
  for(int i=down; i>up; i--) {
    updown.write(i);
    delay(d);
  }
  
}

void moveUpDown(int target, int d) {
  int currentUp = updown.read();
            
            if(currentUp > target) {
                
                for(int i=currentUp; i>target; i--) {
                    updown.write(i);
                    delay(d);
                }
                
            } else {
                
                for(int i=currentUp; i<target; i++) {
                    updown.write(i);
                    delay(d);
                }
                
            }
}

