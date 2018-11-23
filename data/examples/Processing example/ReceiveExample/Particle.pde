class Particle{

  PVector p,s,v,a;
  boolean alive = false;
  color fgColor = color(255);
  int counter;
  
  Particle(){
    p = new PVector(0,0,0);
    init();
  }

  void init(){
    v = new PVector(0,0,0);
    a = new PVector(0,0.03,0);
    s = new PVector(10,10);
    counter = 0;
  }
  
  void update(){
    v.add(a);
    p.add(v);
    
    s.sub(new PVector(0.1,0.1,0.1));
    if(s.x < 0){
      s = new PVector(0,0,0);
      alive=false;
    }
    
    if(p.y>height+s.y) alive = false;
    counter+=3;
    if(counter>255){
      counter=255;
      alive=false;
    }
  }
  
  void draw(){
    if(alive){
      pushMatrix();
      translate(p.x,p.y,p.z);
      noStroke();
      fill(fgColor);
      ellipseMode(CENTER);
      ellipse(0,0,s.x,s.y);
      popMatrix();
    }
  }
  
  void run(){
    update();
    draw();
  }
}
