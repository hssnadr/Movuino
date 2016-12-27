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

// Set your configuration here
const char * ssid = "Joel Chevrier Bonjour";       // your network SSID (name of the wifi network)
const char * pass = "chevrier";                    // your network password
const char * hostIP = "10.0.1.2";                  // IP address of the host computer
unsigned int port = 2390;                          // port on which data are sent

MPU6050 accelgyro;
ESP8266WiFiMulti WiFiMulti;
WiFiClient client;
int packetNumber = 0;
unsigned int time0 = micros();
unsigned int time1 = micros();
int samplingDelay = 10000; //10ms =100 hz
int16_t ax, ay, az; // store accelerometre values
int16_t gx, gy, gz; // store gyroscope values
int16_t mx, my, mz; // store magneto values

WiFiUDP Udp;

void setup() {
  pinMode(0, OUTPUT);
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

  while (WiFiMulti.run() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
  delay(50);
  Udp.begin(port);
  delay(50);
  IPAddress myIp = WiFi.localIP();
}

void loop() {
  IPAddress myIp = WiFi.localIP();

  accelgyro.getMotion9(&ax, &ay, &az, &gx, &gy, &gz, &mx, &my, &mz); // Get all 9 axis data (acc + gyro + magneto)
  //---- OR -----//
  //accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz); // Get only axis from acc & gyr

  printMovuinoData();

  OSCMessage msg("/movuinOSC");
  msg.add(ax / float(32768));
  msg.add(ay / float(32768));
  msg.add(az / float(32768));
  msg.add(gx / float(32768));
  msg.add(gy / float(32768));
  msg.add(gz / float(32768));
  Udp.beginPacket(hostIP, port);
  msg.send(Udp);
  Udp.endPacket();
  msg.empty();

  delay(10);
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
  Serial.print("\t ");
  Serial.print(mx);
  Serial.print("\t ");
  Serial.print(my);
  Serial.print("\t ");
  Serial.print(mz);
  Serial.println("");
}
