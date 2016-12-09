# Movuino streamer

This part is a Python script which receive Movuino sensors data through wifi connection.
Once you have the data you can compute anything you want, including various libraries (some will come here, especially XMM, developped by IRCAM).
Then it streams the data you want through OSC communication.

###Installation needed
* Python 2.7
* Python libraries:
  * Numpy: easiest way with command line `sudo pip install numpy`
    * This library allows better data manipulation, especially using matrix and vectors
  * pyOSC
    * Dl link: https://pypi.python.org/pypi/pyOSC
    * Reference: https://wiki.labomedia.org/index.php/Envoyer_et_recevoir_de_l%27OSC_en_python#Reception_d.27un_message_avec_un_serveur
    
Go into the Main.py file and `main()` function of each script to see how to interact with the code.

### Note
* the pyOSC library returns an error when you close the server thread (`self.s.close()`). This error is not really a problem since 
the thread is actually closed once called. If you know how to handle it please tell me cause I don't know when I will check that.
* On the OSC template, each data are sent one per one. But you can group them using   
`oscmsg.append(message)`  
For example:
`oscmsg = OSC.OSCMessage()`  
`oscmsg.setAddress("/osc/accMovuino")`  
`oscmsg.append(accX)`  
`oscmsg.append(accY)`  
`oscmsg.append(accZ)`  
`self.c.send(oscmsg)`  
will send those 3 data into one single message on address "/osc/accMovuino"  
(see inside `sendOSCMessage(self, address, message)` function into OSC_Communication.py file)  

    
