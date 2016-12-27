import processing.serial.*;
import oscP5.*;
import netP5.*;

//-----------
//-----------
OscP5 oscP5;
/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation;

//Movuino data
float ax=0;
float ay=0;
float az=0;
float gx=0;
float gy=0;
float gz=0;

void setup () {
  // set the window size:
  size(60,60);
  background(0);
  
  // create a new instance of oscP5. 7400 is the port number you are listening for incoming osc messages.
  oscP5 = new OscP5(this, 7400); // this port must be the same than the port on the Movuino
  
  // create a new NetAddress. a NetAddress is used when sending osc messages with the oscP5.send method.
  // the address of the osc broadcast server
  myBroadcastLocation = new NetAddress("192.168.1.36", 3011); // Init the OSC client with the IP of the host, for Movuino you need to check the address on the Arduino serial monitor when the connection is set
}


void draw() {
  // SEND MESSAGE TO MOVUINO
  float d1 = sqrt(pow(ax,2) + pow(ay,2) + pow(az,2)); // compute euclidan distance (example)
  float d2 = sqrt(pow(gx,2) + pow(gy,2) + pow(gz,2)); // compute euclidan distance (example)
  
  newOSCMessage("dAcc", d1); // send back accelerometer euclidian distance to Movuino (useless but just for the example)
  newOSCMessage("dGyr", d2); // send back gyroscope euclidian distance to Movuino (useless but just for the example)
}