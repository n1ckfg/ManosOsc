//based on oscP5parsing by andreas schlegel
import oscP5.*;
import netP5.*;

//String ipNumber = "127.0.0.1";
int receivePort = 7110;
OscP5 oscP5;

String[] oscChannelNames = { 
  "hand0", "hand0-0", "hand0-1", "hand0-2", "hand0-3", "hand0-4", "hand1", "hand1-0", "hand1-1", "hand1-2", "hand1-3", "hand1-4"
};

void oscSetup() {
  oscP5 = new OscP5(this, receivePort);
}

void oscEvent(OscMessage msg) {
 try{
   for(int i=0;i<oscChannelNames.length;i++){
      if (msg.checkAddrPattern("/"+oscChannelNames[i]) && msg.checkTypetag("ifff")) { //a hand
        int idHand = msg.get(0).intValue();
        hands[idHand].show = true;
        hands[idHand].idHand = idHand;
        hands[idHand].t.x = sW * msg.get(1).floatValue();
        hands[idHand].t.y = sH * msg.get(2).floatValue();
        hands[idHand].t.z = sD * msg.get(3).floatValue();
        //attempt to filter NaNs
        //if (hands[idHand].p.x > -10000 && hands[idHand].p.y > -10000 && hands[idHand].p.z > -10000){
          println(hands[idHand].idHand + " " + hands[idHand].p);
        //}
     /*
     else if (msg.get(0).stringValue().equals("l_foot")) {
        s.lFootCoords[0] = msg.get(2).floatValue();
        s.lFootCoords[1] = msg.get(3).floatValue();
        s.lFootCoords[2] = msg.get(4).floatValue();
      } 
      */
    }else if (msg.checkAddrPattern("/"+oscChannelNames[i]) && msg.checkTypetag("iifff")) { //a finger
        int idHand = msg.get(0).intValue();
        int idFinger = msg.get(1).intValue();
        hands[idHand].oscFinger[idFinger].show = true;
        hands[idHand].oscFinger[idFinger].idHand = idHand;
        hands[idHand].oscFinger[idFinger].idFinger = idFinger;
        hands[idHand].oscFinger[idFinger].t.x = sW * msg.get(2).floatValue();
        hands[idHand].oscFinger[idFinger].t.y = sH * msg.get(3).floatValue();
        hands[idHand].oscFinger[idFinger].t.z = sD * msg.get(4).floatValue();
        //attempt to filter NaNs
        //if (hands[idHand].oscFinger[idFinger].p.x > -10000 && hands[idHand].oscFinger[idFinger].p.y > -10000 && hands[idHand].oscFinger[idFinger].p.z > -10000){
          println(hands[idHand].oscFinger[idFinger].idHand + " " + hands[idHand].oscFinger[idFinger].idFinger + " " + hands[idHand].oscFinger[idFinger].p);
        //}
    }
  }
 }catch(Exception e){ }
}
