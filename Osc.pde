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
