import oscP5.*;
import netP5.*;

String ipNumber = "127.0.0.1";
int sendPort = 7110;
int receivePort = 33333;
OscP5 oscP5;
NetAddress myRemoteLocation;

void oscSetup() {
  oscP5 = new OscP5(this, receivePort);
  myRemoteLocation = new NetAddress(ipNumber, sendPort);
}

void oscTester(){
  OscMessage myMessage;
  myMessage = new OscMessage("/test");
  float testData = random(1);
  myMessage.add(testData);
  oscP5.send(myMessage, myRemoteLocation); 
}

void sendActiveOsc() {
  OscMessage myMessage;
  try{
    //myMessage = new OscMessage("/" + "finger" + idHand + "-" + idPointable);
    myMessage = new OscMessage("/active");
    myMessage.add(activeHands);
    myMessage.add(activeFingers);
    myMessage.add(activeTools);
    myMessage.add(activeOrigins);
    oscP5.send(myMessage, myRemoteLocation);
  }catch(Exception e){ }
  //println("Active hands: " + activeHands + "   fingers: " + activeFingers + "   tools: " + activeTools + "   origins: " + activeOrigins);
} 
