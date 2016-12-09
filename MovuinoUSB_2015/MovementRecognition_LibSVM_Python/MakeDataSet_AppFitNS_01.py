# Generate a data set based on examples store in the folder "DataCollection"
# Normalized data set
# Store normalization parameters for each features (mean and range)
# Store the data set

import glob, os
import numpy as np
import scipy.io as sio
import getFeatures_Detection
import matplotlib.pyplot as plt

def PCA(dataSetMatrix):
    #Principal Component Analysis
    #features association: project features on specific vectors to reduce their number
    #PCA function compute Ureduce (used by LogisticRegression.m and PLAY.m)
    #cf. Coursera - Week 13 - PCA Algorithm
    m = len(dataSetMatrix[:,1]) # number of training example
    X_ = dataSetMatrix
    
    #Compute eigen vectors and matrix
    #formula p.28
    Sigma = (1/float(m))*np.dot(X_.T,X_)
    U,S,V = np.linalg.svd(Sigma, full_matrices=True)
    
    #Get main componants
    #formula p.29
    k=1
    while(np.sum((S[:k])/(np.sum(S))) <0.99): #precision up to 99#
        k=k+1
    
    Ureduce = U[:,:k]

    # Plot weight graph (optional)
    sU = np.dot(U.T, np.array([S]).T)
    wMeanFeatures = np.mean(np.abs(sU),axis=1)
    print "wMeanFeatures = ", wMeanFeatures.shape
    fig, ax = plt.subplots()
    ax.bar(range(len(wMeanFeatures)), wMeanFeatures, bottom=np.min(wMeanFeatures))
    plt.show()

    return Ureduce

# GET ROW DATAS
# corresponding to Good/Bad movements
os.chdir("DataCollectionTEST/")
dataWindow = 40
# timeWindow = 0.2

X = []
Xtemp = []

# Go over "good" files (Y=1)
mGood = 0 # number of Y=1 examples
Fenetre = [] ##### Debug
for f in glob.glob("*Lunges*") : # + glob.glob("*UppercutG*") :
    print(f)

    curFile = open(f, "r") # read file
    dataFile = curFile.read().split("\n")
    
    # Initiate data vector
    rowData = np.empty((1,7)) #[accX, accY, accZ, gyrX, gyrY, gyrZ, time]
    rowData[:] = np.NaN

    # Get data file
    if len(dataFile)>= dataWindow : #check if there's enough data
        
        # Go over each data rows
        for i in range(1,len(dataFile)) :
            data = dataFile[i].split()
            if (len(data)==8 and data[0]=='l') :
                rowData = np.append(rowData, [[float(data[1]),float(data[2]),float(data[3]),float(data[4]),float(data[5]),float(data[6]),float(data[7])]], axis=0)
        rowData = rowData[1:,:] #leave first row of NaN elements

        # find index minAccY
        # indMinAccY = np.where(rowData[:,1]==np.min(rowData[:,1]))[0][0]
        # print "indMinAccY", indMinAccY
        # # find index minY - 0.3s
        # indDetecStart = np.where(rowData[:,6]>=rowData[indMinAccY,6]-0.35)[0][0]
        # print "indDetecStart", indDetecStart
        # # find index (minY-0.3s) + 0.25s
        # indDetecStop = np.where(rowData[:,6]>=rowData[indDetecStart,6]+timeWindow)[0][0]
        # print "indDetecStop", indDetecStop

        indMiddle = int(len(rowData[:,1])/2)

        indDetecStart = indMiddle - int(dataWindow/2) # - 5
        indDetecStop = indDetecStart + dataWindow
        # print "indMiddle", indMiddle
        # print "indDetecStart", indDetecStart
        # print "indDetecStop", indDetecStop

        # Get features
        if (indDetecStop - indDetecStart > 3) :
            Fenetre.append(indDetecStop-indDetecStart) ##### Debug
            for j in range(-3,3) :
                if (indDetecStart+j >= 5) and (indDetecStop+j < len(rowData[:,1])) :
                    X_ = getFeatures_Detection.getFeatures_Detection(rowData[indDetecStart+j:indDetecStop+j,:]) # get corresponding features
                    mGood+= 1 # update counter
                    if Xtemp==[]:
                        Xtemp = [X_] # generate data set matrix
                    else :
                        Xtemp = np.append(Xtemp,[X_],axis=0) # update data set matrix
                    if np.where(np.isnan(Xtemp))[0].size > 0 :
                        break
    #Manage big matrix (clear Xtemp and transfer data into X)
    if len(Xtemp[:])>1000:
        if X==[]:
            X = Xtemp
            Xtemp = []
        else :
            X = np.append(X,Xtemp,axis=0)
            Xtemp = []
    curFile.close()

#Fill X with data left in Xtemp
if Xtemp!=[]:
    if X==[]:
            X = Xtemp
            Xtemp = []
    else :  
        X = np.append(X,Xtemp,axis=0)
        Xtemp = []
Y =np.ones((mGood)) # generate output vector for Y=1 examples

#-------------------
#Get "bad" moves / no moves data

# Go over "bad" files (Y=0)
mBad = 0
for f in glob.glob("*[^Lunges]*") : # glob.glob("*letter*")
    #Manage balance between good and bad examples in data set
    # if mBad >= mGood :
    #     break

    print(f)

    curFile = open(f, "r") # read file
    dataFile = curFile.read().split("\n")

    # Initiate data vector
    rowData = np.empty((1,7)) #[accX, accY, accZ, gyrX, gyrY, gyrZ, time]
    rowData[:] = np.NaN

    # Get data file
    if len(dataFile)>= dataWindow : #check if there's enough data
        # Go over each data rows
        for i in range(1,len(dataFile)) :
            data = dataFile[i].split()
            if (len(data)==8 and data[0]=='l') :
                rowData = np.append(rowData, [[float(data[1]),float(data[2]),float(data[3]),float(data[4]),float(data[5]),float(data[6]),float(data[7])]], axis=0)
        rowData = rowData[1:,:] #leave first row of NaN elements

        for indStart in range(5,len(rowData)-5,int(dataWindow/3)) :
            if len(rowData)>= indStart+dataWindow : #check if there's enough data
                # Get features
                X_ = getFeatures_Detection.getFeatures_Detection(rowData[indStart:indStart+dataWindow,:]) # get corresponding features
                mBad+= 1
                if Xtemp==[]:
                    Xtemp = [X_] # generate data set matrix
                else :
                    Xtemp = np.append(Xtemp,[X_],axis=0) # update data set matrix
                if np.where(np.isnan(Xtemp))[0].size > 0 :
                    break
    if len(Xtemp[:])>1000:
        if X==[]:
            X = Xtemp
            Xtemp = []
        else :
            X = np.append(X,Xtemp,axis=0)
            Xtemp = []
    curFile.close()


if Xtemp!=[]:
    if X==[]:
            X = Xtemp
            Xtemp = []
    else :
        X = np.append(X,Xtemp,axis=0)
        Xtemp = []
Y = np.append(Y,np.zeros((mBad)))  # update output vector with Y=0 examples

print X
print 'nan', np.where(np.isnan(X))[0].size
print X.shape
print Y.shape

# NORMALIZE DATA SET
rangeInput = np.amax(X,axis=0)-np.amin(X,axis=0) # range of each features
print 'rangeInput', rangeInput
print 'nan', np.where(np.isnan(rangeInput))[0].size
meanInput = np.average(X,axis=0) # mean of each features
for i in range(0,len(X[1,:])) :
    if rangeInput[i] != 0 :
        X[:,i] = (X[:,i] - meanInput[i])/rangeInput[i] # normalization
    else :
        X[:,i]=0 # avoid infinite case
# #Save normalization parameters for further uses (PLAY)
# sio.savemat('../SVMVariable_Detection/NormalizationParameters_Detection.mat', {"rangeInput":rangeInput,"meanInput":meanInput})

# PCA
Ureduce = PCA(X)
# sio.savemat('../SVMVariable_Detection/Ureduce_Detection.mat', {"Ureduce":Ureduce}) # save Ureduce
Z = np.dot(Ureduce.T,X.T).T # apply reduction matrix on data set
Z = np.concatenate((np.ones((len(Y),1)),Z),axis=1) # add bias unit

#Save SVM parameters
np.savez('../SVMVariable_Detection/SVMparameters', rangeInput=rangeInput, meanInput=meanInput, Ureduce=Ureduce)

#Shuffle data set
newOrder = np.arange(len(Y))
np.random.shuffle(newOrder)
Zrand = Z[newOrder,:]
Yrand = Y[newOrder]
# sio.savemat('../SVMVariable_Detection/DataSet.mat', {"X":Zrand,"Y":Yrand}) # save data set
np.savez('../SVMVariable_Detection/DataSet', X=Zrand, Y=Yrand)

print X.shape
print 'nan', np.where(np.isnan(X))[0].size
print Ureduce.shape
print Z.shape

print "mGood", mGood
print "mBad", mBad
print "moyenne fenetre", sum(Fenetre)/float(len(Fenetre))
print 'lenFenetre', len(Fenetre)