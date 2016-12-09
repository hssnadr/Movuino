#Features vector based on method discribed in 
#publication "Gesture Recognition with a 3-D Accelerometer"

import math
import cmath
import numpy as np

#not necessary
import glob, os #for debug

def drange(start, stop, step):
    # equivalent of function range except that it allows float steps
    r = start
    while r < stop:
        yield r
        r += step

def DFT(dataFrame,m):
    lFrame_ = len(dataFrame) #frame length lFram = 2.Ls in publication
    # print 'lFrame', lFrame
    t = 0
    for n_ in range(lFrame_):
        t += dataFrame[n_]*cmath.exp(-2*math.pi*1j*m*n_/(lFrame_-1))
    return t

def entropyDFT(dftData,m):
    p_ = float(dftData[m])/np.sum(dftData[1:])
    return p_

##----------------------------------------------------------------------------
def getFeatures_Detection(rowData):
    # Compute features of a data sequence corresponding to one move
    # Compute derived data (derived curves) based on row data
    # Slice each data curve to get series of point from each ones
    # Return a row vector of all features
    
    # Get data
    n = rowData.shape[0]
    ramp = np.linspace(1,100,num=n)
    accX = rowData[:,0]*ramp
    accY = rowData[:,1]*ramp
    accZ = rowData[:,2]*ramp
    gyrX = rowData[:,3]*ramp
    gyrY = rowData[:,4]*ramp
    gyrZ = rowData[:,5]*ramp
    time = rowData[:,6] - rowData[0,6] # Time origin
    
    # print np.fft.fft(accX), len(np.fft.fft(accX))


    # absDFTData = np.empty((n,6)) # matrix containing DFT data from input data
    # absDFTData[:] = np.NaN
    # for i in range(n):
    #     for j in range(6):
    #         absDFTData[i,j] = np.absolute(DFT(rowData[:,j],i))
    # print absDFTData
    # print absDFTData.shape




    # ##----------------------------------------------------------------------------
    # # COMPUTE DERIVED CURVES
    # # integral, double integral, derivative, double derivative
    
    # # Compute time integral (only to get others integral)
    # timeIntegral = [time[0]];
    # for k in range(1,n):
    #     timeIntegral.append(time[k]-time[k-1])
    
    # # Compute data integral (Speed X, Y,Z & Angle X,Y,Z)
    # integralData = np.empty((n,6))
    # integralData[:] = np.NAN
    # for k in range(0,n):
    #     integralData[k,:] = rowData[k,:6]*timeIntegral[k]
    #     if k>0 :
    #         integralData[k,:] += integralData[k-1,:]
    
    # # Compute data double integral (Position X,Y,Z)
    # doubleIntegralData = np.empty((n,6))
    # doubleIntegralData[:] = np.NAN
    # for k in range(0,n):
    #     doubleIntegralData[k,:] = integralData[k,:6]*timeIntegral[k]
    #     if k>0 :
    #         doubleIntegralData[k,:] += doubleIntegralData[k-1,:]
    
    # # Compute data derivate
    # derivData = np.empty((n,6))
    # derivData[:] = np.NAN
    # for k in range(0,n):
    #     if k==0 :
    #         derivData[k,:] = (rowData[k+1,:6]-rowData[k,:6])/(time[k+1]-time[k])
    #     elif k==n-1 :
    #         derivData[k,:] = (rowData[k,:6]-rowData[k-1,:6])/(time[k]-time[k-1])
    #     else :
    #         derivData[k,:] = (rowData[k+1,:6]-rowData[k-1,:6])/(time[k+1]-time[k-1])
     
    # # Compute double data derivate
    # doubleDerivData = np.empty((n,6))
    # doubleDerivData[:] = np.NAN
    # for k in range(0,n):
    #     if k==0 :
    #         doubleDerivData[k,:] = (derivData[k+1,:6]-derivData[k,:6])/(time[k+1]-time[k])
    #     elif k==n-1 :
    #         doubleDerivData[k,:] = (derivData[k,:6]-derivData[k-1,:6])/(time[k]-time[k-1])
    #     else :
    #         doubleDerivData[k,:] = (derivData[k+1,:6]-derivData[k-1,:6])/(time[k+1]-time[k-1])
            
    ##----------------------------------------------------------------------------
    # GET FEATURES
    # slice curves to get the same number of points on each curve
    
    step = 4 #number of slice
    ech = float(n)/float(step) #sampling
    timeStep_ = drange(0,n+ech,ech) #generate time steps
    indStep = []
    for i in timeStep_ :
        i = round(i,2)
        indStep.append(math.floor(i)) #get index corresponding to time steps
    x_=[] #features vector

    # Generate features for each frame (temporal and frequency domain)
    for i in range(len(indStep)-2) :
        # Get range of the frame
        ind = indStep[i]
        ind1 = indStep[i+2] #1 frame corresponds to 2 injunction
        if ind == ind1 :
            rg = ind
        else :
            rg = range(int(ind),int(ind1))
        lengFrame = len(rg)

        # Get Discrete Fourier Transform (DFT)
        absDFTData_ = np.empty((lengFrame,6)) # matrix containing DFT data from input data
        absDFTData_[:] = np.NaN
        for i in range(lengFrame):
            for j in range(6):
                absDFTData_[i,j] = np.absolute(DFT(rowData[rg,j],i))

        # Add DC component as features (for each axis x,y,z)
        x_ += absDFTData_[0,:].tolist()

        # Add energy features (exclude DC component)
        x_ += (np.sum(np.power(absDFTData_[1:,:],2),axis=0)/(lengFrame-1)).tolist()

        # Add entropy features (exclude DC component)
        entropyDFTData_ = np.empty((lengFrame,6)) # matrix containing DFT entropy data
        entropyDFTData_[:] = np.NaN
        for i in range(lengFrame):
            for j in range(6):
                entropyDFTData_[i,j] = entropyDFT(absDFTData_[:,j],i)
        x_ += np.sum(entropyDFTData_[1:,:]*np.log(1/entropyDFTData_[1:,:]),axis=0).tolist() # normalize entropy

        # Add deviation features (time domain)
        datMean = np.mean(rowData[rg,:-1],axis=0)
        x_ += np.sum(np.power( rowData[rg,:-1]-datMean ,2),axis=0).tolist()

        # Add corelation features (time domain)
        y_ = []
        for i in range(6):
            for j in range(6):
                if (j>i):
                    # vij = np.sum(np.abs(rowData[rg,i]*rowData[rg,j]))/float(lengFrame)
                    # vii = np.sum(np.abs(rowData[rg,i]*rowData[rg,i]))/float(lengFrame)
                    # vjj = np.sum(np.abs(rowData[rg,j]*rowData[rg,j]))/float(lengFrame)
                    # yij = (vij-datMean[i]*datMean[j]) / float(math.sqrt(vii-datMean[i]**2) * math.sqrt(vjj-datMean[j]**2))

                    yij = np.sum((rowData[rg,i]-datMean[i])*(rowData[rg,j]-datMean[j]))
                    if math.sqrt(np.sum(rowData[rg,i]-datMean[i])**2) * math.sqrt(np.sum(rowData[rg,j]-datMean[j])**2) != 0 :
                        yij /= float(math.sqrt(np.sum(rowData[rg,i]-datMean[i])**2) * math.sqrt(np.sum(rowData[rg,j]-datMean[j])**2))
                    else:
                        yij = 0
                    
                    y_.append(yij)
        x_ += y_

    # print x_
    # print len(x_)



    # Mean data
    # x_.append(np.max(accX)-np.min(accX))
    # print x_
    # x_.append(np.max(accY)-np.min(accY))
    # x_.append(np.max(accZ)-np.min(accZ))
    # x_.append(np.max(gyrX)-np.min(gyrX))
    # x_.append(np.max(gyrY)-np.min(gyrY))
    # x_.append(np.max(gyrZ)-np.min(gyrZ))    
    # x_ += (np.max(derivData,axis=0)-np.min(derivData,axis=0)).tolist()
    # x_ += (np.max(doubleDerivData,axis=0)-np.min(doubleDerivData,axis=0)).tolist()
    # x_.append(np.mean(accX))
    # x_.append(np.mean(accY))
    # x_.append(np.mean(accZ))
    # x_.append(np.mean(gyrX))
    # x_.append(np.mean(gyrY))
    # x_.append(np.mean(gyrZ))
    # x_ += np.mean(integralData,axis=0).tolist()
    # x_ += np.mean(doubleIntegralData,axis=0).tolist()
    # x_ += np.mean(derivData,axis=0).tolist()
    # x_ += np.mean(doubleDerivData,axis=0).tolist()
    
    # # Cut each curves and add each point in the features vector
    # #---ROW DATA (AccX, AccY,AccZ, GyrX, GyrY, GyrZ)
    # for i in range(len(indStep)-2) :
    #     ind = indStep[i]
    #     ind1 = indStep[i+2] #1 frame corresponds to 2 injunction
    #     if ind == ind1 :
    #         rg = ind
    #     else :
    #         rg = range(int(ind),int(ind1))
    #     print rg
    #     x_.append(np.mean(accX[rg]))

    ##----------------------------------------------------------------------------
    # MAKE FEATURES VECTOR
    Xoutput = np.asarray(x_)
    # Xoutput = np.concatenate((x_, np.power(x_, 2), np.power(x_, 3), np.sqrt(np.absolute(x_)),np.log(np.absolute(x_)+0.01)), axis=1) # Add features
#     Xoutput = Xoutput.reshape(len(Xoutput),1) # reshape array
    if np.where(np.isnan(Xoutput))[0].size != 0:
        print 'NANANANANANAN'
    return Xoutput


# print("Time to get online")
# os.chdir("DataCollection/")
# curFile = open("NoMove_RandomV1_USB60Hz_118.dat", "r") # read file
# dataFile = curFile.read().split("\n")

# # Initiate data vector
# rowData = np.empty((1,7)) #[accX, accY, accZ, gyrX, gyrY, gyrZ, time]
# rowData[:] = np.NaN

# # Go over each data rows
# for i in range(1,len(dataFile)) :
#     data = dataFile[i].split()
#     if (len(data)==8 and data[0]=='l') :
#         rowData = np.append(rowData, [[float(data[1]),float(data[2]),float(data[3]),float(data[4]),float(data[5]),float(data[6]),float(data[7])]], axis=0)
# rowData = rowData[1:,:] #leave first row of NaN elements

# X_ = getFeatures_Detection(rowData) # get corresponding features
# print('Good Bye')