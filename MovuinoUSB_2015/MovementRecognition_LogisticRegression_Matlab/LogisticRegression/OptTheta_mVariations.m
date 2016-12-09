% MINIMIZE COST FUNCTION ON Mtrain VARIATION (size of the training set)
% Get Theta values for each mtrain values
% use fminunc (MatLab function) on the TRAINING SET

% Initialize model
% m goes from 1 to mtrain
lambda=optLambda_Evaluation; % based on lambda variation results
optTheta = []; % matrix of weight features (theta) corresponding to each m values

% Theta initialization
% initialize features weight (theta) at 0
thetaInit=zeros(n,1); % theta initializeation without bias unit
thetaInit=[0;thetaInit]; % add bias unit

% Minimise costFunction over LAMBDA values
fprintf('0/%d\n',mtrain); %display progression
for i=1:500:mtrain
    Xtrain = Xrand(1:i,:);
    Ytrain = Yrand(1:i);
    save('LRvariables.mat','Xtrain','Ytrain','lambda');  % store values for the cost function store in folder "Logistic Regression"
    
    % fminunc to minimize cost function and get optTheta_ (for 1 value of lambda)
    options = optimset('GradObj','on','MaxIter',10000); %Optimization options
    [optTheta_,functionVal, exitFlag] = fminunc(@costFunctionLR,thetaInit,options);
    
    optTheta = [optTheta optTheta_]; % store optTheta_ values in optTheta matrix (for all m values)
    fprintf('%d/%d\n',i,mtrain); %display progression
end

%%
% TEST OPTHETA ON TRAINING SET OVER Mtrain VARIATION
% Evaluate %error
% for each values of optTheta in function of mtrain values

errorTrain = zeros(size(mtrain)); % Error array on training set

disp('-----------------------');
disp('TRAINING SET');

% Go over m values
for i=1:size(optTheta,2)
    %temp values initialization
    err = 0;
    truePos = 0;
    falsePos = 0;
    trueNeg = 0;
    falseNeg = 0;
    
    disp('-----------------------');
    
    % Go over training examples
    for j=1:i+1
        %Just to avoir the case j=1:1 (i=1)
        if(j==i+1)
            break;
        end
        
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
    errorTrain(i) = 100*err/i; % formule p.17
    
    %Display results
    disp('----');
    fprintf('mtrain = %d ; error = %f\n',i,errorTrain(i));
    fprintf('False positive = %f percent\n',falsePos*100/i);
    fprintf('Precision = %f\n',double(truePos/(truePos+falsePos)));
    fprintf('False negative = %f percent\n',double(falseNeg*100/i));
    fprintf('Recall = %f\n',double(truePos/(truePos+falseNeg)));
end

%%
% MINIMIZE COST FUNCTION ON Mtrain VARIATION (size of the data set)
% Get Theta values for each mtrain values
% use fminunc (MatLab function) on the TEST SET

disp('-----------------------');
disp('TEST SET');

errorTest = zeros(size(mtrain)); % Error array on test set

%Go over m values
for i=1:size(optTheta,2)
    %temp values initialization
    err = 0;
    truePos = 0;
    falsePos = 0;
    trueNeg = 0;
    falseNeg = 0;
    
    disp('-----------------------');
    
    %Go over test set examples
    for j=1:mtest
        %Get single test example
        X_ = Xtest(j,:)';
        h = hFun(X_,optTheta(:,i)); % evaluate output

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
    %Get pourcentages
    errorTest(i) = 100*err/mtest; % formule p.17
    
    %Display results
    disp('----');
    fprintf('mtrain = %d ; error = %f\n',i,errorTest(i));
    fprintf('False positive = %f percent\n',falsePos*100/mtest);
    fprintf('Precision = %f\n',double(truePos/(truePos+falsePos)));
    fprintf('False negative = %f percent\n',double(falseNeg*100/mtest));
    fprintf('Recall = %f\n',double(truePos/(truePos+falseNeg)));
   
end

%%
% GRAPHIC RESULTS VIZUALISATION (optional)
% Plot Jtrain VS Jtest on : %error
% variation over m (size of training set)

figure('Name','mTrain variations results');

title('Jtrain VS Jtest (lambda=0)','FontSize',15);
xlabel('m training set','FontSize',15);
ylabel('error (%)','FontSize',15);
grid('on');

% Graphic % Error
hold on
plot(1:size(optTheta,2),errorTrain,'k-o');
plot(1:size(optTheta,2),errorTest,'r-x');
legend('Jtrain','Jtest');
hold off

% Save figure
savefig('mVariation_')