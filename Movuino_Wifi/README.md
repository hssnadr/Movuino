# Movuino Wifi - Code Template

Movuino is a wireless sensor board. It includes an accelerometer, a gyroscope and a magnetometer.  
Here is a code template to stream those data from the board to your computer using Wifi, and then to stream them to any application using Open Sound Control:
* Presentation:  http://opensoundcontrol.org/
* Reference: http://opensoundcontrol.org/spec-1_0

Here you will find:  
* Firmware template for the Movuino board, editable with Arduino
* Python script receiving data from Movuino, computing them and sharing them through OSC
* Template to receive those data on various application:
  * Unity
  * Processing
  * Pure Data
  * Max MSP
  * More to come ...  
  
The interest to use Python between Movuino and others development plateforms is to more quickly prototype various scenarios. Once you have a nice data algorithm in Python you can easily plug it to any kind of application using OSC.  
You can even mixe application, for example: a game developped with Processing for screen interaction while the sound is generated with PureData.  
Also, Python has lots of powerful open source libraries ready to make data computation (SVM, Markov chains, linear regression...) and is very flexible to handle lots of data using Numpy library.  

# Movuino board firmware (Firmware_MovuinoWifi/Movuino_WifiFirmware)

* Install Arduino software
* Inside Arduino
  * Install the card ESP8266: https://learn.sparkfun.com/tutorials/esp8266-thing-hookup-guide/installing-the-esp8266-arduino-addon
  * Choose card (Tools/Board): Adafruit HUZZAH ESP8266
  * Install library MPU6050: Sketch/Include Library/Manage Libraries... seek and install MPU6050
  * Follow instructions inside the code (ip, rooter, password, port...)
  * Upload firmware and check on the Arduino monitor window if everything is good
  
### Important
* **You have to change a code a line into the MPU6050 library (file : Arduino/libraries/MPU6050/MPU6050.h)**
 * line 58, set: `#define MPU6050_DEFAULT_ADDRESS MPU6050_ADDRESS_AD0_HIGH` (instead of `_LOW`)  
 -> You can change it with any code / text editor, even Windows Notepad
* In the Movuino firmware, the ip you set must be the one of the computer which will receive data with the Python script. The computer and the Movuino board must be connected **on the same wifi network.**  

  
   
   
# Movuino streamer (MovuinoDesktop_Python)

This part is a Python script which receive Movuino sensors data through wifi connection.
Once you have the data you can compute anything you want, including various libraries (some will come here, especially XMM, developped by IRCAM).
Then it streams the data you want through OSC communication.

###Installation needed
* Python 2.7
* Python libraries:
  * Numpy: easiest way with command line `sudo pip install numpy`
    * This library allows better data manipulation, especially using matrix and vectors
  * pyOSC
    * DL link: https://pypi.python.org/pypi/pyOSC
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

    


