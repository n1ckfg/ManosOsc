void keyPressed(){
  if(keyCode==9){
    debug = !debug;
    if(!debug) background(0);
  }
  if(key=='t'||key=='T'){
    showTraces = !showTraces;
  }
  if(key=='z'||key=='Z'){
    reverseZ = !reverseZ;
  }
  if(key==' '){
    absPositioning = !absPositioning;
  }  
}
