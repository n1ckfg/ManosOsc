class PointablePoint{
  ArrayList pointablePath;
  PVector p = new PVector(0,0,0);
  PVector pp = new PVector(0,0,0); //previous position
  int idPointable = 0;
  int idHand = 0;
  color fgColor = color(255);
  String pointType = "pointable";
  boolean active = false;
  boolean clicked = false;

  PointablePoint(int _ip, int _ih, PVector _p, color _c, String _s){
    idPointable = _ip;
    idHand = _ih;
    pointablePath = new ArrayList();
    p = _p;
    fgColor = _c;
    pointType = _s;
  }
  
  void update(){
    //if(record) pointablePath.add(p);
    if(record||showTraces) pointablePath.add(p);
    if(sendOsc) sendPointableOsc();
    if(sendMidi) sendPointableMidi();
    if(pp == p){
      active = false;
    }else{
      active = true;
    }
  }
  
  void draw(){
    //if(debug){
      drawDot(p, fgColor, idHand + "-" + idPointable);
      drawTraces(pointablePath, color(fgColor,100));
    //}
  }
  
  void run(){
    update();
    draw();
  }
  
  void sendPointableOsc() {
    OscMessage myMessage;
    try{
      if(oscFormat.equals("Animata")){
        myMessage = new OscMessage("/joint");
        myMessage.add(pointType + idHand + "-" + idPointable);
        myMessage.add(((p.x/sW)*640)+0);
        myMessage.add(((p.y/sH)*480)+0);
        oscP5.send(myMessage, myRemoteLocation);
      }else if(oscFormat.equals("Isadora")){
        int a=0;
        int b=0;
        int c=0;
        if(idPointable==0){
          a = 4;
          b = 5;
          c = 6;
        }else if(idPointable==1){
          a = 7;
          b = 8;
          c = 9;
        }else if(idPointable==2){
          a = 10;
          b = 11;
          c = 12;
        }else if(idPointable==3){
          a = 13;
          b = 14;
          c = 15;
        }else if(idPointable==4){
          a = 16;
          b = 17;
          c = 18;
        }
        myMessage = new OscMessage("/isadora/"+getMidiId(a));
        myMessage.add(p.x/sW);
        oscP5.send(myMessage, myRemoteLocation);
        myMessage = new OscMessage("/isadora/"+getMidiId(b));
        myMessage.add(p.y/sH);
        oscP5.send(myMessage, myRemoteLocation);
        myMessage = new OscMessage("/isadora/"+getMidiId(c));
        myMessage.add(p.z/sD);
        oscP5.send(myMessage, myRemoteLocation); 
      }else if(oscFormat.equals("OSCeleton")){
        myMessage = new OscMessage("/joint");
        myMessage.add(pointType + idHand + "-" + idPointable);
        myMessage.add(idHand);
        myMessage.add(p.x/sW);
        myMessage.add(p.y/sH);
        myMessage.add(p.z/sD);
        oscP5.send(myMessage, myRemoteLocation);
      }else if(oscFormat.equals("OldManos")){
        //myMessage = new OscMessage("/" + "finger" + idHand + "-" + idPointable);
        myMessage = new OscMessage("/" + pointType + idHand + "-" + idPointable);
        myMessage.add(pointType);
        myMessage.add(idHand);
        myMessage.add(idPointable);
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
        //myMessage = new OscMessage("/" + "finger" + idHand + "-" + idPointable);
        myMessage = new OscMessage("/" + pointType + idHand + "-" + idPointable);
        myMessage.add(pointType);
        myMessage.add(idHand);
        myMessage.add(idPointable);
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
  
  void sendPointableMidi(){
    try{
      int a=0;
      int b=0;
      int c=0;
      if(idPointable==0){
        a = 4;
        b = 5;
        c = 6;
      }else if(idPointable==1){
        a = 7;
        b = 8;
        c = 9;
      }else if(idPointable==2){
        a = 10;
        b = 11;
        c = 12;
      }else if(idPointable==3){
        a = 13;
        b = 14;
        c = 15;
      }else if(idPointable==4){
        a = 16;
        b = 17;
        c = 18;
      }
      sendCtl(getMidiId(a),getMidiVal(p.x,sW));
      sendCtl(getMidiId(b),getMidiVal(p.y,sH));
      sendCtl(getMidiId(c),getMidiVal(p.z,sD));      
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
