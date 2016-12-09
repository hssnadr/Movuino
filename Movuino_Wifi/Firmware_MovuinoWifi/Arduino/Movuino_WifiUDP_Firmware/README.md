# Movuino board firmware

* Install Arduino software
* Inside Arduino
  * Install the card ESP8266: https://learn.sparkfun.com/tutorials/esp8266-thing-hookup-guide/installing-the-esp8266-arduino-addon
  * Choose card (Tools/Board): Adafruit HUZZAH ESP8266
  * Install library MPU6050: Sketch/Include Library/Manage Libraries... seek and install MPU6050
  * Follow instructions inside the code (ip, rooter, password, port...)
  * Upload firmware and check on the Arduino monitor window if everything is good
  
### Important
**You have to change a code a line into the MPU6050 library (file : Arduino/libraries/MPU6050/MPU6050.h)**
* line 58, set: `#define MPU6050_DEFAULT_ADDRESS MPU6050_ADDRESS_AD0_HIGH` (instead of `_LOW`)  
-> You can change it with any code / text editor, even Windows Notepad
