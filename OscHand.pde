class OscHand {

  OscFinger[] oscFinger = new OscFinger[5];
  PVector p, s;
  boolean show = false;
  int idHand = 0;
  int fingerCount = 0;

  PFont font;
  String fontFace = "Arial";
  int fontSize = 12;
  int fontOverSample = 1;

  color fillColor0 = color(127, 50, 50);
  color fillColor1 = color(50, 50, 127);
  float yOffset = 100;

  OscHand() {
    for (int i=0;i<oscFinger.length;i++) {
      oscFinger[i] = new OscFinger();
    }
    p = new PVector(0, 0, 0);
    s = new PVector(20, 20);
    font = createFont(fontFace, fontOverSample*fontSize);
    textFont(font, fontSize);
  }

  void update() {
    for (int i=0;i<oscFinger.length;i++) {
      oscFinger[i].idHand = idHand;      
      oscFinger[i].run();
    }
  }

  void draw() {
    if (show) {
      if (idHand==0) {
        fill(fillColor0);
        stroke(fillColor0);
      }
      else if (idHand==1) {
        fill(fillColor1);
        stroke(fillColor1);
      }
      strokeWeight(1);
      for (int i=0;i<oscFinger.length;i++) {
        if (oscFinger[i].show && fingerCount >1){
          line(oscFinger[i].p.x, oscFinger[i].p.y, oscFinger[i].p.z, p.x, p.y+yOffset, p.z);
        }
      }
      if (fingerCount>1) {
        pushMatrix();
        ellipseMode(CENTER);
        noStroke();
        translate(p.x, p.y+yOffset, p.z);
        ellipse(0, 0, s.x, s.y);
        fill(0);
        textAlign(CENTER);
        text(idHand, 0, 0);
        popMatrix();
      }
    }
  }

  void oscSend() {
    //--
    if (sendOsc) {
      sendHand();
      sendFinger();
    }
  }

  void sendFinger() {
    OscMessage myMessage;
    for (int i=0;i<fingerCount;i++) {
      try{
        //attempt to filter NaNs
        //if(oscFinger[i].show && oscFinger[i].p.x > -10000 && oscFinger[i].p.y > -10000 && oscFinger[i].p.z > -10000){
        if(oscFinger[i].show){
          myMessage = new OscMessage("/" + "hand" + idHand + "-" + oscFinger[i].idFinger);
          myMessage.add(oscFinger[i].idHand);
          myMessage.add(oscFinger[i].idFinger);
          myMessage.add(oscFinger[i].p.x);
          myMessage.add(oscFinger[i].p.y);
          myMessage.add(oscFinger[i].p.z);
          oscP5.send(myMessage, myRemoteLocation);
        }
      }catch(Exception e){ }
    }
  }

  void sendHand() {
    OscMessage myMessage;
    try{
      //attempt to filter NaNs
      //if(show && fingerCount>1 && p.x > -10000 && p.y > -10000 && p.z > -10000){
      if(show && fingerCount>1){
        myMessage = new OscMessage("/" + "hand" + idHand);
        myMessage.add(idHand);
        myMessage.add(p.x);
        myMessage.add(p.y+yOffset);
        myMessage.add(p.z);
        oscP5.send(myMessage, myRemoteLocation);
      }
    }catch(Exception e){ }
  }

  void run() {
    update();
    oscSend();
    if(debug) draw();
  }
}
