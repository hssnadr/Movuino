//
//	  UnityOSC - Example of usage for OSC receiver
//
//	  Copyright (c) 2012 Jorge Garcia Martin
//
// 	  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
// 	  documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// 	  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
// 	  and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
// 	  The above copyright notice and this permission notice shall be included in all copies or substantial portions 
// 	  of the Software.
//
// 	  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
// 	  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// 	  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
// 	  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// 	  IN THE SOFTWARE.
//

using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityOSC;

public struct Movuino
{
	public Vector3 acc3;
	public Vector3 gyr3;
}

public class OSCControl : MonoBehaviour {
	
	private Dictionary<string, ServerLog> servers;
	private Dictionary<string, ClientLog> clients;
	public static Movuino movuino;

	// Script initialization
	void Start() {	
		OSCHandler.Instance.InitServer("ServerOSC", 7400); //init OSC server SAME PORT THAN THE ONE OF MOVUINO
		OSCHandler.Instance.InitClient("ClientOSC", "192.168.1.36", 3011); //init OSC client with MOVUINO IP address and its listening port
		servers = new Dictionary<string, ServerLog>();
		clients = new Dictionary<string,ClientLog> ();

		movuino = new Movuino ();
		movuino.acc3 = new Vector3 (0, 0, 0);
		movuino.gyr3 = new Vector3 (0, 0, 0);
	}

	// NOTE: The received messages at each server are updated here
    // Hence, this update depends on your application architecture
    // How many frames per second or Update() calls per frame?
	void Update() {
		//Always put this command into the loop
		OSCHandler.Instance.UpdateLogs();

		servers = OSCHandler.Instance.Servers; // create OSC server (to receive messages)
		clients = OSCHandler.Instance.Clients; // create OSC client (to send messages)

		try
		{
			OSCHandler.Instance.SendMessageToClient ("ClientOSC", "dAcc", 666.0f); // SEND OSC MESSAGE
			OSCHandler.Instance.SendMessageToClient ("ClientOSC", "dGyr", 999.0f); // SEND OSC MESSAGE
		}
		catch (Exception e)
		{
			//Debug.LogException(e, this);
			//UnityEngine.Debug.Log ("No OSC client, message not sent"); // Handle exception
		}


		OSCHandler.Instance.UpdateLogs();

		//Print last message received and/or sent with OSC
		string curMess;

		// Get Movuino data
		OSCHandler.Instance.getServerLog(servers, "movuinOSC"); // update movuino object (see Movuino structure above)

		// Get other OSC messages
		curMess = OSCHandler.Instance.getServerLog(servers, "otheraddressOSCmessage"); // to receive other messages than Movuino data
		UnityEngine.Debug.Log ("SERVER: last message = " + curMess);

		//Print last message sent 
		string curClAddr = OSCHandler.Instance.getLastClientLog (clients)[0];
		string curClMess = OSCHandler.Instance.getLastClientLog (clients)[1];
		//UnityEngine.Debug.Log ("CLIENT: " + curClAddr + " " + curClMess);
	}

	private float GetFloat(string stringValue, float defaultValue)
	{
		float result = defaultValue;
		float.TryParse(stringValue, out result);
		return result;
	}
}