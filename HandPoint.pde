class HandPoint {

  int numFingers = 5;
  int numOrigins = numFingers;
  int numTools = numFingers;
  int idActive = 0;
  int idHand = 0;
  color fgColor = color(0, 0, 255);
  String pointType = "hand";
  boolean active = false;
  boolean clicked = false;
  
  PointablePoint[] fingerPoints = new PointablePoint[numFingers];
  PointablePoint[] toolPoints = new PointablePoint[numTools];
  PointablePoint[] originPoints = new PointablePoint[numOrigins];
  ArrayList handPath;
  PVector pStart = new PVector(0,0,0);
  PVector p = new PVector(0,0,0);
  PVector pp = new PVector(0,0,0); //previous position

  HandPoint(int _ih, PVector _p) {
    idHand = _ih;
    pStart = _p;
    p = pStart;
    handPath = new ArrayList();
    for(int i=0;i<numOrigins;i++){
      originPoints[i] = new PointablePoint(i,idHand, p,  color(255, 50), "origin");
    }
    for (int i=0;i<numFingers;i++) {
      fingerPoints[i] = new PointablePoint(i,idHand, p, color(255, 0, 0), "finger");
    }
    for (int i=0;i<numTools;i++) {
      toolPoints[i] = new PointablePoint(i,idHand, p, color(0, 255, 0), "tool");
    }
  }

  void update() {
    //if(record) handPath.add(p);
    if(record||showTraces) handPath.add(p);
    if(sendOsc) sendHandOsc();
    if(sendMidi) sendHandMidi();
    if(pp == p){
      active = false;
    }else{
      active = true;
    }
  }

  void draw() {
    //if(debug){
      drawDot(p, fgColor, ""+idHand);
      drawTraces(handPath, color(fgColor,100));
    //}
  }

  void run() {
    update();
    draw();
  }
  
  void sendHandOsc() {
    OscMessage myMessage;
    try{
      if(oscFormat.equals("Animata")){
        myMessage = new OscMessage("/joint");
        myMessage.add("hand" + idHand);
        myMessage.add(((p.x/sW)*640)+0);
        myMessage.add(((p.y/sH)*480)+0);
        oscP5.send(myMessage, myRemoteLocation);
      }else if(oscFormat.equals("Isadora")){
        myMessage = new OscMessage("/isadora/"+getMidiId(1));
        myMessage.add(p.x/sW);
        oscP5.send(myMessage, myRemoteLocation);
        myMessage = new OscMessage("/isadora/"+getMidiId(2));
        myMessage.add(p.y/sH);
        oscP5.send(myMessage, myRemoteLocation);
        myMessage = new OscMessage("/isadora/"+getMidiId(3));
        myMessage.add(p.z/sD);
        oscP5.send(myMessage, myRemoteLocation);        
      }else if(oscFormat.equals("OSCeleton")){
        myMessage = new OscMessage("/joint");
        myMessage.add("hand" + idHand);
        myMessage.add(idHand);
        myMessage.add(p.x/sW);
        myMessage.add(p.y/sH);
        myMessage.add(p.z/sD);
        oscP5.send(myMessage, myRemoteLocation);
      }else if(oscFormat.equals("OldManos")){
        myMessage = new OscMessage("/" + "hand" + idHand);
        myMessage.add(pointType);
        myMessage.add(idHand);
        if(centerMode){
          myMessage.add((2.0*(p.x/sW))-1.0);
          myMessage.add((2.0*(p.y/sH))-1.0);
          myMessage.add((2.0*(p.z/sD))-1.0);
        }else{
          myMessage.add(p.x/sW);
          myMessage.add(p.y/sH);
          myMessage.add(p.z/sD);        
        }
        oscP5.send(myMessage, myRemoteLocation);
      }else{ //default
        myMessage = new OscMessage("/" + "hand" + idHand);
        myMessage.add(pointType);
        myMessage.add(idHand);
        myMessage.add(idActive);
        if(centerMode){
          myMessage.add((2.0*(p.x/sW))-1.0);
          myMessage.add((2.0*(p.y/sH))-1.0);
          myMessage.add((2.0*(p.z/sD))-1.0);
        }else{
          myMessage.add(p.x/sW);
          myMessage.add(p.y/sH);
          myMessage.add(p.z/sD);        
        }
        oscP5.send(myMessage, myRemoteLocation);
      }
    }catch(Exception e){ }
  }  

  void sendHandMidi(){
    try{
      sendCtl(getMidiId(1),getMidiVal(p.x,sW));
      sendCtl(getMidiId(2),getMidiVal(p.y,sH));
      sendCtl(getMidiId(3),getMidiVal(p.z,sD));      
    }catch(Exception e){ }
  }
  
  int getMidiId(int id){
    int returns = int((idHand*18)+id);
    return returns;
  }
  
  int getMidiVal(float _x, float _sw){
    int returns = int((_x/_sw)*127.0);
    if(returns<0) returns = 0;
    if(returns>127) returns = 127;
    return returns;
  }
}
