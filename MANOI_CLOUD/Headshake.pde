
void headshake(int repeat, int moveTime, int delayTime) {
  
 int head_f1[17] = {
      HOME0+150,
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
    
 int head_f2[17] = {
      HOME0-150,
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
  
  
  
 for(int i=0; i<=repeat; i++) {
  
  // Frame 1
  ssc.setFrame(homeFrame, moveTime, delayTime);
  
  // Frame 2
  ssc.setFrame(head_f1, moveTime, delayTime);
  
  // Frame 3
  ssc.setFrame(head_f2, moveTime, delayTime);
  
  // Frame 4
  ssc.setFrame(homeFrame, moveTime, delayTime);
  
 }
 
 
 
 lastMove = 4;
 
}

