void oscSetup() {
  oscP5 = new OscP5(this, receivePort);
  myRemoteLocation = new NetAddress(ipNumber, sendPort);
}

void oscLeapSetup() {
  oscSetup();
  if(numberOfHands>0){
    listener = new SampleListener();
    controller = new Controller();
    controller.addListener(listener);
    for (int i=0;i<hands.length;i++) {
      hands[i] = new OscHand();
    }
    //~~~~~~~~~~~~~~~
  }else{
    leap = new LeapMotionP5(this);
    if(numberOfHands==0){
       singleFinger = new OscSingleFinger();
       singleTool = new OscSingleTool();
     }
  }
}

void oscLeapUpdate() {
  //stuff from Alex's
  /*
  try {
    System.in.read();
  }catch (IOException e) {
    e.printStackTrace();
  }*/
  if(numberOfHands>0){
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~
    for (int i=0;i<hands.length;i++) {
      try{
        hands[i].run();
      }catch(Exception e){ }
    }
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }else{
    try{
      singleFingerToolHandler();
    }catch(Exception e){ }
  }
}

void singleFingerToolHandler(){
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //single finger mode
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  try{
    singleFinger.show = true;
    singleTool.show = true;
    
    for (Map.Entry entry : leap.getFingerPositions().entrySet()) {
      Integer fingerId = (Integer) entry.getKey();
      Vector position = (Vector) entry.getValue();
      singleFinger.p = getAnswer(position);
      singleFinger.show = true;
    }
    
    for (Map.Entry entry : leap.getToolPositions().entrySet()) {
      Integer toolId = (Integer) entry.getKey();
      Vector position = (Vector) entry.getValue();
      singleTool.p = getAnswer(position);
      singleTool.show = true;
    }
 
  singleFinger.run();
  singleTool.run();
  }catch(Exception e){ }
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}

PVector getAnswer(Vector position){
  PVector answer = new PVector(0,0,0);
  answer.x = leapToScreenX(position.getX());
  answer.y = leapToScreenY(position.getY());
  answer.z = position.get(2);
  if(reverseZ){
    answer.z *= -1;
  }
  return answer;
}
//~~~duplicated from SampleListener

  float LEAP_WIDTH = leapH/2; //orig 200, in mm
  float LEAP_HEIGHT = leapW/2;//orig 700, in mm 
  
float leapToScreenX(float x){
  float c = width / 2.0;
  if (x > 0.0)  {
    return lerp(c, width, x/LEAP_WIDTH);
  }else{
    return lerp(c, 0.0, -x/LEAP_WIDTH);
  }
}

float leapToScreenY(float y){
  return lerp(height, 0.0, y/LEAP_HEIGHT);
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void stop(){
  controller.removeListener(listener);
  leap.stop();
  super.stop();
}

//2D Hit Detect.  Assumes center.  x,y,w,h of object 1, x,y,w,h, of object 2.
boolean hitDetect(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  w1 /= 2;
  h1 /= 2;
  w2 /= 2;
  h2 /= 2; 
  if(x1 + w1 >= x2 - w2 && x1 - w1 <= x2 + w2 && y1 + h1 >= y2 - h2 && y1 - h1 <= y2 + h2) {
    return true;
  } 
  else {
    return false;
  }
}

    //3D Hit Detect.  Assumes center.  xyz, whd of object 1, xyz, whd of object 2.
  boolean hitDetect3D(PVector p1, PVector s1, PVector p2, PVector s2) {
    s1.x /= 2;
    s1.y /= 2;
    s1.z /= 2;
    s2.x /= 2;
    s2.y /= 2; 
    s2.z /= 2; 
    if (  p1.x + s1.x >= p2.x - s2.x && 
          p1.x - s1.x <= p2.x + s2.x && 
          p1.y + s1.y >= p2.y - s2.y && 
          p1.y - s1.y <= p2.y + s2.y &&
          p1.z + s1.z >= p2.z - s2.z && 
          p1.z - s1.z <= p2.z + s2.z
      ) {
      return true;
    } 
    else {
      return false;
    }
  }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

