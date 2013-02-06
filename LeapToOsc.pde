//LeapToOsc by Nick Fox-Gieg and Victoria Nece | fox-gieg.com
//with bits by Grace Christenbery and Alex Kaufmann

import com.leapmotion.leap.*;
import com.onformative.leap.LeapMotionP5;
import oscP5.*;
import netP5.*;
import processing.opengl.*;
import java.io.IOException;
import java.lang.Math;
//--
String ipNumber = "127.0.0.1";
int sendPort = 7110;
int receivePort = 33333;
OscP5 oscP5;
NetAddress myRemoteLocation;
//--
SampleListener listener;
Controller controller;
LeapMotionP5 leap;
//--
int numberOfHands = 2;
OscHand[] hands = new OscHand[numberOfHands];
OscSingle single;

//--
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
boolean kumquatMode = false;

PFont font;
String fontFace = "Arial";
int fontSize = 12;
int fontOverSample = 2;

void initSettings(){
  Settings settings = new Settings("settings.txt");
  if(numberOfHands>0) hands = new OscHand[numberOfHands];
  oscLeapSetup();
  if(numberOfHands==-1) kumquatMode=true;
}

void setup() {
  initSettings();
  size(sW,sH,OPENGL);
  frameRate(fps);
  background(0);
  frameCount = 0;
  font = createFont(fontFace, fontOverSample*fontSize);
  textFont(font, fontSize);
  if(kumquatMode) kumquatSetup();
  }

void draw() {
    if(debug){
    if(kumquatMode){
      kumquatDraw();
    }else{
      background(0);
      noStroke();
      fill(255);
      textAlign(CORNER);
      if(numberOfHands>0){
        text("Press TAB to toggle debug display, SPACE to toggle positioning.",10,20);
        String sayText;
        if(absPositioning){
          sayText = "ON";
        }else{
          sayText = "OFF";
        }
        text("Absolute positioning is " + sayText + ".",10,20+(1.25*fontSize));
      }else if(numberOfHands==0){
        text("Press TAB to toggle debug display.",10,20);
      }
    }
    oscLeapUpdate();
    //println("fps: " + frameRate);
  }
}


