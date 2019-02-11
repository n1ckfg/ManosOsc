String aeFileName = "AEscript";
//String aeFilePath = scriptsFilePath;
String aeFileType = "jsx";

ArrayList AEtarget;
String AEtargetName;
PVector AEoffsetTranslate = new PVector(0,0,0);
PVector AEoffsetScale = new PVector(1,1,1);
boolean motionBlur = true;
boolean applyEffects = false;
int dW = 1920;
int dH = 1080;
int dD = 2000;

void AEkeysMain() {
  AEkeysBegin();
  
  for (int i=0;i<handPoints.length;i++) {
    AEtarget = handPoints[i].handPath;
    AEtargetName = "hand"+handPoints[i].idHand;
    AEkeysMiddle();
    for(int j=0;j<handPoints[i].originPoints.length;j++){
      AEtarget = handPoints[i].originPoints[j].pointablePath;
      AEtargetName = "origin"+handPoints[i].idHand+"-"+handPoints[i].originPoints[j].idPointable;
      AEkeysMiddle();      
    }
    for(int k=0;k<handPoints[i].fingerPoints.length;k++){
      AEtarget = handPoints[i].fingerPoints[k].pointablePath;
      AEtargetName = "finger"+handPoints[i].idHand+"-"+handPoints[i].fingerPoints[k].idPointable;
      AEkeysMiddle();      
    }
    for(int l=0;l<handPoints[i].toolPoints.length;l++){
      AEtarget = handPoints[i].toolPoints[l].pointablePath;
      AEtargetName = "tool"+handPoints[i].idHand+"-"+handPoints[i].toolPoints[l].idPointable;
      AEkeysMiddle();      
    }    
  }

  AEkeysEnd();   
}

void AEkeysMiddle(){
  try{
    PVector temp1 = (PVector) AEtarget.get(0);
    PVector temp2 = (PVector) AEtarget.get(AEtarget.size()-1);
    if(!pStartCheck(temp1) && !pStartCheck(temp2)){ //checks that this has moved from start point
      dataAE.add("\t" + "var solid = myComp.layers.addSolid([1.0, 1.0, 0], \"" + AEtargetName + "\", 50, 50, 1);" + "\r");
      dataAE.add("\t" + "solid.threeDLayer = true;" + "\r");
      if(motionBlur){
        dataAE.add("\t" + "solid.motionBlur = true;" + "\r");
      }
      if(applyEffects){
        AEeffects();
      }
      dataAE.add("\r");
      dataAE.add("\t" + "var p = solid.property(\"position\");" + "\r");
      dataAE.add("\t" + "var r = solid.property(\"rotation\");" + "\r");
      dataAE.add("\r");
    
      for (int j=0;j<counter;j++) {
        AEkeyPos(j);
        //AEkeyRot(i,j);
      }
    }
  }catch(Exception e){ }
}

float AEkeyTime(int frameNum){
  return (float(frameNum)/float(counter)) * (float(counter)/float(fps));
}

void AEkeyPos(int frameNum){
     // smoothing algorithm by Golan Levin

   PVector lower, upper, centerNum;

     centerNum = (PVector) AEtarget.get(frameNum);

     if(applySmoothing && frameNum>smoothNum && frameNum<counter-smoothNum){
       lower = (PVector) AEtarget.get(frameNum-smoothNum);
       upper = (PVector) AEtarget.get(frameNum+smoothNum);
       centerNum.x = (lower.x + weight*centerNum.x + upper.x)*scaleNum;
       centerNum.y = (lower.y + weight*centerNum.y + upper.y)*scaleNum;
       centerNum.z = (lower.z + weight*centerNum.z + upper.z)*scaleNum;
     }
     
     if(frameNum%smoothNum==0||frameNum==0||frameNum==counter-1){
       dataAE.add("\t\t" + "p.setValueAtTime(" + AEkeyTime(frameNum) + ", [ " + (AEoffsetTranslate.x + (AEoffsetScale.x * centerNum.x)) + ", " + (AEoffsetTranslate.y + (AEoffsetScale.y * centerNum.y)) + ", " + (AEoffsetTranslate.z + (AEoffsetScale.z * centerNum.z)) + "]);" + "\r");
     }
}

void AEkeyRot(int spriteNum, int frameNum){
/*
   float lower, upper, centerNum;

     //note the capitalized Float; this is a quirk of ArrayLists. http://processing.org/discourse/beta/num_1227938522.html
     centerNum = (Float) particle[spriteNum].AErot.get(frameNum);

     if(applySmoothing && frameNum>smoothNum && frameNum<counter-smoothNum){
       lower = (Float) particle[spriteNum].AErot.get(frameNum-smoothNum);
       upper = (Float) particle[spriteNum].AErot.get(frameNum+smoothNum);
       centerNum = (lower + weight*centerNum + upper)*scaleNum;
     }
     
     if(frameNum%smoothNum==0||frameNum==0||frameNum==counter-1){
      dataAE.add("\t\t" + "r.setValueAtTime(" + AEkeyTime(frameNum) + ", " + centerNum +");" + "\r");
     }
 */
}

void AEeffects(){
     dataAE.add("\t" + "var myEffect = solid.property(\"Effects\").addProperty(\"Fast Blur\")(\"Blurriness\").setValue(61);");
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void AEkeysBegin() {
  dataAE = new Data();
  dataAE.beginSave();
  dataAE.add("{  //start script" + "\r");
  dataAE.add("\t" + "app.beginUndoGroup(\"foo\");" + "\r");
  dataAE.add("\r");
  dataAE.add("\t" + "// create project if necessary" + "\r");
  dataAE.add("\t" + "var proj = app.project;" + "\r");
  dataAE.add("\t" + "if(!proj) proj = app.newProject();" + "\r");
  dataAE.add("\r");
  dataAE.add("\t" + "// create new comp named 'my comp'" + "\r");
  dataAE.add("\t" + "var compW = " + dW + "; // comp width" + "\r");
  dataAE.add("\t" + "var compH = " + dH + "; // comp height" + "\r");
  dataAE.add("\t" + "var compL = " + (counter/fps) + ";  // comp length (seconds)" + "\r");
  dataAE.add("\t" + "var compRate = " + fps + "; // comp frame rate" + "\r");
  dataAE.add("\t" + "var compBG = [0/255,0/255,0/255] // comp background color" + "\r");
  dataAE.add("\t" + "var myItemCollection = app.project.items;" + "\r");
  dataAE.add("\t" + "var myComp = myItemCollection.addComp('my comp',compW,compH,1,compL,compRate);" + "\r");
  dataAE.add("\t" + "myComp.bgColor = compBG;" + "\r");
  dataAE.add("\r");  
}

void AEkeysEnd() {
  dataAE.add("\r");
  dataAE.add("\t" + "app.endUndoGroup();" + "\r");
  dataAE.add("}  //end script" + "\r");
  dataAE.endSave(scriptsFilePath + "/" + aeFileName + "_" + millis() + "." + aeFileType);
}
