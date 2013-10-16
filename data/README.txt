ManosOsc 1.1.0
by Nick Fox-Gieg  |  fox-gieg.com

~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

I.  ABOUT
ManosOsc outputs OSC from the Leap controller, tracking the coordinates of your hands and fingers.

~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

II.  CONTROLS
* (D)ebug: Press the D key to toggle a detailed display of the OSC data that ManosOsc is sending. Defaults to ON.

* (Z) reverse: Press the Z key to toggle mirrored tracking--when you move your hand toward the screen, the tracked points move toward you. Defaults to ON.

* (T)races: Press the T key to toggle trails of previous hand and finger positions. Defaults to ON.

* (O)sc: Press the O key to toggle sending OSC data. Defaults to ON.

* (F)older: Opens the app folder in your OS X Finder or Windows Explorer.

* Default settings can be changed by editing the settings.txt file in the app directory.

~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

III.  OSC (Open Sound Control)
To connect two devices over OSC, both of them need to agree on three things:

1. The IP address of the destination machine. By default, this is localhost (127.0.0.1), because you usually want a peripheral gadget to talk to the machine in front of you.

2. An arbitrary port number to connect to. By default, this is 7110.

3. An arbitrary channel name for each stream of data--for example, each axis of a controller. 

* Hand channels:
contents: 
string (name), int (hand id), float (x), float (y), float (z)   

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

To take advantage of the app's OSC output, you'll need to send this information to a program that speaks OSC. 
Two free examples for both Mac and Windows are:
PureData: http://puredata.info/
Processing: http://processing.org/

~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
