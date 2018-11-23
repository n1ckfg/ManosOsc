# ManosOsc 1.1.7
by Nick Fox-Gieg  |  fox-gieg.com

~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

I.  ABOUT
Track your hands and fingers using the Leap Motion Controller and output coordinates over OSC or MIDI.

~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

II.  CONTROLS
* (D)ebug: Press the D key once to toggle a detailed display of the OSC data that ManosOsc is sending. Press it twice to show MIDI data. Defaults to ON.

* (Z) reverse: Press the Z key to toggle mirrored tracking--when you move your hand toward the screen, the tracked points move toward you. Defaults to ON.

* (O)sc: Press the O key to toggle sending OSC data. Defaults to ON.

* (M)idi: Press the M key to toggle sending MIDI data. Defaults to ON.

* (F)older: Opens the app folder in your OS X Finder or Windows Explorer.

* Default settings can be changed by editing the settings.txt file in the app directory.

~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

III.  OSC (Open Sound Control)
To connect two devices over OSC, both of them need to agree on three things:

1. The IP address of the destination machine. By default, this is localhost (127.0.0.1), because you usually want a peripheral gadget to talk to the machine in front of you.

2. An arbitrary port number to connect to. By default, this is 7110.

3. An arbitrary channel name for each stream of data--for example, each axis of a controller. 

The OSC port and destination IP address can be changed by editing the settings.txt file in the app directory.

To take advantage of the app's OSC output, you'll need to send this information to a program that speaks OSC. 
Two free examples for both Mac and Windows are:
PureData: http://puredata.info/
Processing: http://processing.org/

* Hand channels:
contents: 
string (name), int (hand id), int (active origins), float (x), float (y), float (z)   

names: 
/hand0  
/hand1

* Finger channels:
contents: 
string (name), int (hand id), int (finger id), float (x), float (y), float (z)   

names:
/finger0-0
/finger0-1
/finger0-2
/finger0-3
/finger0-4
/finger1-0
/finger1-1
/finger1-2
/finger1-3
/finger1-4

* The same naming convention is used for tool and origin (first knuckle) channels.

* Active channel:
contents:
int (active hands), int (active fingers), int (active tools), int (active origins)

name:
/active

* If you'd like to send different channel message formats, change the "OSC Channel Format" setting. Supported apps include Isadora, OSCeleton, and Animata. To preserve compatibility with old projects, you can also choose the "OldManos" format setting, which had a different message format for hands: 
string (name), int (hand id), float (x), float (y), float (z)   

~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

IV.  MIDI (Musical Instrument Digital Interface)

If you're working with sound and music apps like Ableton Live, you might find MIDI easier to use. (Be aware, however, that it's much less precise than OSC.) 

The MIDI port and channel can be changed by editing the settings.txt file in the app directory.

The ability to route MIDI between applications and over a network is built into OS X, but Windows will need a third-party driver. Two free examples are:
Midi-Yoke: http://www.midiox.com/myoke.htm
rtpMIDI: http://www.tobias-erichsen.de/software/rtpmidi.html

* Each tracking point has a MIDI controller assigned to its x, y, and z axis:

hand0       1,2,3
finger0-0   4,5,6
finger0-1   7,8,9
finger0-2   10,11,12
finger0-3   13,14,15
finger0-4   16,17,18
hand1       19,20,21
finger1-0   22,23,24
finger1-1   25,26,27
finger1-2   28,29,30
finger1-3   31,32,33
finger1-4   34,35,36

~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
