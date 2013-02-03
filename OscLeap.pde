import com.leapmotion.leap.*;

//based on oscP5parsing by andreas schlegel
import oscP5.*;
import netP5.*;

String ipNumber = "127.0.0.1";
int sendPort = 7110;
int receivePort = 33333;
OscP5 oscP5;
NetAddress myRemoteLocation;

SampleListener listener;
Controller controller;
Screen screen;
com.leapmotion.leap.Vector bottomLeftCorner;
com.leapmotion.leap.Frame frame;

void oscSetup() {
  oscP5 = new OscP5(this, receivePort);
  myRemoteLocation = new NetAddress(ipNumber, sendPort);
}

OscHand[] hands = new OscHand[2];

void oscLeapSetup() {
  oscSetup();
  listener = new SampleListener();
  controller = new Controller();
  controller.addListener(listener);
  //calibrates screen for relative positioning
  screen = controller.calibratedScreens().get(0);
  bottomLeftCorner = screen.bottomLeftCorner();
  //~~~~~~~~~~~~~~~
  for (int i=0;i<hands.length;i++) {
    hands[i] = new OscHand();
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
//~~~~~~~~~~~~~~~~~~~~~~~~~~~
  for (int i=0;i<hands.length;i++) {
      hands[i].run();
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~

}

void stop(){
  controller.removeListener(listener);
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

