/*
    This sketch is a Movuino firmware.
    It allows the Movuino to send data on a specific Wifi through a UDP protocol.
*/

#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiUdp.h>
#include "Wire.h"
#include "I2Cdev.h"
#include "MPU6050.h"

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

  time1 = micros();
  unsigned int time2 = time1 - time0;
  //Refresh values every 10ms
  if (time2 >= samplingDelay)
  {
    accelgyro.getMotion9(&ax, &ay, &az, &gx, &gy, &gz, &mx, &my, &mz); // Get all 9 axis data (acc + gyro + magneto)
    //---- OR -----//
    //accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz); // Get only axis from acc & gyr

    Udp.beginPacket(hostIP, 2390);
    digitalWrite(0, LOW);
    if (packetNumber < 255) packetNumber ++;
    else packetNumber = 0;

    char msg[30];
    sprintf(msg, "%d %d %d %d %d %d %d", packetNumber, ax, ay, az, gx, gy, gz);
    Udp.write(msg);
    Udp.endPacket();
    time0 = micros();

    printMovuinoData();
  }
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

