function RecordWebcamNData( fileName )
% Record data from movuino and video from webcam
% Store data in 'filename'.dat
% Store video in 'filename'.mp4
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

% Create video file
if isempty(fileName)
    fileName = 'Webcam_Record';
end
vidWriter = VideoWriter(fileName,'MPEG-4'); %encode in MPEG-4

% Open video file and set framerate to 15 fps (not too much to avoid slowdown)
frmrate = 15;
vidWriter.FrameRate = frmrate;
open(vidWriter);
curFrame = 0; % initialize current frame to 0

%%
% SENSOR INITIALIZATION

%User Defined Properties 
serialPort = 'COM7'; % define COM port %uncomment for Windows
% serialPort = '/dev/tty.usbmodem1411'; % uncomment for MAC
baudeRate = 38400; % serial bauderate

%Open Serial COM Port
s = serial(serialPort, 'BaudRate',baudeRate,'Terminator','LF');
disp('Close Plot to End Session');
fopen(s);

% record variables
data_=[]; % matrix to store sensor data flow
timerVal = tic; % starts a internal stopwatch timer, get elapsed time with the toc function
delay = 0.01; %time delay between mesures (second)

%%
% RECORD

% Get sensor configuration
fprintf(s,'i'); %serial command to get sensor configuration
pause(0.2);
dat = fscanf(s); %get data from serial
dat = sscanf(dat, '%s%d%d%d%d'); %check data format
% Store data
sensorConfig_=[dat(3) dat(4) dat(5)];
ref_='i';

% Live mode command send on Movuino (to get data flow)
fwrite(s,'l');
pause(0.2);

% Record as long as the window is open
while ishandle(h)
    % CAPTURE DATA
    dat = fscanf(s); %get data from serial
    curTime = toc(timerVal); % get current time
    [dat,countSscan] = sscanf(dat, '%s%d%d%d%d%d%d'); %check the data's format
    
    % Store temporary data
    if(countSscan==7 && (dat(1)==108||dat(1)==114)) % Check format = 1 ref caractere ('l'=108 for live mode/'r'=114 for record mode) + 3*accelerometre + 3*gyroscope
        accX = dat(2); %Extract 2nd Data Element (=1st data = acceleration X)
        accY = dat(3);
        accZ = dat(4);
        gyrX = dat(5);
        gyrY = dat(6);
        gyrZ = dat(7);
        data_ = [data_ ;accX accY accZ gyrX gyrY gyrZ curTime];
        ref_=[ref_;dat(1)];
        
        pause(delay); % allow time delay
    
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
    
    % CAPTURE CURRENT FRAME    
    if(curTime >= curFrame/frmrate) % manage video / data framerate synchronization
        img = snapshot(cam); % Acquire frame for processing
        writeVideo(vidWriter, img); % Write frame to video
        
        curFrame = curFrame+1; % update current frame to the next one
    end
end

fprintf(s,'q');%Stop data sending from movuino

%%
% STORE DATA AND VIDEO

% write data_ in 'fileName'.dat file
fileID = fopen(strcat(fileName,'.dat'),'w'); %create file to store data (in case of crash)
% -> Sensor configuration
fprintf(fileID,'%s %d %d %d\n',ref_(1),sensorConfig_(1,1),sensorConfig_(1,2),sensorConfig_(1,3));
% -> Data
for k=2:length(data_)
    fprintf(fileID,'%s %d %d %d %d %d %d %f\n',ref_(k),data_(k,1),data_(k,2),data_(k,3),data_(k,4),data_(k,5),data_(k,6),data_(k,7));
end

% Close data/video files and serial
fclose(fileID);
close(vidWriter);
clear cam
fclose(instrfind);

fprintf('Video saved as %s.mp4\r', fileName);
fprintf('Data saved as %s.dat\r', fileName);

end