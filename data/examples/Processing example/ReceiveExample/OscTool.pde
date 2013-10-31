class OscTool {

  PVector p, s, t, e;
  int numTraces = 150;
  Particle[] traces = new Particle[numTraces];
  int tracerCount=0;
  boolean show = false;
  int idTool = 0;
  int idHand = 0;
  PFont font;
  String fontFace = "Arial";
  int fontSize = 12;
  color fillColor2 = color(50, 250, 50);

  OscTool() {
    p = new PVector(0, 0, 0);
    t = new PVector(0, 0, 0);
    e = new PVector(ease,ease,ease);
    s = new PVector(20, 20);
    font = createFont(fontFace, 2*fontSize);
    textFont(font, fontSize);
    textAlign(CENTER);
    for (int i=0;i<traces.length;i++) {
      traces[i] = new Particle();
    }
  }

  void update() {
    if (show) {
      if(!traces[tracerCount].alive){
        traces[tracerCount].p = new PVector(p.x,p.y,p.z);
        traces[tracerCount].init();
        traces[tracerCount].alive = true;
      }
      if (tracerCount<traces.length-1) {
        tracerCount++;
      }
      else {
        tracerCount=0;
      }
    }
    p = tween3D(p,t,e);
  }

  void draw() {
    strokeWeight(2);
    for (int i=0;i<traces.length;i++) {
      if (i<traces.length-1 ){//&& traces[i].p != p) {
        traces[i].fgColor = color(fillColor2,255-traces[i].counter);
        if(traces[i].alive) traces[i].run();
      }
    }
    if (show) {
      ellipseMode(CENTER);
      fill(fillColor2);
      pushMatrix();
      translate(p.x, p.y,p.z);
      noStroke();
      ellipse(0, 0, s.x, s.y);
      fill(0);
      text(idHand + "." + idTool, 0, 3);
      popMatrix();
      //--
      pushMatrix();
      translate(t.x, t.y,t.z);
      noStroke();
      fill(255);
      ellipse(0, 0, 5, 5);
      popMatrix();  
      //--    
      stroke(255,100);
      line(p.x,p.y,p.z,t.x,t.y,t.z);   
    }
  }

  void run() {
    update();
    draw();
  }
  
}

