import sys
import time
import math
import numpy as np
import OSC_communication as osc
import Movuino_Streamer as mov


def main(args = None):

	# Initialize streaming thread
	streamer= mov.DataStreamer()

	# Initializa data collection and run the thread
	streamer.start_newCollection() 

	osc_client = osc.OSCclient('127.0.0.1', 7000) # Init client communication on specific Ip and port

	# Start OSCServer
	print "Starting OSCServer"
	osc_server = osc.OSCserver('127.0.0.1', 5000) # Init server communication on specific Ip and port
	osc_server.addListener("test") # add listener on address "test"
	osc_server.addListener("fader") # add listener on address "fader"
	osc_server.addListener("dAcc") # add listener on address "dAcc"
	osc_server.addListener("dGyr") # add listener on address "dGyr"
	
	timer0 = time.time()
	timer1 = timer0
	while (timer1-timer0 < 10):
		timer1 = time.time()
		time.sleep(0.05) # regulate data flow speed

		print "SERVER:", osc_server.get_CurrentMessage()

		# Return current data received
		accX = float(streamer.get_lastData()[1]) / 255
		accY = float(streamer.get_lastData()[2]) / 255
		accZ = float(streamer.get_lastData()[3]) / 255
		gyrX = float(streamer.get_lastData()[4]) / 255
		gyrY = float(streamer.get_lastData()[5]) / 255
		gyrZ = float(streamer.get_lastData()[6]) / 255

		osc_client.sendOSCMessage('accX', accX)
		osc_client.sendOSCMessage('accY', accY)
		osc_client.sendOSCMessage('accZ', accZ)
		osc_client.sendOSCMessage('gyrX', gyrX)
		osc_client.sendOSCMessage('gyrY', gyrY)
		osc_client.sendOSCMessage('gyrZ', gyrZ)


		# Computation before to send data
		dis = math.sqrt(accX**2 + accY**2 + accZ**2)
		osc_client.sendOSCMessage('distance', dis)

		print "---------------"

	# Return all data received since last collection initialization
	print streamer.get_dataCollection()

	osc_server.closeServer() # return ERROR MESSAGE but ignore it (close the OSC server without killing the app)
	streamer.stop() # Stop streaming
	streamer.join() # Close thread

if __name__ == '__main__':
    sys.exit(main())