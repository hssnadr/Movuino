% Generate a data set based on examples store in the folder "DataCollection"
% Normalized data set
% Store normalization parameters for each features (mean and range)
% Store the data set
clearvars;

%%
% GET ROW DATAS
% corresponding to Good/Bad movements
GetDataGood; % call script
GetDataBad; % call script

%%
% COMPUTE DATA SET
mGood = size(cellAccXGood,2); % training examples Good
mBad = size(cellAccXBad,2); % training examples Bad
m = mGood + mBad; % total number of training examples
X=NaN;% data set matrix

% Go over good moves
for i=1:mGood
    % Compute data matrix with data stored in the cells
    rowDat_ = [ ...
        double(cellAccXGood{i}(:)) double(cellAccYGood{i}(:)) double(cellAccZGood{i}(:)) ...
        double(cellGyrXGood{i}(:)) double(cellGyrYGood{i}(:)) double(cellGyrZGood{i}(:)) ...
        cellTimeDataGood{i}(:)];
    
    % Compute features
    x_ = getFeatures_Evaluation(rowDat_);
    
    % Add to data set matrix
    if i==1
        X = double(x_);
    else
        X = [X ; double(x_)];
    end
end

% Go over bad moves
for i=1:mBad
    % Compute data matrix with data stored in the cells
    rowDat_ = [ ...
        double(cellAccXBad{i}(:)) double(cellAccYBad{i}(:)) double(cellAccZBad{i}(:)) ...
        double(cellGyrXBad{i}(:)) double(cellGyrYBad{i}(:)) double(cellGyrZBad{i}(:)) ...
        cellTimeDataBad{i}(:)];
    
    % Compute features
    x_ = getFeatures_Evaluation(rowDat_);
    
    % Add to data set matrix
    X = [X ; double(x_)];
end

%%
% NORMALIZE DATA SET
rangeInput = NaN(size(X,2),1);
meanInput = NaN(size(X,2),1);

% Compute normalization parameters for each features
for i=1:size(X,2)
    rangeInput(i) = max(X(:,i))-min(X(:,i));
    meanInput(i) = mean(X(:,i));
    if(rangeInput(i)~=0)
        X(:,i) = double(X(:,i) - meanInput(i))/double(rangeInput(i));
    else
        X(:,i) = 0;
    end
end

% Store normalization parameters (for futur examples evaluation)
% into folder "TrainingSetVariables"
rangeInput_Evaluation = rangeInput;
meanInput_Evaluation = meanInput;
save('TrainingSetVariables/NormalizationParameters_Evaluation.mat','rangeInput_Evaluation','meanInput_Evaluation');

%%
% SAVE DATA SET (into folder "TrainingSetVariables")
Y = [ones(mGood,1); zeros(mBad,1)]; % Ouput data of training set (supervised learning)
save('TrainingSetVariables/DataSet_Evaluation.mat','X','Y');
