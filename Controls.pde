void keyPressed() {
  if (key=='z' || key=='Z') reverseZ = !reverseZ;
  if (key=='d' || key=='D') debug = !debug;
  if (key=='t' || key=='T') showTraces = !showTraces;
  if (key=='o' || key=='O') sendOsc = !sendOsc;
  if (key=='f' || key=='F') openAppFolderHandler();
  /*
  if(key==' ' || keyCode==33 || keyCode==34){
    record = !record;
    firstRun = false;
  }*/
}

void openAppFolderHandler(){
  if(System.getProperty("os.name").equals("Mac OS X")){
    try{
      print("Trying OS X Finder method.");
      //open(sketchPath(""));
      //String[] params = {  };
      open(sketchPath("data"));
      open(sketchPath("ManosOsc.app/Contents/Resources/Java/data"));
      open(sketchPath("ManosOsc_LM.app/Contents/Resources/Java/data"));
    }catch(Exception e){ }
  }else{
    try{
      print("Trying Windows Explorer method.");
      Desktop.getDesktop().open(new File(sketchPath("") + "/data"));
    }catch(Exception e){ }
  }
}

