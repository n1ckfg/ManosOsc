import processing.opengl.*;

OscHand[] hands = new OscHand[2];

int leapW = 16*50;
int leapH = 9*50;
int sW = leapW;
int sH = leapH;
int sD = 400;
int fps = 60;
float ease = 10;

void setup(){
  Settings settings = new Settings("settings.txt");
  //~~
  sW = displayWidth;
  sH = displayHeight;
  sD = int(0.5 * (sW + sH));
  noCursor();
  //~~
  size(sW,sH,OPENGL);
  oscSetup();
  frameRate(fps);
  background(0);
  for (int i=0;i<hands.length;i++) {
    hands[i] = new OscHand();
  }
  //setupGl();
}

void draw(){
  background(0);

  for (int i=0;i<hands.length;i++) {
    hands[i].run();
  }
  
  println(frameRate);
}

 //Tween movement.  start, end, ease (more = slower).
  float tween(float v1, float v2, float e) {
    v1 += (v2-v1)/e;
    return v1;
  }

  PVector tween3D(PVector v1, PVector v2, PVector e) {
    v1.x += (v2.x-v1.x)/e.x;
    v1.y += (v2.y-v1.y)/e.y;
    v1.z += (v2.z-v1.z)/e.z;
    return v1;
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
