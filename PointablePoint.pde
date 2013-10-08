class PointablePoint{
  ArrayList pointablePath;
  PVector p = new PVector(0,0,0);
  int idPointable = 0;
  int idHand = 0;
  color fgColor = color(255);
  String pointType = "pointable";

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
    if(sendOsc) sendPointable();
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
  
  void sendPointable() {
    OscMessage myMessage;
    try{
      myMessage = new OscMessage("/" + "finger" + idHand + "-" + idPointable);
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
    }catch(Exception e){ }
  }  

}
