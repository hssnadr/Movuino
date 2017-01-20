/**
 * oscP5 website at http://www.sojamo.de/oscP5
 */

void newOSCMessage(String canal, float message) {
  /* create a new OscMessage with an address pattern, in this case /test. */
  OscMessage myOscMessage = new OscMessage("/" + canal);
  /* add a value (an integer) to the OscMessage */
  myOscMessage.add(message);
  /* send the OscMessage to a remote location specified in myNetAddress */
  oscP5.send(myOscMessage, myBroadcastLocation);
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  if (theOscMessage.checkAddrPattern("/osc/accX")) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("f")) { //f=flot, s = string, i = int ...
      ax = theOscMessage.get(0).floatValue() ;
      println("AccX = " +ax);
      return;
    }
  }
  
  if (theOscMessage.checkAddrPattern("/osc/accY")) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("f")) { //f=flot, s = string, i = int ...
      ay = theOscMessage.get(0).floatValue() ;
      println("AccY = " +ay);
      return;
    }
  }
  
  if (theOscMessage.checkAddrPattern("/osc/accZ")) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("f")) { //f=flot, s = string, i = int ...
      ay = theOscMessage.get(0).floatValue() ;
      println("AccZ = " +az);
      return;
    }
  }
  println("### received an osc message. with address pattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
}