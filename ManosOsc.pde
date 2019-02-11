//ManosOsc by Nick Fox-Gieg  |  fox-gieg.com
//thanks to Liubo Borissov, Grace Christenbery, Alex Kaufmann, Victoria Nece, Marcel Schwittlick

//import com.onformative.leap.LeapMotionP5;
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
boolean sendMidi = true;
String[] sayText = new String[20];
PFont font;
String fontFace = "assets/DroidSans-Bold-48.vlw";
int fontSize = 16;
color fontColor = color(255);
boolean centerMode = false;
boolean leapConnection = false;
boolean netConnection = false;
boolean doNetConnection = false;
int netCheckCounter = 0;
int netCheckInterval = 2000;
int netCheckTimeout = 1;
InetAddress[] addresses;
boolean fullScreen = false;
boolean debugDisplayMidi = false;
String oscFormat = "Legacy";

int activeHands = 0;
int activeFingers = 0;
int activeOrigins = 0;
int activeTools = 0;

String scriptsFilePath = "scripts";
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
boolean fixedPositions = false;
Settings settings;

void setup() {
  size(700, 700, P3D);
  settings = new Settings("settings.txt");
  surface.setSize(sW, sH);
  frameRate(fps);
  scriptsFolderHandler();
  leap = new LeapMotionP5(this);
  if (System.getProperty("os.name").equals("Mac OS X")) {
    try {
      font = loadFont(fontFace);
    }
    catch(Exception e) {
      font = createFont("Arial", 2*fontSize);
    }
  }
  else {
    try {
      font = loadFont(fontFace);
    }
    catch(Exception e) {
      font = createFont("Arial", 2*fontSize);
    }
  }
  textFont(font, fontSize);
  initHands(pStart);
  oscSetup();
  midiSetup();
  try {
    splashScreen = loadImage("assets/splashScreen.png");
  }
  catch(Exception e) { 
    showSplashScreen=false;
  }
  if (openAppFolder) {
    openAppFolderHandler();
  }
  if (doNetConnection) netConnection = checkNetConnection(netCheckTimeout);
}

void draw() {
  resetActiveCount(); //going to check how many hands, fingers, origins, tools have changed since previous frame
  try {
    if (netCheckCounter<netCheckInterval) {
      if (doNetConnection) netConnection = checkNetConnection(netCheckTimeout);
      netCheckCounter++;
    }
    else {
      netCheckCounter=0;
    }
  }
  catch(Exception e) {
  }
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

    if(fixedPositions){
      stroke(255,33);
      strokeWeight(4);
      line(width/2,0,width/2,height);
    } 
    
    int handCounter = 0;
    //hands
    for (Hand hand : leap.getHandList()) {
      int fingerCounter = 0;
      int toolCounter = 0;
      int originCounter = 0;
      try {
        handPoints[handCounter].pp = handPoints[handCounter].p;
        handPoints[handCounter].p = getPos(leap.getPosition(hand));
        handPoints[handCounter].run();
        if(fixedPositions){
          if(handPoints[handCounter].p.x<width/2){
            handPoints[handCounter].idHand = 0; //left
            for(int i=0;i<handPoints[handCounter].numOrigins;i++){
              handPoints[handCounter].originPoints[i].idHand = 0;
            }
            for (int i=0;i<handPoints[handCounter].numFingers;i++) {
              handPoints[handCounter].fingerPoints[i].idHand = 0;
            }
            for (int i=0;i<handPoints[handCounter].numTools;i++) {
              handPoints[handCounter].toolPoints[i].idHand = 0;
            }            
          }else{
            handPoints[handCounter].idHand = 1; //right
            for(int i=0;i<handPoints[handCounter].numOrigins;i++){
              handPoints[handCounter].originPoints[i].idHand = 1;
            }
            for (int i=0;i<handPoints[handCounter].numFingers;i++) {
              handPoints[handCounter].fingerPoints[i].idHand = 1;
            }
            for (int i=0;i<handPoints[handCounter].numTools;i++) {
              handPoints[handCounter].toolPoints[i].idHand = 1;
            }  
          }
        }
        if(handPoints[handCounter].active) activeHands++;
      }
      catch(Exception e) {
      }

      //origins on a hand
      for (Pointable pointable : leap.getPointableList(hand)) {
        try {
          handPoints[handCounter].originPoints[originCounter].pp = handPoints[handCounter].originPoints[originCounter].p;
          handPoints[handCounter].originPoints[originCounter].p = getPos(leap.getOrigin(pointable));
          handPoints[handCounter].originPoints[originCounter].run();
          drawConnect(handPoints[handCounter].p, handPoints[handCounter].originPoints[originCounter].p);
          if(handPoints[handCounter].originPoints[originCounter].active) activeOrigins++;
          originCounter++;
        }
        catch(Exception e) {
        }
      }
      try{
        handPoints[handCounter].idActive = originCounter; //this updates hand's internal count of active pointables
      }catch(Exception e){ }

      //fingers on a hand
      for (Finger finger : leap.getFingerList(hand)) {
        try {
          handPoints[handCounter].fingerPoints[fingerCounter].pp = handPoints[handCounter].fingerPoints[fingerCounter].p;
          handPoints[handCounter].fingerPoints[fingerCounter].p = getPos(leap.getTip(finger));
          handPoints[handCounter].fingerPoints[fingerCounter].run();
          drawConnect(handPoints[handCounter].originPoints[fingerCounter].p, handPoints[handCounter].fingerPoints[fingerCounter].p);
          if(handPoints[handCounter].fingerPoints[fingerCounter].active) activeFingers++;
          fingerCounter++;
        }
        catch(Exception e) {
        }
      }

      //tools on a hand
      for (Tool tool : leap.getToolList(hand)) {
        try {
          handPoints[handCounter].toolPoints[toolCounter].pp = handPoints[handCounter].toolPoints[toolCounter].p;
          handPoints[handCounter].toolPoints[toolCounter].p = getPos(leap.getTip(tool));
          handPoints[handCounter].toolPoints[toolCounter].run();
          drawConnect(handPoints[handCounter].originPoints[toolCounter].p, handPoints[handCounter].toolPoints[toolCounter].p);
          if(handPoints[handCounter].toolPoints[toolCounter].active) activeTools++;
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
      "   |   (O)sc: " + setOnOff(sendOsc) + 
      "   |   (M)idi: " + setOnOff(sendMidi) + 
      "   |   (F)older ";  

    sayText[1] = "(R)ecord: " + setOnOff(record) + 
      "       frames: " + counter + "       seconds: " + (counter/fps);


    if (doNetConnection) {
      sayText[2] = "fps: " + int(frameRate) + 
        "       net: " + setYesNo(netConnection) +
        "       leap: " + setYesNo(leapConnection);
    }else {
      sayText[2] = "fps: " + int(frameRate) + 
        "       leap: " + setYesNo(leapConnection);
    }

    if(!debugDisplayMidi){
      sayText[3] = "osc ip: " + ipNumber +
          "       osc port: " + sendPort +
          "       osc format: " + oscFormat;
    }else{
      sayText[3] = "midi channel: " + midiChannelNum + 
          "       midi port: " + midiPortNum;
    }

    sayText[4] = "";
    //~~
    if(!debugDisplayMidi){
      if(oscFormat.equals("Isadora")){
        sayText[5] = "osc for hand0     [   /isadora/" + handPoints[0].getMidiId(1) + "/ " + rounder(handPoints[0].p.x/sW,3) + ",   /isadora/" + handPoints[0].getMidiId(2) + "/ " + rounder(handPoints[0].p.y/sH,3) + ",   /isadora/" + handPoints[0].getMidiId(3) + "/ " + rounder(handPoints[0].p.z/sD,3) + "   ]";
        sayText[6] = "osc for finger0-0     [   /isadora/" + handPoints[0].fingerPoints[0].getMidiId(4) + "/ " + rounder(handPoints[0].fingerPoints[0].p.x/sW,3) + ",   /isadora/" + handPoints[0].fingerPoints[0].getMidiId(5) + "/ " + rounder(handPoints[0].fingerPoints[0].p.y/sH,3) + ",   /isadora/" + handPoints[0].fingerPoints[0].getMidiId(6) + "/ " + rounder(handPoints[0].fingerPoints[0].p.z/sD,3) + "   ]";
        sayText[7] = "osc for finger0-1     [   /isadora/" + handPoints[0].fingerPoints[1].getMidiId(7) + "/ " + rounder(handPoints[0].fingerPoints[1].p.x/sW,3) + ",   /isadora/" + handPoints[0].fingerPoints[1].getMidiId(8) + "/ " + rounder(handPoints[0].fingerPoints[1].p.y/sH,3) + ",   /isadora/" + handPoints[0].fingerPoints[1].getMidiId(9) + "/ " + rounder(handPoints[0].fingerPoints[1].p.z/sD,3) + "   ]";
        sayText[8] = "osc for finger0-2     [   /isadora/" + handPoints[0].fingerPoints[2].getMidiId(10) + "/ " + rounder(handPoints[0].fingerPoints[2].p.x/sW,3) + ",   /isadora/" + handPoints[0].fingerPoints[2].getMidiId(11) + "/ " + rounder(handPoints[0].fingerPoints[2].p.y/sH,3) + ",   /isadora/" + handPoints[0].fingerPoints[2].getMidiId(12) + "/ " + rounder(handPoints[0].fingerPoints[2].p.z/sD,3) + "   ]";
        sayText[9] = "osc for finger0-3     [   /isadora/" + handPoints[0].fingerPoints[3].getMidiId(13) + "/ " + rounder(handPoints[0].fingerPoints[3].p.x/sW,3) + ",   /isadora/" + handPoints[0].fingerPoints[3].getMidiId(14) + "/ " + rounder(handPoints[0].fingerPoints[3].p.y/sH,3) + ",   /isadora/" + handPoints[0].fingerPoints[3].getMidiId(15) + "/ " + rounder(handPoints[0].fingerPoints[3].p.z/sD,3) + "   ]";
        sayText[10] = "osc for finger0-4     [   /isadora/" + handPoints[0].fingerPoints[4].getMidiId(16) + "/ " + rounder(handPoints[0].fingerPoints[4].p.x/sW,3) + ",   /isadora/" + handPoints[0].fingerPoints[4].getMidiId(17) + "/ " + rounder(handPoints[0].fingerPoints[4].p.y/sH,3) + ",   /isadora/" + handPoints[0].fingerPoints[4].getMidiId(18) + "/ " + rounder(handPoints[0].fingerPoints[4].p.z/sD,3) + "   ]";
        sayText[11] = "";
        sayText[12] = "osc for hand1     [   /isadora/" + handPoints[1].getMidiId(1) + "/ " + rounder(handPoints[1].p.x/sW,3) + ",   /isadora/" + handPoints[1].getMidiId(2) + "/ " + rounder(handPoints[1].p.y/sH,3) + ",   /isadora/" + handPoints[1].getMidiId(3) + "/ " + rounder(handPoints[1].p.z/sD,3) + "   ]";
        sayText[13] = "osc for finger1-0     [   /isadora/" + handPoints[1].fingerPoints[0].getMidiId(4) + "/ " + rounder(handPoints[1].fingerPoints[0].p.x/sW,3) + ",   /isadora/" + handPoints[1].fingerPoints[0].getMidiId(5) + "/ " + rounder(handPoints[1].fingerPoints[0].p.y/sH,3) + ",   /isadora/" + handPoints[1].fingerPoints[0].getMidiId(6) + "/ " + rounder(handPoints[1].fingerPoints[0].p.z/sD,3) + "   ]";
        sayText[14] = "osc for finger1-1     [   /isadora/" + handPoints[1].fingerPoints[1].getMidiId(7) + "/ " + rounder(handPoints[1].fingerPoints[1].p.x/sW,3) + ",   /isadora/" + handPoints[1].fingerPoints[1].getMidiId(8) + "/ " + rounder(handPoints[1].fingerPoints[1].p.y/sH,3) + ",   /isadora/" + handPoints[1].fingerPoints[1].getMidiId(9) + "/ " + rounder(handPoints[1].fingerPoints[1].p.z/sD,3) + "   ]";
        sayText[15] = "osc for finger1-2     [   /isadora/" + handPoints[1].fingerPoints[2].getMidiId(10) + "/ " + rounder(handPoints[1].fingerPoints[2].p.x/sW,3) + ",   /isadora/" + handPoints[1].fingerPoints[2].getMidiId(11) + "/ " + rounder(handPoints[1].fingerPoints[2].p.y/sH,3) + ",   /isadora/" + handPoints[1].fingerPoints[2].getMidiId(12) + "/ " + rounder(handPoints[1].fingerPoints[2].p.z/sD,3) + "   ]";
        sayText[16] = "osc for finger1-3     [   /isadora/" + handPoints[1].fingerPoints[3].getMidiId(13) + "/ " + rounder(handPoints[1].fingerPoints[3].p.x/sW,3) + ",   /isadora/" + handPoints[1].fingerPoints[3].getMidiId(14) + "/ " + rounder(handPoints[1].fingerPoints[3].p.y/sH,3) + ",   /isadora/" + handPoints[1].fingerPoints[3].getMidiId(15) + "/ " + rounder(handPoints[1].fingerPoints[3].p.z/sD,3) + "   ]";
        sayText[17] = "osc for finger1-4     [   /isadora/" + handPoints[1].fingerPoints[4].getMidiId(16) + "/ " + rounder(handPoints[1].fingerPoints[4].p.x/sW,3) + ",   /isadora/" + handPoints[1].fingerPoints[4].getMidiId(17) + "/ " + rounder(handPoints[1].fingerPoints[4].p.y/sH,3) + ",   /isadora/" + handPoints[1].fingerPoints[4].getMidiId(18) + "/ " + rounder(handPoints[1].fingerPoints[4].p.z/sD,3) + "   ]";
        sayText[18] = "";
        sayText[19] = "";//osc channel /active     [   (i) " + activeHands+ ",   (i) " + activeFingers + ",   (i) " + activeTools + ",   (i) " + activeOrigins + "   ]";
      }else if(oscFormat.equals("OSCeleton")||oscFormat.equals("Animata")){ //differentiated using the convertVals function
        sayText[5] = "osc channel /joint     [   (s) hand0,   (i) " + handPoints[0].idHand + convertVals(handPoints[0].p, "hand");
        sayText[6] = "osc channel /joint     [   (s) finger0-0,   (i) " + handPoints[0].idHand + convertVals(handPoints[0].fingerPoints[0].p, "finger");
        sayText[7] = "osc channel /joint     [   (s) finger0-1,   (i) " + handPoints[0].idHand + convertVals(handPoints[0].fingerPoints[1].p, "finger");
        sayText[8] = "osc channel /joint     [   (s) finger0-2,   (i) " + handPoints[0].idHand + convertVals(handPoints[0].fingerPoints[2].p, "finger");
        sayText[9] = "osc channel /joint     [   (s) finger0-3,   (i) " + handPoints[0].idHand + convertVals(handPoints[0].fingerPoints[3].p, "finger");
        sayText[10] = "osc channel /joint     [   (s) finger0-4,   (i) " + handPoints[0].idHand + convertVals(handPoints[0].fingerPoints[4].p, "finger");
        sayText[11]="";
        sayText[12] = "osc channel /joint     [   (s) hand1,   (i) " + handPoints[1].idHand + convertVals(handPoints[1].p, "hand");
        sayText[13] = "osc channel /joint     [   (s) finger1-0,   (i) " + handPoints[1].idHand + convertVals(handPoints[1].fingerPoints[0].p, "finger");
        sayText[14] = "osc channel /joint     [   (s) finger1-1,   (i) " + handPoints[1].idHand + convertVals(handPoints[1].fingerPoints[1].p, "finger");
        sayText[15] = "osc channel /joint     [   (s) finger1-2,   (i) " + handPoints[1].idHand + convertVals(handPoints[1].fingerPoints[2].p, "finger");
        sayText[16] = "osc channel /joint     [   (s) finger1-3,   (i) " + handPoints[1].idHand + convertVals(handPoints[1].fingerPoints[3].p, "finger");
        sayText[17] = "osc channel /joint     [   (s) finger1-4,   (i) " + handPoints[1].idHand + convertVals(handPoints[1].fingerPoints[4].p, "finger");
        sayText[18] = "";
        sayText[19] = "osc channel /active     [   (i) " + activeHands+ ",   (i) " + activeFingers + ",   (i) " + activeTools + ",   (i) " + activeOrigins + "   ]";
      }else if(oscFormat.equals("OldManos")){
        sayText[5] = "osc channel /hand0     [   (s) " + handPoints[0].pointType + ",   (i) " + handPoints[0].idHand + convertVals(handPoints[0].p, "hand");
        sayText[6] = "osc channel /finger0-0     [   (s) " + handPoints[0].fingerPoints[0].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[0].idPointable + convertVals(handPoints[0].fingerPoints[0].p, "finger");
        sayText[7] = "osc channel /finger0-1     [   (s) " + handPoints[0].fingerPoints[1].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[1].idPointable + convertVals(handPoints[0].fingerPoints[1].p, "finger");
        sayText[8] = "osc channel /finger0-2     [   (s) " + handPoints[0].fingerPoints[2].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[2].idPointable + convertVals(handPoints[0].fingerPoints[2].p, "finger");
        sayText[9] = "osc channel /finger0-3     [   (s) " + handPoints[0].fingerPoints[3].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[3].idPointable + convertVals(handPoints[0].fingerPoints[3].p, "finger");
        sayText[10] = "osc channel /finger0-4     [   (s) " + handPoints[0].fingerPoints[4].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[4].idPointable + convertVals(handPoints[0].fingerPoints[4].p, "finger");
        sayText[11]="";
        sayText[12] = "osc channel /hand1     [   (s) " + handPoints[1].pointType + ",   (i) " + handPoints[1].idHand + convertVals(handPoints[1].p, "hand");
        sayText[13] = "osc channel /finger1-0     [   (s) " + handPoints[1].fingerPoints[0].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[0].idPointable + convertVals(handPoints[1].fingerPoints[0].p, "finger");
        sayText[14] = "osc channel /finger1-1     [   (s) " + handPoints[1].fingerPoints[1].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[1].idPointable + convertVals(handPoints[1].fingerPoints[1].p, "finger");
        sayText[15] = "osc channel /finger1-2     [   (s) " + handPoints[1].fingerPoints[2].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[2].idPointable + convertVals(handPoints[1].fingerPoints[2].p, "finger");
        sayText[16] = "osc channel /finger1-3     [   (s) " + handPoints[1].fingerPoints[3].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[3].idPointable + convertVals(handPoints[1].fingerPoints[3].p, "finger");
        sayText[17] = "osc channel /finger1-4     [   (s) " + handPoints[1].fingerPoints[4].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[4].idPointable + convertVals(handPoints[1].fingerPoints[4].p, "finger");
        sayText[18] = "";
        sayText[19] = "osc channel /active     [   (i) " + activeHands+ ",   (i) " + activeFingers + ",   (i) " + activeTools + ",   (i) " + activeOrigins + "   ]";
      }else{ //default
        sayText[5] = "osc channel /hand0     [   (s) " + handPoints[0].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].idActive + convertVals(handPoints[0].p, "hand");
        sayText[6] = "osc channel /finger0-0     [   (s) " + handPoints[0].fingerPoints[0].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[0].idPointable + convertVals(handPoints[0].fingerPoints[0].p, "finger");
        sayText[7] = "osc channel /finger0-1     [   (s) " + handPoints[0].fingerPoints[1].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[1].idPointable + convertVals(handPoints[0].fingerPoints[1].p, "finger");
        sayText[8] = "osc channel /finger0-2     [   (s) " + handPoints[0].fingerPoints[2].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[2].idPointable + convertVals(handPoints[0].fingerPoints[2].p, "finger");
        sayText[9] = "osc channel /finger0-3     [   (s) " + handPoints[0].fingerPoints[3].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[3].idPointable + convertVals(handPoints[0].fingerPoints[3].p, "finger");
        sayText[10] = "osc channel /finger0-4     [   (s) " + handPoints[0].fingerPoints[4].pointType + ",   (i) " + handPoints[0].idHand + ",   (i) " + handPoints[0].fingerPoints[4].idPointable + convertVals(handPoints[0].fingerPoints[4].p, "finger");
        sayText[11]="";
        sayText[12] = "osc channel /hand1     [   (s) " + handPoints[1].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].idActive + convertVals(handPoints[1].p, "hand");
        sayText[13] = "osc channel /finger1-0     [   (s) " + handPoints[1].fingerPoints[0].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[0].idPointable + convertVals(handPoints[1].fingerPoints[0].p, "finger");
        sayText[14] = "osc channel /finger1-1     [   (s) " + handPoints[1].fingerPoints[1].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[1].idPointable + convertVals(handPoints[1].fingerPoints[1].p, "finger");
        sayText[15] = "osc channel /finger1-2     [   (s) " + handPoints[1].fingerPoints[2].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[2].idPointable + convertVals(handPoints[1].fingerPoints[2].p, "finger");
        sayText[16] = "osc channel /finger1-3     [   (s) " + handPoints[1].fingerPoints[3].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[3].idPointable + convertVals(handPoints[1].fingerPoints[3].p, "finger");
        sayText[17] = "osc channel /finger1-4     [   (s) " + handPoints[1].fingerPoints[4].pointType + ",   (i) " + handPoints[1].idHand + ",   (i) " + handPoints[1].fingerPoints[4].idPointable + convertVals(handPoints[1].fingerPoints[4].p, "finger");
        sayText[18] = "";
        sayText[19] = "osc channel /active     [   (i) " + activeHands+ ",   (i) " + activeFingers + ",   (i) " + activeTools + ",   (i) " + activeOrigins + "   ]";
      }
    }else{
      sayText[5] = "midi ctl for hand0     [   (" + handPoints[0].getMidiId(1) + ") " + handPoints[0].getMidiVal(handPoints[0].p.x,sW) + ",   (" + handPoints[0].getMidiId(2) + ") " + handPoints[0].getMidiVal(handPoints[0].p.y,sH) + ",   (" + handPoints[0].getMidiId(3) + ") " + handPoints[0].getMidiVal(handPoints[0].p.z,sD) + "   ]";
      sayText[6] = "midi ctl for finger0-0     [   (" + handPoints[0].fingerPoints[0].getMidiId(4) + ") " + handPoints[0].fingerPoints[0].getMidiVal(handPoints[0].fingerPoints[0].p.x,sW) + ",   (" + handPoints[0].fingerPoints[0].getMidiId(5) + ") " + handPoints[0].fingerPoints[0].getMidiVal(handPoints[0].fingerPoints[0].p.y,sH) + ",   (" + handPoints[0].fingerPoints[0].getMidiId(6) + ") " + handPoints[0].fingerPoints[0].getMidiVal(handPoints[0].fingerPoints[0].p.z,sD) + "   ]";
      sayText[7] = "midi ctl for finger0-1     [   (" + handPoints[0].fingerPoints[1].getMidiId(7) + ") " + handPoints[0].fingerPoints[1].getMidiVal(handPoints[0].fingerPoints[1].p.x,sW) + ",   (" + handPoints[0].fingerPoints[1].getMidiId(8) + ") " + handPoints[0].fingerPoints[1].getMidiVal(handPoints[0].fingerPoints[1].p.y,sH) + ",   (" + handPoints[0].fingerPoints[1].getMidiId(9) + ") " + handPoints[0].fingerPoints[1].getMidiVal(handPoints[0].fingerPoints[1].p.z,sD) + "   ]";
      sayText[8] = "midi ctl for finger0-2     [   (" + handPoints[0].fingerPoints[2].getMidiId(10) + ") " + handPoints[0].fingerPoints[2].getMidiVal(handPoints[0].fingerPoints[2].p.x,sW) + ",   (" + handPoints[0].fingerPoints[2].getMidiId(11) + ") " + handPoints[0].fingerPoints[2].getMidiVal(handPoints[0].fingerPoints[2].p.y,sH) + ",   (" + handPoints[0].fingerPoints[2].getMidiId(12) + ") " + handPoints[0].fingerPoints[2].getMidiVal(handPoints[0].fingerPoints[2].p.z,sD) + "   ]";
      sayText[9] = "midi ctl for finger0-3     [   (" + handPoints[0].fingerPoints[3].getMidiId(13) + ") " + handPoints[0].fingerPoints[3].getMidiVal(handPoints[0].fingerPoints[3].p.x,sW) + ",   (" + handPoints[0].fingerPoints[3].getMidiId(14) + ") " + handPoints[0].fingerPoints[3].getMidiVal(handPoints[0].fingerPoints[3].p.y,sH) + ",   (" + handPoints[0].fingerPoints[3].getMidiId(15) + ") " + handPoints[0].fingerPoints[3].getMidiVal(handPoints[0].fingerPoints[3].p.z,sD) + "   ]";
      sayText[10] = "midi ctl for finger0-4     [   (" + handPoints[0].fingerPoints[4].getMidiId(16) + ") " + handPoints[0].fingerPoints[4].getMidiVal(handPoints[0].fingerPoints[4].p.x,sW) + ",   (" + handPoints[0].fingerPoints[4].getMidiId(17) + ") " + handPoints[0].fingerPoints[4].getMidiVal(handPoints[0].fingerPoints[4].p.y,sH) + ",   (" + handPoints[0].fingerPoints[4].getMidiId(18) + ") " + handPoints[0].fingerPoints[4].getMidiVal(handPoints[0].fingerPoints[4].p.z,sD) + "   ]";
      sayText[11] = "";
      sayText[12] = "midi ctl for hand1     [   (" + handPoints[1].getMidiId(1) + ") " + handPoints[1].getMidiVal(handPoints[1].p.x,sW) + ",   (" + handPoints[1].getMidiId(2) + ") " + handPoints[1].getMidiVal(handPoints[1].p.y,sH) + ",   (" + handPoints[1].getMidiId(3) + ") " + handPoints[1].getMidiVal(handPoints[1].p.z,sD) + "   ]";
      sayText[13] = "midi ctl for finger1-0     [   (" + handPoints[1].fingerPoints[0].getMidiId(4) + ") " + handPoints[1].fingerPoints[0].getMidiVal(handPoints[1].fingerPoints[0].p.x,sW) + ",   (" + handPoints[1].fingerPoints[0].getMidiId(5) + ") " + handPoints[1].fingerPoints[0].getMidiVal(handPoints[1].fingerPoints[0].p.y,sH) + ",   (" + handPoints[1].fingerPoints[0].getMidiId(6) + ") " + handPoints[1].fingerPoints[0].getMidiVal(handPoints[1].fingerPoints[0].p.z,sD) + "   ]";
      sayText[14] = "midi ctl for finger1-1     [   (" + handPoints[1].fingerPoints[1].getMidiId(7) + ") " + handPoints[1].fingerPoints[1].getMidiVal(handPoints[1].fingerPoints[1].p.x,sW) + ",   (" + handPoints[1].fingerPoints[1].getMidiId(8) + ") " + handPoints[1].fingerPoints[1].getMidiVal(handPoints[1].fingerPoints[1].p.y,sH) + ",   (" + handPoints[1].fingerPoints[1].getMidiId(9) + ") " + handPoints[1].fingerPoints[1].getMidiVal(handPoints[1].fingerPoints[1].p.z,sD) + "   ]";
      sayText[15] = "midi ctl for finger1-2     [   (" + handPoints[1].fingerPoints[2].getMidiId(10) + ") " + handPoints[1].fingerPoints[2].getMidiVal(handPoints[1].fingerPoints[2].p.x,sW) + ",   (" + handPoints[1].fingerPoints[2].getMidiId(11) + ") " + handPoints[1].fingerPoints[2].getMidiVal(handPoints[1].fingerPoints[2].p.y,sH) + ",   (" + handPoints[1].fingerPoints[2].getMidiId(12) + ") " + handPoints[1].fingerPoints[2].getMidiVal(handPoints[1].fingerPoints[2].p.z,sD) + "   ]";
      sayText[16] = "midi ctl for finger1-3     [   (" + handPoints[1].fingerPoints[3].getMidiId(13) + ") " + handPoints[1].fingerPoints[3].getMidiVal(handPoints[1].fingerPoints[3].p.x,sW) + ",   (" + handPoints[1].fingerPoints[3].getMidiId(14) + ") " + handPoints[1].fingerPoints[3].getMidiVal(handPoints[1].fingerPoints[3].p.y,sH) + ",   (" + handPoints[1].fingerPoints[3].getMidiId(15) + ") " + handPoints[1].fingerPoints[3].getMidiVal(handPoints[1].fingerPoints[3].p.z,sD) + "   ]";
      sayText[17] = "midi ctl for finger1-4     [   (" + handPoints[1].fingerPoints[4].getMidiId(16) + ") " + handPoints[1].fingerPoints[4].getMidiVal(handPoints[1].fingerPoints[4].p.x,sW) + ",   (" + handPoints[1].fingerPoints[4].getMidiId(17) + ") " + handPoints[1].fingerPoints[4].getMidiVal(handPoints[1].fingerPoints[4].p.y,sH) + ",   (" + handPoints[1].fingerPoints[4].getMidiId(18) + ") " + handPoints[1].fingerPoints[4].getMidiVal(handPoints[1].fingerPoints[4].p.z,sD) + "   ]";
      sayText[18] = "";
      sayText[19] = "";
    }
      //~~
    fill(fontColor);
    for (int i=0;i<sayText.length;i++) {
      try {
        if (i<2){
          text(sayText[i], textX, textY*(i+1));
        }else{
          if (debug) text(sayText[i], textX, textY*(i+1));
        }
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
      //exit();
    }
  }

  //oscTester();
  //midiTester();
  if(sendOsc) sendActiveOsc(); //sends count of active hands, fingers, tools, origins
}

//not reading correctly from settings
//boolean sketchFullScreen() {
  //return fullScreen;
//}
  
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
        strokeWeight(4);
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
  record=false;
  firstRun=true;
  counter=0;
}

String convertVals(PVector p, String t) {
  String s = "";
  if(oscFormat.equals("Animata")){
    s = ",   (f) " + rounder(640 * (p.x/sW), 3) + ",   (f) " + rounder(480 * (p.y/sH), 3) + "   ]";
  }else{
    if (t=="hand") { //doesn't appear to do anything; was I planning to have something different for hands?
      if (centerMode) {
        s = ",   (f) " + rounder((2.0*(p.x/sW))-1.0, 3) + ",   (f) " + rounder((2.0*(p.y/sH))-1.0, 3) + ",   (f) " + rounder((2.0*(p.z/sD))-1.0, 3) + "   ]";
      }
      else {
        s = ",   (f) " + rounder(p.x/sW, 3) + ",   (f) " + rounder(p.y/sH, 3) + ",   (f) " + rounder(p.z/sD, 3) + "   ]";
      }
    } 
    else {
      if (centerMode) {
        s = ",   (f) " + rounder((2.0*(p.x/sW))-1.0, 3) + ",   (f) " + rounder((2.0*(p.y/sH))-1.0, 3) + ",   (f) " + rounder((2.0*(p.z/sD))-1.0, 3) + "   ]";
      }
      else {
        s = ",   (f) " + rounder(p.x/sW, 3) + ",   (f) " + rounder(p.y/sH, 3) + ",   (f) " + rounder(p.z/sD, 3) + "   ]";
      }
    }
  }
  return s;
}

float rounder(float _val, float _places) {
  _val *= pow(10, _places);
  _val = round(_val);
  _val /= pow(10, _places);
  return _val;
}

boolean checkNetConnection(int _t) {
  boolean answer = false;
  try {
    addresses = InetAddress.getAllByName("leapmotion.com");
    for (InetAddress address : addresses) {
      //if (address.isReachable(_t)) { //timeout
        //answer = true;
        //println("Internet connection, and " + address + " is reachable.");
      //}
     //else {
        answer = true;
        //println("Internet connection, but " + address + " is not reachable.");
      //}
    }
  }
  catch (Exception e) {
    answer = false;
    //println("No internet connection.");
  }
  return answer;
}

void resetActiveCount(){
  activeHands = 0;
  activeFingers = 0;
  activeOrigins = 0;
  activeTools = 0;
}
