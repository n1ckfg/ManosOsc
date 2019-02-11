import promidi.*;

MidiIO midiIO;
MidiOut midiOut;

int midiChannelNum = 0;
int midiPortNum = 0;

//setup function
void midiSetup(){
  midiIO = MidiIO.getInstance(this);
  midiIO.printDevices();
  try{
    midiOut = midiIO.getMidiOut(midiChannelNum,midiPortNum); //channel, port
  }catch(Exception e){
    try{
      midiOut = midiIO.getMidiOut(0,0); //channel, port
    }catch(Exception ee){ }
  }
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
