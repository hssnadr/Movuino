function RecordWebcamNData_Metronome( fileName )
% Record data from movuino and video from webcam
% Record invidual sequences based on a metronome (time window)
% Apply a mean average filter on data before to store them
% Store data in 'filename'_#sequence.dat
% Store video in 'filename'_#sequence.mp4
% A sound (default matlab error sound) is played at the begining of each sequence (metronome style)
% Enter the file name as input (string)

cd('SEQUENCES'); % all data files are stored into 'SEQUENCES' folder
fclose(instrfind); % close serial port to avoid problems

% Create interface
h=figure('units','pixels',...
    'position',[600 300 300 100],...
    'resize','off',...
    'color',[0.8 0.8 0.8],...
    'numbertitle','off',...
    'name','Frame visualization',...
    'menubar','none',...
    'KeyPressFcn',@keyPress,...
    'tag','interface');
uicontrol('style','text',...
    'fontSize',11,...
    'fontWeight','bold',...
    'units','pixels',...
    'position',[50 10 200 60],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'string',sprintf('Webcam recording \n Close the window to stop'));

%%
% WEBCAM INITIALIZATION

% Open webcam
cam = webcam;
disp(cam);
frmrate = 15; % Set framerate to 15 fps (not too much to avoid slowdown)

%%
% SENSOR INITIALIZATION

%User Defined Properties 
serialPort = 'COM5'; % define COM port %uncomment for Windows
% serialPort = '/dev/tty.usbmodem1411'; % uncomment for MAC
baudeRate = 38400; % serial bauderate

%Open Serial COM Port
s = serial(serialPort, 'BaudRate',baudeRate,'Terminator','LF');
disp('Close Plot to End Session');
fopen(s);

% record variables
dataCollect=[]; % matrix to store sensor data flow
dataCollect_MMean=[]; % matrix to store mean average on sensor data flow
N = 3; % range for moving average
metronomeDelay = 1.0; % duration in second of each sequence
delay = 0.01; %time delay between mesures (second)
n=0; % initialize index of current sequence
curInd = 0; % initialize data matrix index

%%
% RECORD

% Get sensor configuration
fprintf(s,'i'); %serial command to get sensor configuration
pause(0.2);
dat = fscanf(s); %get data from serial
dat = sscanf(dat, '%s%d%d%d%d'); %check data format
% Store data
sensorConfig_=[dat(3) dat(4) dat(5)];

% Live mode command send on Movuino (to get data flow)
fwrite(s,'l');
pause(0.2);

% Record as long as the window is open
while ishandle(h)
    % CREATE CURRENT SEQUENCE
    n=n+1; % update current sequence index
    
    % Manifest new sequence for user
    beep; % play sound to simulate metronome
    set(h,'color',[rand(1) rand(1) rand(1)]); % change window color on each sequence (to preview rythm while recording)
    
    % Create sequence video file
    if isempty(fileName)
        fileName = strcat('Webcam_Record',int2str(n)); % include move index in file name
    end
    vidWriter = VideoWriter(strcat(fileName,'_',int2str(n)),'MPEG-4'); % encode in MPEG-4 (.mp4)
    vidWriter.FrameRate = frmrate; % set framerate
    open(vidWriter); % open video file
    curFrame = 0; % initialize current frame to 0 for new sequence
    timerVal = tic; % starts a internal stopwatch timer
    
    %%
    % Start sequence recording
    while(toc(timerVal) <= metronomeDelay)
        pause(delay); % allow time delay between mesures

        % CAPTURE CURRENT DATA
        % Scan serial port
        dat = fscanf(s); %get data from serial
        curTime = toc(timerVal); % get current time (= time since 'tic')
        [dat,countSscan] = sscanf(dat, '%s%d%d%d%d%d%d'); %check the data's format

        % Store temporary data
        if(countSscan==7 && (dat(1)==108||dat(1)==114)) % Check format = 1 ref caractere ('l'=108 for live mode/'r'=114 for record mode) + 3*accelerometre + 3*gyroscope
            % Extract values from serial data
            accX = dat(2); %Extract 2nd Data Element (=1st data = acceleration X)
            accY = dat(3);
            accZ = dat(4);
            gyrX = dat(5);
            gyrY = dat(6);
            gyrZ = dat(7);
            
            % Store into sequence data matrix
            curInd = curInd+1;
            dataCollect(curInd,:) = [accX accY accZ gyrX gyrY gyrZ curTime]; % matrix containing sensors datas on the observation window
            
            % Apply moving average and store it into dataCollect_MMean
            if (size(dataCollect,1)>= N) % mean average if enouth data
                meanDat_ = (1/N)*sum(dataCollect(curInd-N+1:curInd,1:6)); % mean average on data (not on time)
                dataCollect_MMean(curInd,:) = [meanDat_ dataCollect(curInd,7) n]; % matrix containing filtered sensors data on the observation window
            else
                dataCollect_MMean(curInd,:) = [dataCollect(curInd,:) n];
            end
            
        % Manage serial errors    
        elseif isempty(dat)
            disp('empty dat');
        else
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

        % CAPTURE CURRENT VIDEO FRAME
        if(curTime >= curFrame/frmrate)
            img = snapshot(cam); % Acquire frame for processing
            writeVideo(vidWriter, img); % Write frame to video
            curFrame = curFrame+1; % update current frame to the next one
        end
    end
    
    % Store mean data in cells : cellData_MMean{n,:} correspond to the data of the n-th sequence
    if(~isempty(dataCollect_MMean))
        curMovRow = find(dataCollect_MMean(:,8)==n); % find the rows corresponding to the current sequence (number n)
        cellData_MMean{n,1} = dataCollect_MMean(curMovRow,1); %AccX
        cellData_MMean{n,2} = dataCollect_MMean(curMovRow,2); %AccY
        cellData_MMean{n,3} = dataCollect_MMean(curMovRow,3); %AccZ
        cellData_MMean{n,4} = dataCollect_MMean(curMovRow,4); %GyrX
        cellData_MMean{n,5} = dataCollect_MMean(curMovRow,5); %GyrY
        cellData_MMean{n,6} = dataCollect_MMean(curMovRow,6); %GyrZ
        cellData_MMean{n,7} = dataCollect_MMean(curMovRow,7)-dataCollect(curMovRow(1),7); %Time
    end
    
    % Store video file
    close(vidWriter);
    
    fprintf('sequence num. %d\n',n) % display progression
end

fprintf(s,'q');%Stop data sending from movuino

%%
% STORE DATA AND VIDEO
disp('writing data...');
for i=1:n % store each sequences individualy
    % write data_ in 'fileName'.dat file
    fileID = fopen(strcat(fileName,'_',int2str(i),'.dat'),'w'); % sequence data file creation
    % -> sensor configuration
    fprintf(fileID,'%s %d %d %d\n','i',sensorConfig_(1,1),sensorConfig_(1,2),sensorConfig_(1,3));
    % -> data
    for k=1:length(cellData_MMean{i,1}) % write datas into the file
        fprintf(fileID,'%s %d %d %d %d %d %d %f\n','l', ...
            cellData_MMean{i,1}(k), ...
            cellData_MMean{i,2}(k), ...
            cellData_MMean{i,3}(k), ...
            cellData_MMean{i,4}(k), ...
            cellData_MMean{i,5}(k), ...
            cellData_MMean{i,6}(k), ...
            cellData_MMean{i,7}(k));
    end
    fclose(fileID); % close data file
end

%%
% Close webcam and serial
clear cam
fclose(instrfind);

fprintf('Video saved as %s.mp4\r', fileName);
fprintf('Data saved as %s.dat\r', fileName);

end