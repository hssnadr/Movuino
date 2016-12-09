% MINIMIZE COST FUNCTION ON LAMBDA VARIATION
% Get Theta values for each lambda values
% Lambda = regularization term of the logistic regression model
% use fminunc (MatLab function) on the TRAINING SET

% Lambda values
Lambda=0:3:50; % lambda (vector) values going to be tested
optTheta = zeros(n+1,length(Lambda)); % matrix of weight features (theta) corresponding to each lambda values

% Theta initialization
% initialize features weight (theta) at 0
thetaInit=zeros(n,1); % theta initializeation without bias unit
thetaInit=[0;thetaInit]; % add bias unit

% Minimise costFunction over LAMBDA values
fprintf('0/%d\n',length(Lambda));% display progression
for i=1:length(Lambda)
    lambda = Lambda(i);
    save('LRvariables.mat','Xtrain','Ytrain','lambda'); % store values for the cost function store in folder "Logistic Regression"
    
    % fminunc to minimize cost function and get optTheta_ (for 1 value of lambda)
    options = optimset('GradObj','on','MaxIter',10000); % Optimization options
    [optTheta_,functionVal, exitFlag] = fminunc(@costFunctionLR,thetaInit,options); 
    
    optTheta(:,i) = optTheta_; % store optTheta_ values in optTheta matrix (for all lambda values)
    fprintf('%d/%d\n',i,length(Lambda));% display progression
end

%%
% TEST OPTHETA ON TRAINING SET OVER LAMBDA VARIATION
% Evaluate %error, %recall and %precision
% for each values of optTheta in function of lambda values

errorTrain = zeros(size(Lambda)); % Error array on training set
precisionTrain = zeros(size(Lambda)); % Precision array on training set
recallTrain = zeros(size(Lambda)); % Recall array on training set

disp('-----------------------');
disp('TRAINING SET');

% Go over lambda values
for i=1:length(Lambda)
    %temp values initialization
    err = 0;
    truePos = 0;
    falsePos = 0;
    trueNeg = 0;
    falseNeg = 0;
    
    disp('-----------------------');
    
    % Go over training examples
    for j=1:mtrain
        %Get single training example
        X_ = Xtrain(j,:)';
        h = hFun(X_,optTheta(:,i)); %evaluate output

        % Estimated as positive
        if(h >= 0.5)
            fprintf('Good y = %d ; h = %f', Ytrain(j),h);
            truePos = truePos + 1;
            if(Ytrain(j)==0) % if output of the data set (true value) is negative (Y=0) then it's a false positive
                %update values
                err = err + 1;
                truePos = truePos - 1;
                falsePos = falsePos + 1;
                fprintf('  <-------');
            end
            fprintf('\n');
            
        % Estimated as negative
        else
            fprintf('Bad y = %d ; h = %f', Ytrain(j),h);
            trueNeg = trueNeg + 1;
            if(Ytrain(j)==1) % if output of the data set (true value) is positive (Y=1) then it's a false negative
                %update values
                err = err + 1;
                trueNeg = trueNeg - 1;
                falseNeg = falseNeg + 1;
                fprintf('  <-------');
            end
            fprintf('\n');
        end
    end
    % Get pourcentages
    errorTrain(i) = 100*err/mtrain; % formula p.17
    precisionTrain(i) = double(truePos/(truePos+falsePos)); % formula p.21
    recallTrain(i) = double(truePos/(truePos+falseNeg));
    
    %Display results
    disp('----');
    fprintf('lambda = %d ; error = %f\n',Lambda(i),errorTrain(i));
    fprintf('False positive = %f percent\n',falsePos*100/mtrain);
    fprintf('Precision = %f\n',precisionTrain(i));
    fprintf('False negative = %f percent\n',double(falseNeg*100/mtrain));
    fprintf('Recall = %f\n',recallTrain(i));
end

%%
% TEST OPTHETA ON TEST SET OVER LAMBDA VARIATION
% idem on TEST SET
% Evaluate %error, %recall and %precision
% for each values of optTheta in function of lambda values

disp('-----------------------');
disp('TEST SET');

errorTest = zeros(size(Lambda)); % Error array on test set
precisionTest = zeros(size(Lambda)); % Precision array on test set
recallTest = zeros(size(Lambda)); % Recall array on test set

% Go over lambda values
for i=1:length(Lambda)
    %temp values initialization
    err = 0;
    truePos = 0;
    falsePos = 0;
    trueNeg = 0;
    falseNeg = 0;
    
    disp('-----------------------');
    
    % Go over test set examples
    for j=1:mtest
        %Get single test example
        X_ = Xtest(j,:)';
        h = hFun(X_,optTheta(:,i)); %evaluate output

        % Estimated as positive
        if(h >= 0.5)
            fprintf('Good y = %d ; h = %f', Ytest(j),h);
            truePos = truePos + 1;
            if(Ytest(j)==0) % if output of the data set (true value) is negative (Y=0) then it's a false positive
                %update values
                err = err + 1;
                truePos = truePos - 1;
                falsePos = falsePos + 1;
                fprintf('  <-------');
            end
            fprintf('\n');
            
        % Estimated as negative
        else
            fprintf('Bad y = %d ; h = %f', Ytest(j),h);
            trueNeg = trueNeg + 1;
            if(Ytest(j)==1) % if output of the data set (true value) is positive (Y=1) then it's a false negative
                %update values
                err = err + 1;
                trueNeg = trueNeg - 1;
                falseNeg = falseNeg + 1;
                fprintf('  <-------');
            end
            fprintf('\n');
        end
    end
    
    % Get pourcentages
    errorTest(i) = 100*err/mtest; % formule p.17
    precisionTest(i) = double(truePos/(truePos+falsePos)); % formule p.21
    recallTest(i) = double(truePos/(truePos+falseNeg));
    
    %Display results
    disp('----');
    fprintf('lambda = %d ; error = %f\n',Lambda(i),errorTest(i));
    fprintf('False positive = %f percent\n',falsePos*100/mtest);
    fprintf('Precision = %f\n',precisionTest(i));
    fprintf('False negative = %f percent\n',double(falseNeg*100/mtest));
    fprintf('Recall = %f\n',recallTest(i));
   
end

%%
% GRAPHIC RESULTS VIZUALISATION (optional)
% Plot Jtrain VS Jtest on : %error, %recall, % precision
% variation over Lambda

figure('Name','Lambda variations results');

% Graphic % Error
subplot(4,1,1);
hold on
plot(Lambda,errorTrain,'k-o');
plot(Lambda,errorTest,'r-x');
title('Jtrain VS Jtest','FontSize',15);
ylabel('error (%)','FontSize',15);
grid('on');
legend('Jtrain','Jtest');
hold off

% Graphic % Precision (cf. false positive)
subplot(4,1,2);
grid('on');
hold on
plot(Lambda,precisionTrain,'k-o');
plot(Lambda,precisionTest,'r-x');
ylabel('Precision','FontSize',15);
legend('Train','Test');
hold off

% Graphic % Recall (cf. false negative)
subplot(4,1,3);
grid('on');
hold on
plot(Lambda,recallTrain,'k-o');
plot(Lambda,recallTest,'r-x');
ylabel('Recall','FontSize',15);
legend('Train','Test');
hold off

% Graphic % FScore (score based on recall and precision)
subplot(4,1,4);
grid('on');
hold on
FScoreTrain = 2*(precisionTrain.*recallTrain)./(precisionTrain+recallTrain);
FScoreTest = 2*(precisionTest.*recallTest)./(precisionTrain+recallTest);
plot(Lambda,FScoreTrain,'k-o');
plot(Lambda,FScoreTest,'r-x');
xlabel('lambda','FontSize',15);
ylabel('FScore','FontSize',15);
legend('Train','Test');
hold off

% Save figure
savefig('LambdaVariation_')