//ManosOsc by Nick Fox-Gieg  |  fox-gieg.com
//thanks to Liubo Borissov, Grace Christenbery, Alex Kaufmann, Victoria Nece, Marcel Schwittlick

import processing.opengl.*;
import com.onformative.leap.LeapMotionP5;
import com.leapmotion.leap.*;
import java.awt.Desktop;
import java.net.InetAddress;

LeapMotionP5 leap;

int sW = 700; // official width
int sH = 700; // official height
int sD = 1000; // random guess
int fps = 60;

boolean openAppFolder = false;
boolean showSplashScreen = false;
float splashScreenTime = 3.5; //sec
PImage splashScreen;
boolean reverseZ = true;
boolean debug = true;
boolean showTraces = true;
float timeToTrace = 0.5;
boolean sendOsc = true;
String[] sayText = new String[14];
PFont font;
String fontFace = "assets/DroidSans-Bold-48.vlw";
int fontSize = 16;
color fontColor = color(255);
boolean centerMode = false;
boolean leapConnection = false;
boolean netConnection = false;
boolean doNetConnection = false;
int netCheckTime = 2000;

String scriptsFilePath = "data";
boolean record = false;
boolean firstRun = true;
boolean applySmoothing = true;
int smoothNum = 6; //smoothing
float weight = 18;
float scaleNum  = 1.0 / (weight + 2);
Data dataAE, dataMaya;
boolean writeAE = true;
boolean writeMaya = true;
int counter = 0;

int numHands = 2;
HandPoint[] handPoints = new HandPoint[numHands];
PVector pStart = new PVector(0, 0, 0);

void setup() {
  Settings settings = new Settings("settings.txt");
  size(sW, sH, OPENGL);
  frameRate(fps);
  leap = new LeapMotionP5(this);
  if(System.getProperty("os.name").equals("Mac OS X")){
    try {
      font = loadFont(fontFace);
    }catch(Exception e) {
      font = createFont("Arial", 2*fontSize);
    }
  }else{
    try {
      font = loadFont(fontFace);
    }catch(Exception e) {
      font = createFont("Arial", 2*fontSize);
    }
  }
  textFont(font, fontSize);
  initHands(pStart);
  oscSetup();
  try {
    splashScreen = loadImage("assets/splashScreen.png");
  }
  catch(Exception e) { 
    showSplashScreen=false;
  }
  if (openAppFolder) {
    openAppFolderHandler();
  }
  if(doNetConnection) netConnection = checkNetConnection(1);
}

void draw() {
  try{
    if(millis()>netCheckTime){
      if(doNetConnection) netConnection = checkNetConnection(1);
      netCheckTime += millis();
    }
  }catch(Exception e){ }
  if (showSplashScreen & millis()<splashScreenTime*1000) {
    imageMode(CORNER);
    try {
      image(splashScreen, 0, 0);
    }
    catch(Exception e) {
    }
  }
  else {
    if (!record) {
      background(0);
    }
    else {
      background(75, 0, 0);
    }
    int handCounter = 0;
    //hands
    for (Hand hand : leap.getHandList()) {
      int fingerCounter = 0;
      int toolCounter = 0;
      int originCounter = 0;
      try {
        handPoints[handCounter].p = getPos(leap.getPosition(hand));
        handPoints[handCounter].run();
      }
      catch(Exception e) {
      }

      //origins on a hand
      for (Pointable pointable : leap.getPointableList(hand)) {
        try {
          handPoints[handCounter].originPoints[originCounter].p = getPos(leap.getOrigin(pointable));
          handPoints[handCounter].originPoints[originCounter].run();
          drawConnect(handPoints[handCounter].p, handPoints[handCounter].originPoints[originCounter].p);
          originCounter++;
        }
        catch(Exception e) {
        }
      }

      //fingers on a hand
      for (Finger finger : leap.getFingerList(hand)) {
        try {
          handPoints[handCounter].fingerPoints[fingerCounter].p = getPos(leap.getTip(finger));
          handPoints[handCounter].fingerPoints[fingerCounter].run();
          drawConnect(handPoints[handCounter].originPoints[fingerCounter].p, handPoints[handCounter].fingerPoints[fingerCounter].p);
          fingerCounter++;
        }
        catch(Exception e) {
        }
      }

      //tools on a hand
      for (Tool tool : leap.getToolList(hand)) {
        try {
          handPoints[handCounter].toolPoints[toolCounter].p = getPos(leap.getTip(tool));
          handPoints[handCounter].toolPoints[toolCounter].run();
          drawConnect(handPoints[handCounter].originPoints[toolCounter].p, handPoints[handCounter].toolPoints[toolCounter].p);
          toolCounter++;
        }
        catch(Exception e) {
        }
      }

      handCounter++;
    }
    //--
    int textX = 20;
    int textY = 30;
    sayText[0] = "(D)ebug: " + setOnOff(debug) +
      "   |   (Z) reverse: " + setOnOff(reverseZ) +
      "   |   (T)races: " + setOnOff(showTraces) + 
      "   |   (O)sc: " + setOnOff(sendOsc) + 
      "   |   (F)older "; //"(SPACE) to record" + 
    if(doNetConnection){
      sayText[1] = "fps: " + int(frameRate) + 
        "       ip: " + ipNumber +
        "       port: " + sendPort + 
        "       net: " + setYesNo(netConnection) +
        "       leap: " + setYesNo(leapConnection);
    }else{
      sayText[1] = "fps: " + int(frameRate) + 
        "       ip: " + ipNumber +
        "       port: " + sendPort + 
        "       leap: " + setYesNo(leapConnection);    
    }
    //~~
    sayText[2] = "channel /hand0     [   (s) " + handPoints[0].pointType + ",   (i) " + handPoints[0].idHand + convertVals(handPoints[0].p, "hand");
    sayText[3] = "channel /finger0-0     [   (s) " + handPoints[0].fingerPoints[0].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[0].idPointable + convertVals(handPoints[0].fingerPoints[0].p, "finger");
    sayText[4] = "channel /finger0-1     [   (s) " + handPoints[0].fingerPoints[1].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[1].idPointable + convertVals(handPoints[0].fingerPoints[1].p, "finger");
    sayText[5] = "channel /finger0-2     [   (s) " + handPoints[0].fingerPoints[2].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[2].idPointable + convertVals(handPoints[0].fingerPoints[2].p, "finger");
    sayText[6] = "channel /finger0-3     [   (s) " + handPoints[0].fingerPoints[3].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[3].idPointable + convertVals(handPoints[0].fingerPoints[3].p, "finger");
    sayText[7] = "channel /finger0-4     [   (s) " + handPoints[0].fingerPoints[4].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[4].idPointable + convertVals(handPoints[0].fingerPoints[4].p, "finger");
    sayText[8] = "channel /hand1     [   (s) " + handPoints[1].pointType + ",   (i) " + handPoints[1].idHand + convertVals(handPoints[1].p, "hand");
    sayText[9] = "channel /finger1-0     [   (s) " + handPoints[1].fingerPoints[0].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[0].idPointable + convertVals(handPoints[1].fingerPoints[0].p, "finger");
    sayText[10] = "channel /finger1-1     [   (s) " + handPoints[1].fingerPoints[1].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[1].idPointable + convertVals(handPoints[1].fingerPoints[1].p, "finger");
    sayText[11] = "channel /finger1-2     [   (s) " + handPoints[1].fingerPoints[2].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[2].idPointable + convertVals(handPoints[1].fingerPoints[2].p, "finger");
    sayText[12] = "channel /finger1-3     [   (s) " + handPoints[1].fingerPoints[3].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[3].idPointable + convertVals(handPoints[1].fingerPoints[3].p, "finger");
    sayText[13] = "channel /finger1-4     [   (s) " + handPoints[1].fingerPoints[4].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[4].idPointable + convertVals(handPoints[1].fingerPoints[4].p, "finger");
    //~~
    fill(fontColor);
    for (int i=0;i<sayText.length;i++) {
      try {
        if (i==0) text(sayText[i], textX, textY*(i+1));
        if (i>0 && debug) text(sayText[i], textX, textY*(i+1));
      }
      catch(Exception e) {
      }
    }

    if (record) {
      counter++;
      println("frames: " + counter + "   seconds: " + (counter/fps));
    }
    else if (!record && !firstRun) {
      writeAllKeys();
      exit();
    }
  }
  //oscTester();
}

String setOnOff(boolean _b) {
  String s;
  if (_b) {
    s = "ON";
  }
  else {
    s = "OFF";
  }
  return s;
}

String setYesNo(boolean _b) {
  String s;
  if (_b) {
    s = "YES";
  }
  else {
    s = "NO";
  }
  return s;
}

public void stop() {
  leap.stop();
}

void initHands(PVector _p) {
  for (int i=0;i<handPoints.length;i++) {
    handPoints[i] = new HandPoint(i, _p);
  }
}

void clearMemory() {
  counter=0;
  //--
  for (int i=0;i<numHands;i++) {
    handPoints[i].handPath = new ArrayList();
    for (int j=0;j<handPoints[i].originPoints.length;j++) {
      handPoints[i].originPoints[j].pointablePath = new ArrayList();
    }
    for (int k=0;k<handPoints[i].fingerPoints.length;k++) {
      handPoints[i].fingerPoints[k].pointablePath = new ArrayList();
    }
    for (int l=0;l<handPoints[i].toolPoints.length;l++) {
      handPoints[i].toolPoints[l].pointablePath = new ArrayList();
    }
  }
}

PVector getPos(PVector p) {
  if (reverseZ) p.z *= -1;
  return p;
}

void drawDot(PVector p, color c, String t) {
  pushMatrix();
  translate(p.x, p.y, p.z);
  noStroke();
  fill(c);
  ellipse(0, 0, 10, 10);
  fill(255);
  text(t, 0, 0);
  popMatrix();
}

void drawConnect(PVector _p1, PVector _p2) {
  stroke(255, 100);
  strokeWeight(2);
  noFill();
  if (!pStartCheck(_p2)) {
    //if(debug) line(_p1.x, _p1.y, _p1.z, _p2.x, _p2.y, _p2.z); 
    line(_p1.x, _p1.y, _p1.z, _p2.x, _p2.y, _p2.z);
  }
}

boolean pStartCheck(PVector _p) {
  if (hitDetect3D(_p, new PVector(1, 1, 1), pStart, new PVector(1, 1, 1))) {
    return true;
  }
  else {
    return false;
  }
}

void drawTraces(ArrayList target, color _c) {
  if (showTraces) {
    for (int i=0;i<target.size();i++) {
      if (i>target.size()-int(timeToTrace*fps)) {
        PVector p = (PVector) target.get(i);
        stroke(_c);
        strokeWeight(2);
        noFill();
        point(p.x, p.y, p.z);
      }
    }
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

void writeAllKeys() {
  if (writeAE) AEkeysMain();  // After Effects, JavaScript
  if (writeMaya) mayaKeysMain();  // Maya, Python
}

String convertVals(PVector p, String t) {
  String s = "";
  if (t=="hand") {
    if(centerMode){
      s = ",   (f) " + rounder((2.0*(p.x/sW))-1.0,3) + ",   (f) " + rounder((2.0*(p.y/sH))-1.0,3) + ",   (f) " + rounder((2.0*(p.z/sD))-1.0,3) + "   ]";
    }else{
      s = ",   (f) " + rounder(p.x/sW,3) + ",   (f) " + rounder(p.y/sH,3) + ",   (f) " + rounder(p.z/sD,3) + "   ]";
    }
  } else {
    if(centerMode){
      s = ",   (f) " + rounder((2.0*(p.x/sW))-1.0,3) + ",   (f) " + rounder((2.0*(p.y/sH))-1.0,3) + ",   (f) " + rounder((2.0*(p.z/sD))-1.0,3) + "   ]";
    }else{
      s = ",   (f) " + rounder(p.x/sW,3) + ",   (f) " + rounder(p.y/sH,3) + ",   (f) " + rounder(p.z/sD,3) + "   ]";
    }
  }
  return s;
}

float rounder(float _val, float _places){
  _val *= pow(10,_places);
  _val = round(_val);
  _val /= pow(10,_places);
  return _val;
}

boolean checkNetConnection(int _t){
  boolean answer = false;
  try{
    int timeout = _t; //duration over which to retry
    InetAddress[] addresses = InetAddress.getAllByName("google.com");
    for (InetAddress address : addresses) {
      if (address.isReachable(timeout)){
        answer = true;
        //println("Internet connection, and " + address + " is reachable.");
      }else{
        answer = true;
        //println("Internet connection, but " + address + " is not reachable.");
      }
    }
  }catch (Exception e) {
    answer = false;
    //println("No internet connection.");
  }
  return answer;
}
