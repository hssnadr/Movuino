# Mubu for Movuino

MuBu is a Max/MSP package developed by IRCAM. It gives Max objects to easily store and manage data flows.
* Presentation: https://www.julesfrancoise.com/mubu-probabilistic-models/
* Download link: http://forumnet.ircam.fr/fr/produit/mubu/
* References (2012): http://forumnet.ircam.fr/wp-content/uploads/2012/10/MuBu-for-Max-Reference.pdf
* Discussion forum: http://forumnet.ircam.fr/user-groups/mubu-for-max/forum/
  
In this code template, the purpose is to exploit the HHMM libraries (Hidden Hierarchical Markov Movel) also developed by IRCAM. This allows to record different gestures (here 3 gestures) and to make them recognize in real time by the algorithm. More specifically, this template is made to receive data of the Movuino sensor. The firmware used for Movuino is also provided and can be update directly with the Arduino software.

## Content

Here you will find:  
* in the Arduino folder, a firmware template for the Movuino board, editable with Arduino;
* A Max/MSP file containing the interface and the libraries to recognize your gestures.

## Installation
  
### Movuino
* Download and install the Arduino software: https://www.arduino.cc/en/Main/Software
* Download and install the CP2014 driver: http://www.silabs.com/products/mcu/Pages/USBtoUARTBridgeVCPDrivers.aspx
* Inside Arduino
  * Install the card ESP8266 following those instructions: https://learn.sparkfun.com/tutorials/esp8266-thing-hookup-guide/installing-the-esp8266-arduino-addon
 * Go to Tools/Board, select "Adafruit HUZZAH ESP8266" with:
      * CPU Frequency: 80 MHz
      * Flash Size: 4M (3M SPIFFS)
      * Upload Speed: 115200
      * Port: the one corresponding to the Movuino
  * Copy the content of the Arduino folder into your own Arduino folder (Macintosh and Windows: Documents/Arduino). It includes the libraries you need, but you can also install them by yourself. In the Arduino software go to "Sketch/Include Library/Manage Libraries...", here seek and install:  
    * I2Cdev
    * OSC
    * MPU6050
      * for this one you need to make a correction in the library file. Go to Arduino/libraries/MPU6050/ and edit the file "MPU6050.h" (open it in NotePad, SublimeText, NotePad++ or anykind of text editor).
        * line 58, replace the line: `#define MPU6050_DEFAULT_ADDRESS MPU6050_ADDRESS_AD0_LOW`
        * **by:** `#define MPU6050_DEFAULT_ADDRESS MPU6050_ADDRESS_AD0_HIGH`
  * Restart Arduino and follow instructions inside the code (ip, rooter, password, port...)
     * `const char * ssid = "my_box_name";` set the name of your wifi network
     * `const char * pass = "my_password";` type the password of the network
     * `const char * hostIP = "192.168.1.35";` set the ip address of **YOUR COMPUTER** which is also connected to the same Wifi network and on which you will use the Max file
     * `const unsigned int port = 7400;` (optional) here you can set the port on which the data are sent. If you don't use other ports or if you have no idea of what I'm talking about you can let 7400.
     * `const unsigned int localPort = 3011;` (optional) here you can set the port on which Movuino can receive OSC message. Idem, better to let it at 3011.
  * Upload firmware and check on the Arduino monitor window if everything is good!
  
  
### MAX/MSP
To run the Max file, you'll need to install the MuBu package. It's very simple!
* download the package on the MuBu page: http://forumnet.ircam.fr/fr/produit/mubu/
* unzip the folder "MuBuForMax" and simply past it into the proper folder:
 * **On Macintosh**
    * go to Applications folder, right click on the **Max** icon and choose "Show Package Contents"
    * paste the MuBuForMax folder into Contents/Resources/C74/packages
    * launch or restart Max and that's it.
  * **On Windows**
    * paste the MuBuForMax folder into C:\Program Files\Cycling '74\Max 7\resources\packages
    * launch or restart Max and that's it.
    
Once everything is installed and launch, you should see the Movuino data moving on the Max graphic "Movuino Data". Then the instruction are given within the file. The workflow is
 * Step 1: Select the gesture you want to record (1,2 and 3)
 * Step 2: Trigger the record, the recording starts automatically when you start moving and stops when you stop;
 * Step 3: Activate the play mode;
 * Reproduce the recorded gestures and follow the output at the bottom of the patch;
 * You can also replay the recorded gestures by clicking on the gesture you want above the `PLAY` subpatch.
