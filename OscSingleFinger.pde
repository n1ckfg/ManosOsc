class OscSingleFinger {

  PVector p, s;
  int numTraces = int(timeToTrace*fps);
  PVector[] traces = new PVector[numTraces];
  int tracerCount=0;
  boolean show = false;
  
  PFont font;
  String fontFace = "Arial";
  int fontSize = 12;
  int fontOverSample = 1;

  color fillColor2 = color(250, 50, 250); //single = purple;

  OscSingleFinger() {
    p = new PVector(0, 0, 0);
    s = new PVector(20, 20);
    
    font = createFont(fontFace, fontOverSample*fontSize);
    textFont(font, fontSize);
    
    for (int i=0;i<traces.length;i++) {
      traces[i] = new PVector(0, 0, 0);
    }
  }

  void update() {
    if (show) {
      traces[tracerCount] = p;
      if (tracerCount<traces.length-1) {
        tracerCount++;
      }
      else {
        tracerCount=0;
      }
    }
  }

  void draw() {
    strokeWeight(2);
    for (int i=0;i<traces.length;i++) {
      if (i<traces.length-1 && traces[i] != p) {
        stroke(fillColor2, 100);
        if(showTraces) line(traces[i].x, traces[i].y, traces[i].z, traces[i+1].x, traces[i+1].y, traces[i+1].z);
      }
    }
    if (show) {
      ellipseMode(CENTER);
      fill(fillColor2);
      pushMatrix();
      translate(p.x, p.y, p.z);
      noStroke();
      ellipse(0, 0, s.x, s.y);
      fill(0);
      textAlign(CENTER);
      text("0", 0, 3);
      popMatrix();
    }
  }

  void run() {
    update();
    oscSend();
    if(debug) draw();
  } 

  void oscSend() {
    //--
    if (sendOsc) {
      sendSingle();
    }
  }

  void sendSingle() {
    OscMessage myMessage;
      try{
        //attempt to filter NaNs
        //if(oscFinger[i].show && oscFinger[i].p.x > -10000 && oscFinger[i].p.y > -10000 && oscFinger[i].p.z > -10000){
        if(show){
          myMessage = new OscMessage("/" + "singlefinger");
          myMessage.add(p.x/sW);
          myMessage.add(p.y/sH);
          myMessage.add(p.z/sD);
          oscP5.send(myMessage, myRemoteLocation);
        }
      }catch(Exception e){ }
  }  

}

