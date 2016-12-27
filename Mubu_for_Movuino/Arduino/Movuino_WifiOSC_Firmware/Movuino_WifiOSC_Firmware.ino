/*
    This sketch is a Movuino firmware.
    It allows the Movuino to send data on a specific Wifi through an OSC protocol. (Open Sound Control)
*/

#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiUdp.h>
#include "Wire.h"
#include "I2Cdev.h"
#include "MPU6050.h"
#include <OSCBundle.h>
#include <OSCMessage.h>
#include <OSCTiming.h>
#include <SLIPEncodedSerial.h>
#include <SLIPEncodedUSBSerial.h>

// Set your wifi network configuration here
//const char * ssid = "my_box_name";               // your network SSID (name of the wifi network)
//const char * pass = "my_password";               // your network password
const char * ssid = "Livebox-dfc4";                      // your network SSID (name of the wifi network)
const char * pass = "2C4A14671307251995325AF6E1";                 // your network password
const char * hostIP = "192.168.1.35";            // IP address of the host computer
const unsigned int port = 7400;                  // port on which data are sent (send OSC message)

MPU6050 accelgyro;
ESP8266WiFiMulti WiFiMulti;
WiFiClient client;
int packetNumber = 0;
int16_t ax, ay, az; // store accelerometre values
int16_t gx, gy, gz; // store gyroscope values
int16_t mx, my, mz; // store magneto values

// Button variables
const int pinBtn = 13;     // the number of the pushbutton pin
boolean isBtn = 0;         // variable for reading the pushbutton status
float pressTime = 1000;    // pressure time needed to switch Movuino state
float lastButtonTime;
boolean lockPress = false; // avoid several activation on same button pressure
boolean isWifi;

// LEDs
const int pinLedWifi = 2; // wifi led indicator
const int pinLedBat = 0;  // battery led indicator

WiFiUDP Udp;

void setup() {
  // pin setup
  pinMode(pinBtn, INPUT_PULLUP); // pin for the button
  pinMode(pinLedWifi, OUTPUT);   // pin for the wifi led
  pinMode(pinLedBat, OUTPUT);    // pin for the battery led

  Wire.begin();
  Serial.begin(115200);
  delay(10);

  // initialize device
  Serial.println("Initializing I2C devices...");
  accelgyro.initialize();

  // We start by connecting to a WiFi network
  WiFiMulti.addAP(ssid, pass);

  Serial.println();
  Serial.println();
  Serial.print("Wait for WiFi... ");

  // wait while connecting to wifi ...
  while (WiFiMulti.run() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }

  // Movuino is now connected to Wifi
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
  delay(50);
  Udp.begin(port);
  delay(50);
  IPAddress myIp = WiFi.localIP();
  isWifi = true;
}

void loop() {
  
  // BUTTON CHECK
  isBtn = digitalRead(pinBtn); // check if button is pressed
  if (isBtn) {
    lastButtonTime = millis();
    lockPress = false;
  }
  else {
    if (millis() - lastButtonTime > pressTime && !lockPress) {
      lockPress = true; // avoid several activation with same pressure
      isWifi = !isWifi; // switch state
      lastButtonTime = millis();

      if (!isWifi) {
        shutDownWifi();
      }
      else {
        awakeWifi();
      }
    }
  }
  
  // MOVUINO DATA
  if (WiFi.status() == WL_CONNECTED) {
    IPAddress myIp = WiFi.localIP();

    // GET MOVUINO DATA
    //accelgyro.getMotion9(&ax, &ay, &az, &gx, &gy, &gz, &mx, &my, &mz); // Get all 9 axis data (acc + gyro + magneto)
    //---- OR -----//
    accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz); // Get only axis from acc & gyr

    delay(5);
    
    printMovuinoData(); // optionnal

    // SEND MOVUINO DATA
    OSCMessage msg("/movuinOSC"); // create an OSC message on address "/movuinOSC"
    msg.add(ax / float(32768));   // add acceleration X data as message
    msg.add(ay / float(32768));   // add acceleration Y data
    msg.add(az / float(32768));   // add ...
    msg.add(gx / float(32768));
    msg.add(gy / float(32768));
    msg.add(gz / float(32768));    // you can add as many data as you want
    Udp.beginPacket(hostIP, port); // send message to computer target with "hostIP" on "port"
    msg.send(Udp);
    Udp.endPacket();
    msg.empty();

    delay(5);
  }
  else {
    delay(200); // wait more if Movuino is sleeping
  }
}

void shutDownWifi() {
  WiFi.mode(WIFI_OFF);
  WiFi.forceSleepBegin();
  delay(1); // needed
  digitalWrite(pinLedWifi, HIGH); // turn OFF wifi led
  digitalWrite(pinLedBat, HIGH);  // turn OFF battery led
  Serial.println("OFF");
}

void awakeWifi() {
  // Awake wifi and re-connect Movuino
  WiFi.forceSleepWake();
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, pass);
  digitalWrite(pinLedBat, LOW); // turn ON wifi led

  //Blink wifi led while wifi is connecting
  while (WiFiMulti.run() != WL_CONNECTED) {
    digitalWrite(pinLedWifi, LOW);
    delay(200);
    digitalWrite(pinLedWifi, HIGH);
    delay(200);
  }
  digitalWrite(pinLedWifi, LOW);
  Serial.println("ON");
}

void printMovuinoData() {
  Serial.print(ax / float(32768));
  Serial.print("\t ");
  Serial.print(ay / float(32768));
  Serial.print("\t ");
  Serial.print(az / float(32768));
  Serial.print("\t ");
  Serial.print(gx / float(32768));
  Serial.print("\t ");
  Serial.print(gy / float(32768));
  Serial.print("\t ");
  Serial.print(gz / float(32768));
  Serial.println("");
}
