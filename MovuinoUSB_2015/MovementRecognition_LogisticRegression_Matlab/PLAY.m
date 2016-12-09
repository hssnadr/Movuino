%REAL TIME MOVEMENTS EVALUATION
%based on the model compute by the logistic regression algorithm

%%
% Create window and UI
h=figure('units','pixels',...
    'position',[600 300 300 100],...
    'resize','off',...
    'color',[0.8 0.8 0.8],...
    'numbertitle','off',...
    'name','Frame visualization',...
    'menubar','none',...
    'tag','interface');
uicontrol('style','text',...
    'fontSize',11,...
    'fontWeight','bold',...
    'units','pixels',...
    'position',[50 10 200 60],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'string',sprintf('MY FISTS BLEED DEATH \n Close the window to stop'));
disp('Close Plot to End Session'); %application is running while the window is open

%%
% MANAGE SERIAL

%close open serials
if(~isempty(instrfind('Status','open')))
    fclose(instrfind);
end

%Search for the good serial
% serialPort = 'COM5';% define COM port # %uncomment for Windows
serialPort = '/dev/tty.usbmodem1421'; % uncomment for MAC

%Serial parameter
baudeRate = 38400;
s = serial(serialPort, 'BaudRate',baudeRate,'Terminator','LF');

%Open serial
fopen(s);

%%
% INITIALIZE CAPTURE

% Get logistic regression model parameters
addpath('TrainingSetVariables');%all data compute by the logistic regression store in folder "TrainingSetVariables"
load('optTheta_Evaluation.mat'); %load optTheta_Evaluation variable
load('NormalizationParameters_Evaluation.mat'); %meanInput_Evaluation and rangeInput_Evaluation
load('Ureduce_Evaluation.mat'); %Ureduce_Evaluation

% Real time parameters
delay = 0.01; % delay between each row from the sensor
sizeDataWindow = 8; % number of data store at each moment
timerVal = tic; % starts a internal stopwatch timer

% Moving average Data matrix parameters
N = 3; % range for moving average
dataCollect = NaN(N,7); % matrix containing sensors datas to compute moving average
dataCollect_MMean = NaN(sizeDataWindow,7); % matrix containing sensors moving average datas on the observation window

% Send command to sensor (l = Live mode)
fwrite(s,'l');
pause(0.2);

%%
% REAL TIME CAPTURE

% capture is running while the window is open
while(ishandle(1))
    
    pause(delay); % allow time delay between measures
    % Re-send the live mode command each time (sensor problem)
    fwrite(s,'l');
    
    % Scan serial port
    dat = fscanf(s); %get data from serial
    curTime = toc(timerVal); % get current time
    [dat,countSscan] = sscanf(dat, '%s%d%d%d%d%d%d'); %check the data's format('%s'=string, '%d'=integer)
    
    % Data format verification before manipulation
    if(countSscan==7 && (dat(1)==108||dat(1)==114)) % 7 = 1 ref caractere ('l'=108/'r'=114) + 3*accelerometre + 3*gyroscope
        % Extract values from serial data
        accX = dat(2); %Extract 2nd Data Element (=1st data = acceleration X)
        accY = dat(3);
        accZ = dat(4);
        gyrX = dat(5);
        gyrY = dat(6);
        gyrZ = dat(7);
        % Store into data window matrix
        dataCollect = [dataCollect(2:end,:) ; accX accY accZ gyrX gyrY gyrZ curTime];
        
        % Moving average (store into dataCollect_MMean)
        if (isempty(dataCollect(isnan(dataCollect)))) % mean average if enough data
            meanDat_ = (1/N)*sum(dataCollect(:,1:6)); % mean average on data (not on time)
            dataCollect_MMean = [dataCollect_MMean(2:end,:) ; meanDat_ dataCollect(end,7)]; % matrix containing filtered sensors datas on the observation window
        end
        
        % Movement Evaluation (on dataCollect_MMean)
        if (isempty(dataCollect_MMean(isnan(dataCollect_MMean)))) % if there's no more NaN (dataCollect is full) the window is evaluated
            % Get features
            X = getFeatures_Evaluation(dataCollect_MMean)';
            
            % Features normalization based on parameters of the model
            Xnorm = (X - meanInput_Evaluation)./double(rangeInput_Evaluation);
            Xnorm(isnan(Xnorm)| isinf(Xnorm)) = 0; % avoid infinite case (when rangeInput=0)
            
            %Features reduction
            Z = Ureduce_Evaluation'*Xnorm;
            Z = [1;Z]; %add bias units
            
            % Output estimation
            h = sigmoid(optTheta_Evaluation'*Z);
            disp(h);
            if(h >= 0.4)
                fprintf('---------- BON h = %f\r',h);
                beep;
                dataCollect(:) = NaN; % dataCollect reset
                dataCollect_MMean(:) = NaN; % dataCollect reset
            end
        end
        
    elseif isempty(dat) % manage case when serial response is empty
    	disp('empty dat');
        
    else % manage specific case (cf. sensor)
        if(dat(1)==77)%'M'=77(ASCII)
            disp('err data M');
        end
        if(dat(1)==76)%'L'=76(ASCII)
            disp('ERROR --> session terminated');
            fprintf(s,'q');%Stop data sending from movuino
            pause(0.2);
            break;
        end
    end
end

%%
% CLOSE SESSION

fprintf(s,'q');% Stop data sending from movuino
fclose(instrfind); % close serial port

disp('YOU MUST DEFEAT SHENG LONG TO STAND A CHANCE');