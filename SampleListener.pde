class SampleListener extends Listener {

  float LEAP_WIDTH = leapH/2; //orig 200, in mm
  float LEAP_HEIGHT = leapW/2;//orig 700, in mm  
  PVector p = new PVector(0,0,0);
  boolean verboseDebug = false;
  
  void onInit(Controller controller) {
    if(verboseDebug) println("Initialized");
  }

  void onConnect(Controller controller) {
    if(verboseDebug) println("Connected");
  }

  void onDisconnect(Controller controller) {
    if(verboseDebug) println("Disconnected");
  }

  void onExit(Controller controller) {
    if(verboseDebug) println("Exited");
  }

void onFrame(com.leapmotion.leap.Controller controller) {
  //relative positioning based on LeapCircles by Grace Christenbery
  //println("Frame");
  com.leapmotion.leap.Frame frame = controller.frame();
  /*
    println("Frame id: " + frame.id()
   + ", timestamp: " + frame.timestamp()
   + ", hands: " + frame.hands().count()
   + ", fingers: " + frame.fingers().count()
   + ", tools: " + frame.tools().count());
   */

  // Get the first hand
  if(hands.length > 0){
  for (int i=0;i<hands.length;i++) {
    int foo = 0; 
    try{
      foo = hands[0].fingerCount;
    }catch(Exception qq){ }
    if(i==0 || i>0 && foo >0){ //crude way to check for two hands? throwing nullpointer errors
    try{
      hands[i].fingerCount = 0;
      hands[i].p = new PVector(0, 0, 0);
    }catch(Exception e){ }
    try {
      Hand hand = frame.hands().get(i);
      hands[i].idHand = i;
      // Get fingers
      FingerList fingers = hand.fingers();

      if (!frame.hands().empty()) {
        //Check if the hand has fingers.
        if (!fingers.empty()) {

          //Calculate the hand's average finger tip position
          com.leapmotion.leap.Vector avgPos =  com.leapmotion.leap.Vector.zero();
          for (Finger finger : fingers) {
            avgPos = avgPos.plus(finger.tipPosition());
          }
          avgPos = avgPos.divide(fingers.count());
          //println("Hand " + (i+1) + " has " + fingers.count() + " fingers, average finger tip position: " + avgPos);

          //Tell the position of the leaper's (user's) fingertip.
          Screen screen = controller.calibratedScreens().get(0);
           com.leapmotion.leap.Vector bottomLeftCorner = screen.bottomLeftCorner();
          //~~~
          for (int j=0;j<hands[i].oscFinger.length;j++) {
            hands[i].oscFinger[j].show = true;
            try {
              Finger pointer = fingers.get(j);
               com.leapmotion.leap.Vector point = pointer.tipPosition();
              //println("You are pointing at: " + point);
              float distance = screen.distanceToPoint(point);
              //println("The distance from the screen to your finger tip is: " + distance + "mm");

              //Tell what point on the screen the leaper is pointing at.
               com.leapmotion.leap.Vector screenPoint = screen.intersect(pointer, true);
              //println("You are pointing at this point on the screen: " + screenPoint);
              //The vector of the bottom left corner
              //println("Bottom-left Corner: " +  bottomLeftCorner);

              //Tell what pixel coordinate the leaper is pointing to.
              //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              PVector answer = new PVector(0,0,0);
              if(absPositioning){
                answer.x = leapToScreenX(point.get(0));
                answer.y = leapToScreenY(point.get(1));
              }else{
                answer.x = width*screenPoint.get(0);
                //Without subtracting from 1, the Y is inverted.
                answer.y = height*(1-abs(screenPoint.get(1)));
                //println("X Pixel: " + pixelX + "Y Pixel: " + pixelY);
              }
              //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

              answer.z = point.get(2);
              if(reverseZ) answer.z *= -1;
              //println(pixelX + " " + pixelY + " " + pixelZ);
              //Give the pixel values to pixelPoint for the draw() function.
              hands[i].oscFinger[j].p = answer;
              if(i>0 && hitDetect3D(hands[i].oscFinger[j].p, new PVector(5,5,5), hands[i-1].oscFinger[j].p, new PVector(5,5,5))) hands[i].oscFinger[j].show = false;
              hands[i].oscFinger[j].idFinger = j;
              try {
                if (hands[i].oscFinger[j].p.x > -10000 && hands[i].oscFinger[j].p.y > -10000 && hands[i].oscFinger[j].p.z > -10000) {
                  hands[i].p.add(hands[i].oscFinger[j].p);
                  hands[i].fingerCount++;
                }
              }
              catch(Exception e) {
              }
          }
            catch(Exception e) {
              hands[i].oscFinger[j].show = false;
            }
          }

          //~~~
        }
      }


      //Get the hand's normal vector and direction
      com.leapmotion.leap.Vector normal = hand.palmNormal();
      com.leapmotion.leap.Vector direction = hand.direction();

      //Calculate the hand's pitch, roll, and yaw angles
      /*
    println("Hand " + (i+1) + " pitch: " + Math.toDegrees(direction.pitch()) + " degrees, "
       + "roll: " + Math.toDegrees(normal.roll()) + " degrees, "
       + "yaw: " + Math.toDegrees(direction.yaw()) + " degrees\n");
       */
      hands[i].p.div(hands[i].fingerCount);
      if(i>0 && hitDetect3D(hands[i].p, new PVector(5,5,5), hands[i-1].p, new PVector(5,5,5))) hands[i].show = false;
      //println("hand " + hands[i].p + " " + hands[i].fingerCount);
      if (hands[i].p.x > -10000 && hands[i].p.y > -10000 && hands[i].p.z > -10000) hands[i].show = true;
    }
    catch(Exception e) {
      try{
        hands[i].show=false;
      }catch(Exception f){ }
    }
  }
  
  }//null check -- trying to protect against starting with no hands
  }
}

//~~~~~~~~~~~~~~~~~~~~~~ abs pos tools from example
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

}
