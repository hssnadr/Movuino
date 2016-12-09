# import scipy.io
import numpy as np
from svmutil import *

# X = scipy.io.loadmat('SVMVariable_Detection/DataSet.mat')['X']
# Y = scipy.io.loadmat('SVMVariable_Detection/DataSet.mat')['Y'][0]

# X = scipy.io.loadmat('LRVariables.mat')['Xtrain']
# Y = scipy.io.loadmat('LRVariables.mat')['Ytrain']

npzfile = np.load('SVMVariable_Detection/DataSet.npz')
X = npzfile['X']
Y = npzfile['Y']

print X[0,:5]
print Y

n = len(X[0,:])
m = len(Y) 
mtrain = int(0.7*m)
print "n =",n
print "m =",m
print "mtrain =", mtrain

Xtrain = X[:mtrain,:].tolist()
Ytrain = Y[:mtrain].tolist()
Xtest = X[mtrain:,:].tolist()
Ytest = Y[mtrain:].tolist()

probTrain = svm_problem(Ytrain,Xtrain)
mSVM = svm_train(probTrain, '-c 20 -g 0.8') # '-c 8 -g 0.5' based on grid.py with 3 slices in features
print "\nTRAINING SET"
p_label, p_acc, p_val = svm_predict(Ytrain,Xtrain, mSVM)
print "\nTEST SET"
p_label, p_acc, p_val = svm_predict(Ytest,Xtest, mSVM)
svm_save_model('WM_SVMmodel_Detection.model', mSVM)

# Save data set as a libsvm file
dataSet_file = open("WMdataset_Detection", "w")
for i in range(m):
    if Y[i]==0:
        Y_ = -1
    else:
        Y_ = +1
    dataSet_file.write("%d" % (Y_)) # write output
    for j in range(n):
        dataSet_file.write(" %d:%f" % (j+1,X[i,j])) # write input (features)
    dataSet_file.write("\n") # insert new line
    
# # Read data in LIBSVM format
# y, x = svm_read_problem('WMdataset_Detection')
# m = svm_train(y[:mtrain], x[:mtrain], '-c 8 -g 0.5') # '-c 8 -g 0.5' based on grid.py with 3 slices in features
# print "\nTRAINING SET"
# p_label, p_acc, p_val = svm_predict(y[:mtrain], x[:mtrain], m)
# print "\nTEST SET"
# p_label, p_acc, p_val = svm_predict(y[mtrain:], x[mtrain:], m)
# # print "p_val = ", p_val

# print "---------\n"

# m = svm_train(y[:mtrain], x[:mtrain], '-t 0 -c 4 -b 1')
# print "\nTRAINING SET"
# p_label, p_acc, p_val = svm_predict(y[:mtrain], x[:mtrain], m)
# print "\nTEST SET"
# p_label, p_acc, p_val = svm_predict(y[mtrain:], x[mtrain:], m)
# print "---------\n"

# m = svm_train(y[:mtrain], x[:mtrain], '-t 2 -c 5')
# print "\nTRAINING SET"
# p_label, p_acc, p_val = svm_predict(y[:mtrain], x[:mtrain], m)
# print "\nTEST SET"
# p_label, p_acc, p_val = svm_predict(y[mtrain:], x[mtrain:], m)
# print "---------\n"