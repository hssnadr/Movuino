import sys
import time
import numpy as np
import OSC_communication as osc
import math

def main(args = None):
	# Start OSC server (to receive message)
	print "Starting OSCServer"
	osc_server = osc.OSCserver('192.168.1.35', 7400) # Init the OSC server with YOUR IP and use the same port number as the sender (here Movuino on port 7400)
	osc_server.addListener("movuinOSC") # add listener on address "movuinOSC"
	time.sleep(0.1)

	d1 = 0.0
	d2 = 0.0

	# Start OSC client (to send message)
	osc_client = osc.OSCclient('192.168.1.36', 3011) # Init the OSC client with the IP of the host, for Movuino you need to check the address on the Arduino serial monitor when the connection is set

	timer0 = time.time()
	timer1 = timer0
	while (timer1-timer0 < 10):
		timer1 = time.time()
		time.sleep(0.05)

		# RECEIVE MOVUINO DATA
		curAddr, curVal = osc_server.get_CurrentMessage() # extract address and values of current message
		if curAddr == "movuinOSC" :
			ax = float(curVal[0])
			ay = float(curVal[1])
			az = float(curVal[2])
			gx = float(curVal[3])
			gy = float(curVal[4])
			gz = float(curVal[5])

			print ax, ay, az, gx, gy, gz

			d1 = 100 * math.sqrt(ax**2 + ay**2 + az**2) # compute euclidan distance (example)
			d2 = 100 * math.sqrt(gx**2 + gy**2 + gz**2) # compute euclidan distance (example)

		# SEND MESSAGE TO MOVUINO
		osc_client.sendOSCMessage('dAcc', d1) # send back accelerometer euclidian distance to Movuino (useless but just for the example)
		osc_client.sendOSCMessage('dGyr', d2) # send back gyroscope euclidian distance to Movuino (useless but just for the example)	

		print "---------------"

	osc_server.closeServer() # ERROR MESSAGE but close the OSC server without killing the app

if __name__ == '__main__':
    sys.exit(main())