import com.leapmotion.leap.Controller;
//import com.leapmotion.leap.Frame;
import com.leapmotion.leap.Hand;
import com.leapmotion.leap.FingerList;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.Vector;
import com.leapmotion.leap.Screen;
import com.leapmotion.leap.processing.LeapMotion;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//based on oscP5parsing by andreas schlegel
import oscP5.*;
import netP5.*;

String ipNumber = "127.0.0.1";
int sendPort = 7110;
int receivePort = 4321;
OscP5 oscP5;
NetAddress myRemoteLocation;
//---
/*
String[] oscChannelNames = { 
  "hand0", "hand0-0", "hand0-1", "hand0-2", "hand0-3", "hand0-4", "hand1", "hand1-0", "hand1-1", "hand1-2", "hand1-3", "hand1-4"
};
float[] oscSendData = { 
  0, 0, 0
};
*/

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//1.  This function initializes OSC.  Put it in your setup().
void oscSetup() {
  oscP5 = new OscP5(this, receivePort);
  myRemoteLocation = new NetAddress(ipNumber, sendPort);
}

//2.  This function sends OSC.  Put it in your draw(), or in control functions like mousePressed() and keyPressed().
/*
void oscSend() {
  //--
  if (sendOsc) {
    OscMessage myMessage;

    for (int i=0;i<oscChannelNames.length;i++) {
      myMessage = new OscMessage("/" + oscChannelNames[i]);
      for(int j=0;j<oscSendData.length;j++){
        myMessage.add(oscSendData[j]);
      }
      oscP5.send(myMessage, myRemoteLocation);
    }
  }
}
*/

void oscTest(){
  if (sendOsc) {
    OscMessage myMessage;
    myMessage = new OscMessage("/foo");
    myMessage.add(0);
    oscP5.send(myMessage, myRemoteLocation);
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LeapMotion leapMotion;
OscHand[] hands = new OscHand[2];

void oscLeapSetup() {
  oscSetup();
  leapMotion = new LeapMotion(this);
  for (int i=0;i<hands.length;i++) {
    hands[i] = new OscHand();
  }
}

void oscLeapUpdate() {
  for (int i=0;i<hands.length;i++) {
    hands[i].run();
  }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void onFrame(final Controller controller) {
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
    if(i==0 || i>0 && hands[0].fingerCount >0){ //crude way to check for two hands?
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
          Vector avgPos = Vector.zero();
          for (Finger finger : fingers) {
            avgPos = avgPos.plus(finger.tipPosition());
          }
          avgPos = avgPos.divide(fingers.count());
          //println("Hand " + (i+1) + " has " + fingers.count() + " fingers, average finger tip position: " + avgPos);

          //Tell the position of the leaper's (user's) fingertip.
          Screen screen = controller.calibratedScreens().get(0);
          Vector bottomLeftCorner = screen.bottomLeftCorner();
          //~~~
          for (int j=0;j<hands[i].oscFinger.length;j++) {
            hands[i].oscFinger[j].show = true;
            try {
              Finger pointer = fingers.get(j);
              Vector point = pointer.tipPosition();
              //println("You are pointing at: " + point);
              float distance = screen.distanceToPoint(point);
              //println("The distance from the screen to your finger tip is: " + distance + "mm");

              //Tell what point on the screen the leaper is pointing at.
              Vector screenPoint = screen.intersect(pointer, true);
              //println("You are pointing at this point on the screen: " + screenPoint);
              //The vector of the bottom left corner
              //println("Bottom-left Corner: " +  bottomLeftCorner);

              //Tell what pixel coordinate the leaper is pointing to.
              float pixelX = width*screenPoint.get(0);
              //Without subtracting from 1, the Y is inverted.
              float pixelY = height*(1-abs(screenPoint.get(1)));
              //println("X Pixel: " + pixelX + "Y Pixel: " + pixelY);

              float pixelZ = -1 * point.get(2);
              //println(pixelX + " " + pixelY + " " + pixelZ);
              //Give the pixel values to pixelPoint for the draw() function.
              hands[i].oscFinger[j].p = new PVector(pixelX, pixelY, pixelZ);
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
      Vector normal = hand.palmNormal();
      Vector direction = hand.direction();

      //Calculate the hand's pitch, roll, and yaw angles
      /*
    println("Hand " + (i+1) + " pitch: " + Math.toDegrees(direction.pitch()) + " degrees, "
       + "roll: " + Math.toDegrees(normal.roll()) + " degrees, "
       + "yaw: " + Math.toDegrees(direction.yaw()) + " degrees\n");
       */
      hands[i].p.div(hands[i].fingerCount);
      if(i>0 && hitDetect3D(hands[i].p, new PVector(5,5,5), hands[i-1].p, new PVector(5,5,5))) hands[i].show = false;
      println("hand " + hands[i].p + " " + hands[i].fingerCount);
      if (hands[i].p.x > -10000 && hands[i].p.y > -10000 && hands[i].p.z > -10000) hands[i].show = true;
    }
    catch(Exception e) {
      try{
        hands[i].show=false;
      }catch(Exception f){ }
    }
  }
  }
  }//null check -- trying to protect against starting with no hands
}

//--

void onInit(final Controller controller) {
  //println("Initialized");
}

void onConnect(final Controller controller) {
  //println("Connected");
}

void onDisconnect(final Controller controller) {
  //println("Disconnected");
}

void onExit(final Controller controller) {
  //println("Exited");
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

