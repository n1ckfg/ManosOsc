///////////////////////////
// DATA CLASS
// Marius Watz - http://workshop.evolutionzone.com

class Data {
  ArrayList datalist;
  String filename,data[];
  int datalineId;
 
  // begin data saving
  void beginSave() {
    datalist=new ArrayList();
  }
 
  void add(String s) {
    datalist.add(s);
  }
 
  void add(float val) {
    datalist.add(""+val);
  }
 
  void add(int val) {
    datalist.add(""+val);
  }
 
  void add(boolean val) {
    datalist.add(""+val);
  }
 
  void endSave(String _filename) {
    filename=_filename;
 
    data=new String[datalist.size()];
    data=(String [])datalist.toArray(data);
 
    saveStrings(filename, data);
    println("Saved data to '"+filename+
      "', "+data.length+" lines.");
  }
 
  void load(String _filename) {
    filename=_filename;
 
    datalineId=0;
    data=loadStrings(filename);
    println("Loaded data from '"+filename+
      "', "+data.length+" lines.");
  }
 
  float readFloat() {
    return float(data[datalineId++]);
  }
 
  int readInt() {
    return int(data[datalineId++]);
  }
 
  boolean readBoolean() {
    return boolean(data[datalineId++]);
  }
 
  String readString() {
    return data[datalineId++];
  }
 
  // Utility function to auto-increment filenames
  // based on filename templates like "name-###.txt" 
 
  public String getIncrementalFilename(String templ) {
    String s="",prefix,suffix,padstr,numstr;
    int index=0,first,last,count;
    File f;
    boolean ok;
 
    first=templ.indexOf('#');
    last=templ.lastIndexOf('#');
    count=last-first+1;
 
    if( (first!=-1)&& (last-first>0)) {
      prefix=templ.substring(0, first);
      suffix=templ.substring(last+1);
 
      // Comment out if you want to use absolute paths
      // or if you're not using this inside PApplet
      if(sketchPath!=null) prefix=savePath(prefix);
 
      index=0;
      ok=false;
 
      do {
        padstr="";
        numstr=""+index;
        for(int i=0; i< count-numstr.length(); i++) padstr+="0";
        s=prefix+padstr+numstr+suffix;
 
        f=new File(s);
        ok=!f.exists();
        index++;
 
        // Provide a panic button. If index > 10000 chances are it's an
        // invalid filename.
        if(index>10000) ok=true;
 
      }
      while(!ok);
 
      // Panic button - comment out if you know what you're doing
      if(index> 10000) {
        println("getIncrementalFilename thinks there is a problem - "+
          "Is there  more than 10000 files already in the sequence "+
          " or is the filename invalid?");
        println("Returning "+prefix+"ERR"+suffix);
        return prefix+"ERR"+suffix;
      }
    }
 
    return s;
  }
 
}
