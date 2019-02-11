String mayaFileName = "mayaScript";
//String mayaFilePath = scriptsFilePath;
String mayaFileType = "py";

ArrayList mayaTarget;
String mayaTargetName;
PVector mayaOffsetTranslate = new PVector(0,6,0);
PVector mayaOffsetScale = new PVector(1,1,1);

void mayaKeysMain() {
  mayaKeysBegin();
  for (int i=0;i<handPoints.length;i++) {
    mayaTarget = handPoints[i].handPath;
    mayaTargetName = "hand"+handPoints[i].idHand;
    mayaKeysMiddle();
    for(int j=0;j<handPoints[i].originPoints.length;j++){
      mayaTarget = handPoints[i].originPoints[j].pointablePath;
      mayaTargetName = "origin"+handPoints[i].idHand+"-"+handPoints[i].originPoints[j].idPointable;
      mayaKeysMiddle();      
    }
    for(int k=0;k<handPoints[i].fingerPoints.length;k++){
      mayaTarget = handPoints[i].fingerPoints[k].pointablePath;
      mayaTargetName = "finger"+handPoints[i].idHand+"-"+handPoints[i].fingerPoints[k].idPointable;
      mayaKeysMiddle();      
    }
    for(int l=0;l<handPoints[i].toolPoints.length;l++){
      mayaTarget = handPoints[i].toolPoints[l].pointablePath;
      mayaTargetName = "tool"+handPoints[i].idHand+"-"+handPoints[i].toolPoints[l].idPointable;
      mayaKeysMiddle();      
    }    
  }
    mayaKeysEnd();
}

void mayaKeysMiddle(){
  try{
    PVector temp1 = (PVector) mayaTarget.get(0);
    PVector temp2 = (PVector) mayaTarget.get(mayaTarget.size()-1);
    if(!pStartCheck(temp1) && !pStartCheck(temp2)){ //checks that this has moved from start point
      dataMaya.add("spaceLocator(name=\"" + mayaTargetName + "\")" + "\r");
      for (int j=0;j<counter;j++) {
        mayaKeyPos(j);
      }
    }
  }catch(Exception e){ }
}

void mayaKeyPos(int frameNum){
  
     // smoothing algorithm by Golan Levin

   PVector lower, upper, centerNum;

     centerNum = (PVector) mayaTarget.get(frameNum);

     if(applySmoothing && frameNum>smoothNum && frameNum<counter-smoothNum){
       lower = (PVector) mayaTarget.get(frameNum-smoothNum);
       upper = (PVector) mayaTarget.get(frameNum+smoothNum);
       centerNum.x = (lower.x + weight*centerNum.x + upper.x)*scaleNum;
       centerNum.y = (lower.y + weight*centerNum.y + upper.y)*scaleNum;
       centerNum.z = (lower.z + weight*centerNum.z + upper.z)*scaleNum;
     }
     
     if(frameNum%smoothNum==0||frameNum==0||frameNum==counter-1){
       dataMaya.add("currentTime("+frameNum+")"+"\r");
       dataMaya.add("move(" + (mayaOffsetTranslate.x + (mayaOffsetScale.x * (centerNum.x/100))) + ", " + (mayaOffsetTranslate.y + (mayaOffsetScale.y * (centerNum.y/-100))) + "," + (mayaOffsetTranslate.x + (mayaOffsetScale.z * (centerNum.z/100))) + ")" + "\r");
       dataMaya.add("setKeyframe()" + "\r");
     }
}

void mayaKeyRot(int spriteNum, int frameNum){
   /*

   float lower, upper, centerNum;

     centerNum = particle[spriteNum].AErot[frameNum];

     if(applySmoothing && frameNum>smoothNum && frameNum<counter-smoothNum){
       lower = particle[spriteNum].AErot[frameNum-smoothNum];
       upper = particle[spriteNum].AErot[frameNum+smoothNum];
       centerNum = (lower + weight*centerNum + upper)*scaleNum;
     }
     
     if(frameNum%smoothNum==0||frameNum==0||frameNum==counter-1){
      dataMaya.add("\t\t" + "r.setValueAtTime(" + AEkeyTime(frameNum) + ", " + centerNum +");" + "\r");
     }
     */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void mayaKeysBegin() {
  dataMaya = new Data();
  dataMaya.beginSave();
  dataMaya.add("from maya.cmds import *" + "\r");
  dataMaya.add("from random import uniform as rnd" + "\r");
  //dataMaya.add("#select(all=True)" + "\r");
  //dataMaya.add("#delete()" + "\r");
  dataMaya.add("playbackOptions(minTime=\"0\", maxTime=\"" + counter + "\")" + "\r");
  //dataMaya.add("#grav = gravity()" + "\r");  
  dataMaya.add("\r");  
}

void mayaKeysEnd() {
  /*
  dataMaya.add("#floor = polyPlane(w=30,h=30)" + "\r");
  dataMaya.add("#rigidBody(passive=True)" + "\r");
  dataMaya.add("#move(0,0,0)" + "\r");
  */
  dataMaya.endSave(scriptsFilePath + "/" + mayaFileName + "_" + millis() + "." + mayaFileType);
}
