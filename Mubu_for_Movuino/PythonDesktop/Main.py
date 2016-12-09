import sys
import time
import numpy as np
import math
import OSC_communication as osc
import Movuino_Streamer as mov

def main(args = None):

	# Initialize streaming thread
	streamer= mov.DataStreamer()

	# Initializa data collection and run the thread
	streamer.start_newCollection()

	osc_client = osc.OSCclient('127.0.0.1', 3011) # Init client communication on specific Ip and port

	time.sleep(0.1)

	timer0 = time.time()
	timer1 = timer0
	osc_client.sendOSCMessage('isMov', 1)
	rawData = np.zeros((1,1)) # reset data collection array

	while (timer1-timer0 < 20):
		timer1 = time.time()
		time.sleep(0.05)

		# Return current data received
		accX = float(streamer.get_lastData()[1]) / float(32768)
		accY = float(streamer.get_lastData()[2]) / float(32768)
		accZ = float(streamer.get_lastData()[3]) / float(32768)
		gyrX = float(streamer.get_lastData()[4]) / float(32768)
		gyrY = float(streamer.get_lastData()[5]) / float(32768)
		gyrZ = float(streamer.get_lastData()[6]) / float(32768)
		da = math.sqrt(accX**2 + accY**2 + accZ**2)
		dg = math.sqrt(gyrX**2 + gyrY**2 + gyrZ**2)

		osc_client.sendOSCMessage('accX', accX)
		osc_client.sendOSCMessage('accY', accY)
		osc_client.sendOSCMessage('accZ', accZ)
		osc_client.sendOSCMessage('gyrX', gyrX)
		osc_client.sendOSCMessage('gyrY', gyrY)
		osc_client.sendOSCMessage('gyrZ', gyrZ)
		 
		print "---------------"

	osc_client.sendOSCMessage('isMov', 0)

	# Return all data received since last collection initialization
	print streamer.get_dataCollection()

	osc_server.closeServer() # ERROR MESSAGE but close the OSC server without killing the app
	streamer.stop() # Stop streaming
	streamer.join() # Close thread

if __name__ == '__main__':
    sys.exit(main())