import math
import time
import numpy as np
from svmutil import *

#Not necessary
import serial #to get our sensor data 
import pygame #to close session by closing pygame window

#Local script
import getFeatures_Detection


#Initialize graphic window
pygame.display.init()
fig = pygame.display.set_mode((640, 480)) #Open main window

#Initialize serial communication with the sensor
# ser = serial.Serial('COM7',38400, timeout=1) # for Windows
ser = serial.Serial('/dev/cu.usbmodem1421',38400, timeout=1) # for Mac

#Check sensor configuration
ser.write("i")
dataSensor = ser.readline().split()
print dataSensor

##
# INITIALIZE CAPTURE
# Get logistic regression model parameters FOR DETECTION
mDetection = svm_load_model('WM_SVMmodel_Detection.model') # based on libsvm library

npzfile = np.load('SVMVariable_Detection/SVMparameters.npz')
rangeInput_Detection = npzfile['rangeInput']
meanInput_Detection = npzfile['meanInput']
Ureduce_Detection = npzfile['Ureduce']

# Real time parameters
delay = 0.01 # delay between each row from the sensor
sizeDataWindow_Detection = 40 # number of data store at each moment for movement detection
timeStart = time.time() #time from 1st of January 1970 (second)

# Moving average Data matrix parameters
N = 5; # range for moving average
dataCollect = np.empty((N,7)) # matrix containing sensors datas to compute moving average
dataCollect[:] = np.NaN
dataCollect_MMean = np.empty((sizeDataWindow_Detection,7)) # matrix containing sensors moving average datas on the observation window
dataCollect_MMean[:] = np.NaN
cRegulator = 0 #Regulator counter
cRegulatorMax = 10 #Regulate number of time data get analysed (cRegulator go back to 0 if cRegulator > cRegulatorMax)

##----------------------------------------------------------------------------
# START PLAY MODE
# Send command to sensor (l = Live mode)
ser.write("l")
time.sleep(0.1)

print("start!")
isFig = True #check if main window is still open
while(isFig):
    # time.sleep(delay) # allow time delay between measures
    
    # Scan serial port
    data = ser.readline().split()
    curTime = time.time()-timeStart # get current time
    # Data format verification before manipulation
    if (len(data)==7 and (data[0]=="l" or data[0]=="r")):
        # Extract values from serial data
        accX = float(data[1])
        accY = float(data[2])
        accZ = float(data[3])
        gyrX = float(data[4])
        gyrY = float(data[5])
        gyrZ = float(data[6])
        
        # Store into data window matrix
        dataCollect = np.concatenate((dataCollect[1:,:] , [[accX, accY, accZ, gyrX, gyrY, gyrZ, curTime]]),axis=0);
        
        # Moving average (store into dataCollect_MMean)
        if (np.where(np.isnan(dataCollect))[0].size == 0) :  # mean average if enough data
            meanDat_ = (1/float(N))*np.sum(dataCollect[:,:6],axis=0) # mean average on data (not on time)
            meanDat_ = np.concatenate((meanDat_ , [dataCollect[-1,6]]),axis=1) # add time
            dataCollect_MMean = np.concatenate((dataCollect_MMean[1:,:], [meanDat_]),axis=0) # matrix containing filtered sensors datas on the observation window
        
        cRegulator += 1
        # print cRegulator, curTime
        
        # Analyze data only if dataCollect_Mean is full of data
        if (np.where(np.isnan(dataCollect_MMean))[0].size == 0 and cRegulator >= cRegulatorMax) : # if there's no more NaN (dataCollect is full) the window is evaluated
            # Movement DETECTION (on dataCollect_MMean)
            cRegulator = 0

            # Get features
            X = getFeatures_Detection.getFeatures_Detection(dataCollect_MMean)
            
            # Features normalization based on parameters of the model
            Xnorm = np.empty(X.shape)
            Xnorm[:] = np.NAN
            for i in range(0,len(X)):
                if (rangeInput_Detection[i] != 0) : # avoid infinite case (when rangeInput=0)
                    Xnorm[i] = (X[i] - meanInput_Detection[i])/rangeInput_Detection[i]
                else:
                    Xnorm[i]=0
                    
            #Features reduction
            Z = np.dot(Ureduce_Detection.T,Xnorm)
            Z = np.concatenate(([1],Z),axis=0).tolist() #add bias units
            dicZ = [{x: Z[x] for x in range(0,len(Z))}]
            
            # Get output estimation
            p_label, p_acc, p_val = svm_predict([1], dicZ, mDetection,'-q')
            p_label = p_label[0]
            print p_label, curTime

            # Check output estimation
            if p_label>0.5 :
                print 'DETECTION :             ', p_val
    
                # Resize dataCollect_MMean on Detection window
                dataCollect_MMean = np.empty((sizeDataWindow_Detection,7))
                dataCollect_MMean[:] = np.NaN  
                ser.flushInput() #empty serial
    
    # Manage serial issues            
    elif not data :
        print "serial is empty"
    
    elif data[0]=="L": # manage specific case (cf. sensor)
        print "sensor sending bytes: session terminated"
        break
        
    elif data[0]=="M": # manage specific case (cf. sensor)
        print "M error" 
    
    # Close window to terminate session
    for event in pygame.event.get(): #check for event
        if(event.type==pygame.QUIT or (event.type==pygame.KEYDOWN and event.key==pygame.K_ESCAPE)): #press escape to leave the while loop
            isFig=False
            pygame.quit()
            
##----------------------------------------------------------------------------
#close serial communication with sensor
print("stop!")
ser.write("q") # stop sending data from movuino
ser.close()

print "\nYOU MUST DEFEAT SHENG LONG TO STAND A CHANCE"