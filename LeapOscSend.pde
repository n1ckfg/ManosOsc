//LeapOscSend by Nick Fox-Gieg | fox-gieg.com

//NOTE: The Leap Processing library doesn't seem to like OpenGL.
//It'll crash on startup, or shortly after, about 2 out of 3 times.
//I'm leaving OpenGl on because it provides a 2x speed boost and 3D position.

import processing.opengl.*;
//abs pos stuff
import java.util.Map;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.ConcurrentHashMap;
//
int leapW = 16*50;
int leapH = 9*50;
int sW = leapW;
int sH = leapH;
int sD = 400;
int fps = 60;
boolean debug = true;
boolean showTraces = true;
float timeToTrace = 0.5;
boolean sendOsc = true;
boolean absPositioning = false;
boolean reverseZ = true;

PFont font;
String fontFace = "Arial";
int fontSize = 12;
int fontOverSample = 2;

void setup() {
  Settings settings = new Settings("settings.txt");
  oscLeapSetup();
  size(sW,sH,OPENGL);
  frameRate(fps);
  background(0);
  frameCount = 0;
  font = createFont(fontFace, fontOverSample*fontSize);
  textFont(font, fontSize);
  }

void draw() {
    if(debug){
    background(0);
    noStroke();
    fill(255);
    textAlign(CORNER);
    text("Press TAB to toggle debug display, SPACE to toggle positioning.",10,20);
    String sayText;
    if(absPositioning){
      sayText = "ON";
    }else{
      sayText = "OFF";
    }
    text("Absolute positioning is " + sayText + ".",10,20+(1.25*fontSize));
  }
  oscLeapUpdate();
  //--
  //oscTest();
}

//~~~~~~~~~~~~~~~~~~~~~~ abs pos tools from example
static float LEAP_WIDTH = 200.0; // in mm
static float LEAP_HEIGHT = 700.0; // in mm

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


