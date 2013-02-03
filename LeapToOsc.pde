//LeapToOsc by Nick Fox-Gieg | fox-gieg.com
//with bits by Grace Christenbery and Alex Kaufmann

import processing.opengl.*;
import java.io.IOException;
import java.lang.Math;
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
  println("fps: " + frameRate);
}


