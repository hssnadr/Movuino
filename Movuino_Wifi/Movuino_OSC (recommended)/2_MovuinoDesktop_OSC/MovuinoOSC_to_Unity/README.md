# Movuino to Unity

This template shows how to communicate with the Movuino using OSC protocole. You can receive the data and send back message to the Movuino.

## Installation
 1. Just download the folder and open it in Unity;
 2. If you launch the game without changing anything (with the Movuino folder include in this template), you should see the cube rotating while moving the Movuino;
 3. Go into the script `CubeControl_byMovuino.cs`: here you can see how to handle Movuino data. You just need to call the movuino object:
  * `OSCControl.movuino.acc3` to get the Vector 3 containing the acceleration data;
  * `OSCControl.movuino.gyr3` to get the Vector 3 containing the gyroscope data.
At this step you can already manipulate Movuino into your application as you want.

To go further:
 4. Go into the `OSCControl.cs`
 5. Here you can edit the port where you receive the Movuino data: `OSCHandler.Instance.InitServer("ServerOSC", 7400);` **be sure to match the one inside the Movuino firmware (port)**
 6. You can also specify the IP address of Movuino and its own listening port to send it back messages: `OSCHandler.Instance.InitClient("ClientOSC", "192.168.1.36", 3011);` **be sure to match the one inside the Movuino firmware (localPost)**
   * the IP address of Movuino is written into the Arduino monitor window when Movuino connects to the network

Next time (cause now I have to visit a friend):
 7. how to send back message to Movuino
 8. how to receive OSC messages others than Movuino data
