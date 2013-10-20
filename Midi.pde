import promidi.*;

MidiIO midiIO;
MidiOut midiOut;

//setup function
void midiSetup(){
  midiIO = MidiIO.getInstance(this);
  midiIO.printDevices();
  midiOut = midiIO.getMidiOut(0,0);
}

void sendCtl(int ch, int val){
  midiOut.sendController(
    new promidi.Controller(ch,val)
  );
}

void midiTester(){
  for(int i=0;i<36;i++){
    sendCtl(i,int(random(127)));
  }
}

