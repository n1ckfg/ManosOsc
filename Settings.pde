class Settings {

  String[] data;

  Settings(String _s) {
    try {
      data = loadStrings(_s);
      for (int i=0; i<data.length; i++) {
        if (data[i].equals("Check for Net Connection")) doNetConnection = setBoolean(settings.data[i+1]);
        if (data[i].equals("Center Coordinates")) centerMode = setBoolean(settings.data[i+1]);
        if (data[i].equals("Open App Folder at Startup")) openAppFolder = setBoolean(settings.data[i+1]);
        if (data[i].equals("Show Splash Screen")) showSplashScreen = setBoolean(settings.data[i+1]);
        if (data[i].equals("Stage Width")) sW = setInt(settings.data[i+1]);
        if (data[i].equals("Stage Height")) sH = setInt(settings.data[i+1]);
        if (data[i].equals("Stage Depth")) sD = setInt(settings.data[i+1]);
        if (data[i].equals("Framerate")) fps = setInt(settings.data[i+1]);
        //if (data[i].equals("Run in Fullscreen")) fullScreen = setBoolean(settings.data[i+1]);
        if (data[i].equals("Fixed Hand Positions")) fixedPositions = setBoolean(settings.data[i+1]);
        if (data[i].equals("Font Size")) fontSize = setInt(settings.data[i+1]);
        if (data[i].equals("Reverse Z Axis")) reverseZ = setBoolean(settings.data[i+1]);
        if (data[i].equals("Debug Display On")) debug = setBoolean(settings.data[i+1]);
        if (data[i].equals("Show Traces")) showTraces = setBoolean(settings.data[i+1]);
        if (data[i].equals("Time to Trace")) timeToTrace = setFloat(settings.data[i+1]);
        if (data[i].equals("Send MIDI Active")) sendMidi = setBoolean(settings.data[i+1]);
        if (data[i].equals("MIDI Send Channel")) midiChannelNum = setInt(settings.data[i+1]);
        if (data[i].equals("MIDI Send Port")) midiPortNum = setInt(settings.data[i+1]);
        if (data[i].equals("Send OSC Active")) sendOsc = setBoolean(settings.data[i+1]);
        if (data[i].equals("OSC Send IP Number")) ipNumber = setString(settings.data[i+1]);
        if (data[i].equals("OSC Send Port")) sendPort = setInt(settings.data[i+1]);
        if (data[i].equals("OSC Channel Format (Manos, OldManos, OSCeleton, Animata, Isadora)")) oscFormat = setString(settings.data[i+1]);
        if (data[i].equals("Save Maya Python")) writeMaya = setBoolean(settings.data[i+1]);
        if (data[i].equals("Maya Offset Translate")) mayaOffsetTranslate = setPVector(settings.data[i+1]);
        if (data[i].equals("Maya Offset Scale")) mayaOffsetScale = setPVector(settings.data[i+1]);
        if (data[i].equals("Save After Effects JavaScript")) writeAE = setBoolean(settings.data[i+1]);
        if (data[i].equals("After Effects Offset Translate")) AEoffsetTranslate = setPVector(settings.data[i+1]);
        if (data[i].equals("After Effects Offset Scale")) AEoffsetScale = setPVector(settings.data[i+1]);
       }
    } 
    catch(Exception e) {
      println("Couldn't load settings file. Using defaults.");
    }
  }

  int setInt(String _s) {
    return int(_s);
  }

  float setFloat(String _s) {
    return float(_s);
  }

  boolean setBoolean(String _s) {
    return boolean(_s);
  }
  
  String setString(String _s) {
    return ""+(_s);
  }
  
  String[] setStringArray(String _s) {
    int commaCounter=0;
    for(int j=0;j<_s.length();j++){
          if (_s.charAt(j)==char(',')){
            commaCounter++;
          }      
    }
    //println(commaCounter);
    String[] buildArray = new String[commaCounter+1];
    commaCounter=0;
    for(int k=0;k<buildArray.length;k++){
      buildArray[k] = "";
    }
    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')') && _s.charAt(i)!=char('{') && _s.charAt(i)!=char('}') && _s.charAt(i)!=char('[') && _s.charAt(i)!=char(']')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
            buildArray[commaCounter] += _s.charAt(i);
         }
       }
     }
     println(buildArray);
     return buildArray;
  }

  color setColor(String _s) {
    color endColor = color(0);
    int commaCounter=0;
    String sr = "";
    String sg = "";
    String sb = "";
    String sa = "";
    int r = 0;
    int g = 0;
    int b = 0;
    int a = 0;

    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
          if (commaCounter==0) sr += _s.charAt(i);
          if (commaCounter==1) sg += _s.charAt(i);
          if (commaCounter==2) sb += _s.charAt(i); 
          if (commaCounter==3) sa += _s.charAt(i);
         }
       }
     }

    if (sr!="" && sg=="" && sb=="" && sa=="") {
      r = int(sr);
      endColor = color(r);
    }
    if (sr!="" && sg!="" && sb=="" && sa=="") {
      r = int(sr);
      g = int(sg);
      endColor = color(r, g);
    }
    if (sr!="" && sg!="" && sb!="" && sa=="") {
      r = int(sr);
      g = int(sg);
      b = int(sb);
      endColor = color(r, g, b);
    }
    if (sr!="" && sg!="" && sb!="" && sa!="") {
      r = int(sr);
      g = int(sg);
      b = int(sb);
      a = int(sa);
      endColor = color(r, g, b, a);
    }
      return endColor;
  }
  
  PVector setPVector(String _s){
    PVector endPVector = new PVector(0,0,0);
    int commaCounter=0;
    String sx = "";
    String sy = "";
    String sz = "";
    float x = 0;
    float y = 0;
    float z = 0;

    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
          if (commaCounter==0) sx += _s.charAt(i);
          if (commaCounter==1) sy += _s.charAt(i);
          if (commaCounter==2) sz += _s.charAt(i); 
         }
       }
     }

    if (sx!="" && sy=="" && sz=="") {
      x = float(sx);
      endPVector = new PVector(x,0);
    }
    if (sx!="" && sy!="" && sz=="") {
      x = float(sx);
      y = float(sy);
      endPVector = new PVector(x,y);
    }
    if (sx!="" && sy!="" && sz!="") {
      x = float(sx);
      y = float(sy);
      z = float(sz);
      endPVector = new PVector(x,y,z);
    }
      return endPVector;
  }
  
}
