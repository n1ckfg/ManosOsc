class OscHand {

  OscFinger[] oscFinger = new OscFinger[5];
  OscTool[] oscTool = new OscTool[5];
  PVector p, s, t, e;
  boolean show = false;
  int idHand = 0;
  int idActive = 0;
  int fingerCount = 0;
  int toolCount = 0;
  PFont font;
  String fontFace = "Arial";
  int fontSize = 12;
  color fillColor0 = color(127, 50, 50);
  color fillColor1 = color(50, 50, 127);
  float yOffset = 100;

  OscHand() {
    for (int i=0;i<oscFinger.length;i++) {
      oscFinger[i] = new OscFinger();
    }
    for (int i=0;i<oscTool.length;i++) {
      oscTool[i] = new OscTool();
    }
    p = new PVector(0, 0, 0);
    t = new PVector(0, 0, 0);
    e = new PVector(ease,ease,ease);
    s = new PVector(20, 20);
    font = createFont(fontFace, 2*fontSize);
    textFont(font, fontSize);
    textAlign(CENTER);
  }

  void update() {
    for (int i=0;i<oscFinger.length;i++) {
      oscFinger[i].idHand = idHand;      
      oscFinger[i].run();
    }
    for (int i=0;i<oscTool.length;i++) {
      oscTool[i].idHand = idHand;      
      oscTool[i].run();
    }
    p = tween3D(p,t,e);
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
        text(idHand, 0, 0);
        popMatrix();
        //--
        pushMatrix();
        translate(t.x, t.y,t.z);
        noStroke();
        fill(255);
        ellipse(0, 0, 5, 5);
        popMatrix();
        stroke(255);
        line(p.x,p.y,p.z,t.x,t.y,t.z);        
      }
    }
  }

void run() {
  update();
  draw();
}

}
