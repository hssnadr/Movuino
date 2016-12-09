% Machine Learning using Logistic Regression
% Train the mathematic model to evaluate movement quality
% Use example store in folder "DataCollection"

clearvars;
addpath('../TrainingSetVariables');
addpath('../LogisticRegression');

%%
% COMPUTE DATA SET
% make a normalized data set based on moves store in folder "DataCollection"
cd('../');
disp('loading data set...')
MakeDataSet_MainG_Evaluation; % script make TrainingSetVariables/DataSet_Evaluation.mat

%%
% FEATURES REDUCTION
% by Principal Component Analysis (PCA)

%Compute reduction matrix
load('TrainingSetVariables/DataSet_Evaluation.mat'); % get X and Y (no bias units)
Ureduce_Evaluation = PCA(X); %features reduction (generate Ureduce)
save('TrainingSetVariables/Ureduce_Evaluation.mat','Ureduce_Evaluation');

%Apply features reduction on data set
m = length(Y); % number of trainging examples
X = Ureduce_Evaluation'*X'; % features reduction

n = size(X',2); % number of features (after reduction)
X = [ones(m,1) X']; %add bias units

%%
% GENERATE TRAINING AND TEST SET based on data set
% training set = 70% of data set
% test set = 30% of data set

% Shuffle data set to get unique data each time
randomOrder = randperm(m); % new random order
Xrand = X(randomOrder,:); % new random data set input
Yrand = Y(randomOrder,:); % new random data set output

% Training Set (70% data set)
mtrain = int16(m*0.7);
Xtrain = Xrand(1:mtrain ,:);
Ytrain = Yrand(1:mtrain);

% Test Set (30% data set)
Xtest = Xrand(mtrain+1:m,:);
Ytest = Yrand(mtrain+1:m);
mtest = m-mtrain;

% Display information
fprintf('m = %d \n', m)
fprintf('mtrain = %d \n', mtrain)
fprintf('mtest = %d \n', mtest)

%%
% MINIMIZE COST FUNCTION ON LAMBDA VARIATION
% Lambda = regularization term of the logistic regression model
% use fminunc (MatLab function) on the TRAINING SET

% Script computing optTheta over lambda values
cd('LogisticRegression');
OptTheta_LambdaVariations;
cd('..\');

% Selection of lambda with the best results (minimum error) on training and
% test set
optLambda_Evaluation = 0; %/!!\ --> faire une fonction pour determiner sa valeur automatiquement à partir du testSet
optTheta_Evaluation = optTheta(:,1); %changer automatiquement l'indice de la colonne en fonction de optLambda_ModDet
save('TrainingSetVariables/optTheta_Evaluation.mat','optTheta_Evaluation');
save('TrainingSetVariables/optTheta.mat','optTheta'); % if necessary

%%
% (optional)
% MINIMIZE COST FUNCTION ON Mtrain VARIATION (size of the training set)
% Get Theta values for each mtrain values
% use fminunc (MatLab function) on the TRAINING SET

% Script computing optTheta over lambda values
cd('LogisticRegression');
OptTheta_mVariations;
cd('..\');