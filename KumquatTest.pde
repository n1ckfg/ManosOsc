// Kumquat Cheering Section by Victoria Nece v.0.8 | www.victorianece.com
// 
// A very silly little experiment with the LeapMotion.
// 
// Requires LeapMotionP5: https://github.com/mrzl/LeapMotionP5
// Contains some code adapted from this forum post: http://forum.processing.org/topic/text-fade-in-out-over-specified-time
 

//import processing.opengl.*;
/*
import com.leapmotion.leap.Vector;
import com.onformative.leap.LeapMotionP5;

LeapMotionP5 leap;

static float LEAP_WIDTH = 200.0f; // in mm
static float LEAP_HEIGHT = 500.0f; // in mm
*/
// Hello from the kumquats
String[] quotes = {
  "The kumquats are watching.",
  "Don't worry.",  
  "The kumquats know you will do the right thing.",
  "They trust you.",
  "They understand.",
  "They are delicious.",  
  };
  

// Set up the text fader
int kumquatCounter;
final int DISPLAY_TIME = 3000; // 2000 ms = 2 seconds
int lastTime; // When the current image was first displayed

float alphaVal = 255;
float a = 1.5;

// Load the kumquat images into an array
PImage[] images = new PImage[3]; //image array
  

void kumquatSetup() {
//  size(800, 600, OPENGL); //Enable OpenGL rendering. Faster rendering but Tool Kumquats' eyes go weird.
  //size(800, 600); //No OpenGL. Slower but the eyes work.
  
  //leap = new LeapMotionP5(this);
  
  textFont(createFont("Ballpark", 32));
  lastTime = millis();
  
  images[0] = loadImage("kumquat.png");
  images[1] = loadImage("invertkumquat.png");
  images[2] = loadImage("openkumquat.png");
    
  //smooth();
}


void kumquatDraw() {
  background(255);
  


  // FINGER-TRACKED KUMQUATS
  for (Map.Entry entry : leap.getFingerPositions().entrySet()) {
    Integer fingerId = (Integer) entry.getKey();
    Vector position = (Vector) entry.getValue();
    stroke(0);
    strokeWeight(12.0);
    strokeCap(ROUND);
    
    pushMatrix();
      translate(leapToScreenX(position.getX()),leapToScreenY(position.getY()));
      
      line(35,height,35,50);
      	
    
      if (fingerId % 2 == 0) { 
      image(images[0],0,0);
      } else {
      image(images[1],0,0);  
      };
      
      fill(0);
      noStroke();
      ellipse(25,40,10,10);
      ellipse(50,40,10,10);
      triangle(20,65,55,65,38,75);
      popMatrix();
      
//    print("Finger:" + fingerId);

  }
  
  

  // TOOL-TRACKED KUMQUATS
  for (Map.Entry entry : leap.getToolPositions().entrySet()) {
    Integer toolId = (Integer) entry.getKey();
    Vector position = (Vector) entry.getValue();
    fill(leap.getToolColors().get(toolId));
    strokeWeight(12.0);
    strokeCap(ROUND);
    stroke(leap.getToolColors().get(toolId));
    
    pushMatrix();
      translate(leapToScreenX(position.getX()),leapToScreenY(position.getY()));
      
      line(35,height,35,50);
      
      if (toolId > 10)  {
        image(images[2],0,0);
        } else {
            if (toolId % 2 == 0) { 
              image(images[1],0,0);
              } else {
              image(images[0],0,0);  
              }
        };

      stroke(255);
      ellipse(25, 40,5,5);
      ellipse(50, 40,5,5);
      noStroke();
      ellipse(38, 75,15,10);

      popMatrix();
      
//   print("Tool:" + toolId); 
  }
  
  
  
//  TEXT CYCLER  
  textAlign(CENTER);
   if (millis() - lastTime >= DISPLAY_TIME) // Time to display next image
  {
    kumquatCounter = int(random(quotes.length));
    alphaVal = 255;
    lastTime = millis();
  }
  fill(0, 0, 0, alphaVal);
  text(quotes[kumquatCounter], 0, 50, 800, 550);
  alphaVal -= a;



//  println(frameRate);
}



/*
void stop() {
  leap.stop();
  super.stop();
}

float leapToScreenX(float x) {
  float c = width / 2.0f;
  if (x > 0.0) {
    return lerp(c, width, x / LEAP_WIDTH);
  } 
  else {
    return lerp(c, 0.0f, -x / LEAP_WIDTH);
  }
}

float leapToScreenY(float y) {
  return lerp(height, 0.0f, y / LEAP_HEIGHT);
}
*/
