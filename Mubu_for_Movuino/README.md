# Mubu for Movuino

MuBu is a Max/MSP package developed by IRCAM. It gives Max objects to easily store and manage data flows.
* Presentation: https://www.julesfrancoise.com/mubu-probabilistic-models/
* Download link: http://forumnet.ircam.fr/fr/produit/mubu/
* References (2012): http://forumnet.ircam.fr/wp-content/uploads/2012/10/MuBu-for-Max-Reference.pdf
* Discussion forum: http://forumnet.ircam.fr/user-groups/mubu-for-max/forum/  
  
In this code template, the purpose is to exploit the HHMM libraries (Hidden Hierarchical Markov Movel) also developed by IRCAM. This allows to record different gestures (here 3 gestures) and to make them recognize in real time by the algorithm. More specifically, this template is made to receive data of the Movuino sensor. The firmware used for Movuino is also provided and can be update directly with the Arduino software.

## Content

Here you will find:  
* in the Arduino folder, a firmware template for the Movuino board, editable with Arduino. 
* A Max/MSP file;

## Installation
  
### Movuino
* Download and install the Arduino software: https://www.arduino.cc/en/Main/Software
* Download and install the XXX driver: www.xxxx.com/download
* Inside Arduino
  * Install the card ESP8266 following those instructions: https://learn.sparkfun.com/tutorials/esp8266-thing-hookup-guide/installing-the-esp8266-arduino-addon
  * Choose card (Tools/Board): Adafruit HUZZAH ESP8266
  * Copy the content of the Arduino folder into your own Arduino folder (Macintosh and Windows: Documents/Arduino). It includes the libraries you need, but you can also install them by yourself. In the Arduino software go to "Sketch/Include Library/Manage Libraries...", here seek and install:  
    * I2Cdev
    * OSC
    * MPU6050
      * for this one you need to make a correction in the library file. Go to Arduino/libraries/MPU6050/ and edit the file "MPU6050.h" (open it in NotePad, SublimeText, NotePad++ or anykind of text editor).
        * line 58, replace the line: `#define MPU6050_DEFAULT_ADDRESS MPU6050_ADDRESS_AD0_LOW`
        * **by:** `#define MPU6050_DEFAULT_ADDRESS MPU6050_ADDRESS_AD0_HIGH`
  * Follow instructions inside the code (ip, rooter, password, port...)
     * `const char * ssid = "my_box_name";` set the name of your wifi network  
     * `const char * pass = "my_password";` type the password of the network  
     * `const char * hostIP = "192.168.1.35";` set the ip address of **YOUR COMPUTER** which is also connected to the same Wifi network and on which you will use the Max file  
     * `const unsigned int port = 7400;` optionnal: here you can set the port on which the data are sent. If you don't use other ports or if you have no idea of what I'm talking about you can let 7400.
  * Go to Tools/Board, select "Adafruit HUZZAH ESP8266" with:
      * CPU Frequency: 80 MHz
      * Flash Size: 4M (3M SPIFFS)
      * Upload Speed: 115200
      * Port: the one corresponding to the Movuino
  * Upload firmware and check on the Arduino monitor window if everything is good!
  * You can shut down (partially) and turn on the Movuino by pressing the button during 1 second.
  
### MAX/MSP
To run the Max file, you'll need to install the MuBu package. It's very simple!  
* download the package on the MuBu page: http://forumnet.ircam.fr/fr/produit/mubu/
* unzip the folder "MuBuForMax" and simply past it into the proper folder:
 * **On Macintosh**
    * go to Applications folder, right click on the **Max** icon and choose "Show Package Contents"
    * paste the MuBuForMax folder into Contents/Resources/C74/packages
    * launch or restart Max and that's it
  * **On Windows**
    * go to your installation folder (e.g.)
    * **to complete**  
    
  
  
It also includes libraries, but you can get them by yourself. In the Arduino software go to "Sketch/Include Library/Manage Libraries...", here you can install:  
 * I2Cdev
 * OSC
  
Concerning MPU6050 you better use the one in the folder, otherwise download manually the library (https://github.com/jrowberg/i2cdevlib/tree/master/Arduino/MPU6050), intall it by copying it into your Arduino folder, and edit the file Arduino/libraries/MPU6050/MPU6050.h
   * line 58, replace the line: `#define MPU6050_DEFAULT_ADDRESS MPU6050_ADDRESS_AD0_LOW`
   * **by:** `#define MPU6050_DEFAULT_ADDRESS MPU6050_ADDRESS_AD0_HIGH`

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

    


