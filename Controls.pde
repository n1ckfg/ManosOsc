void keyPressed() {
  if (key=='z' || key=='Z') reverseZ = !reverseZ;
  if (key=='d' || key=='D') debug = !debug;
  if (key=='t' || key=='T') showTraces = !showTraces;
  if(key==' ' || keyCode==33 || keyCode==34){
    record = !record;
    firstRun = false;
 }
}

