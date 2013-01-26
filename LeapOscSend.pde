//LeapOscSend by Nick Fox-Gieg | fox-gieg.com
//based on LeapCircles by Grace Christenbery
//NOTE: The Leap Processing library doesn't seem to like OPENGL.
//It'll crash on startup, or shortly after, about 2 out of 3 times.

import processing.opengl.*;

int leapW = 16*50;
int leapH = 9*50;
int sW = leapW;
int sH = leapH;
int fps = 60;
boolean debug = true;
boolean showTraces = true;
float timeToTrace = 0.5;
boolean sendOsc = true;
boolean absPositioning = false;

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
    text("Press TAB to toggle debug mode.",20,20);
  }
  oscLeapUpdate();
  //--
  //oscTest();
}


