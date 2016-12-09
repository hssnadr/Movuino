function splitSequence(sequenceName, frameLength)
% Split video and data sequences when too long (somtimes necessary to be
% readen by 'VisualizationVideoData.m' script
% Video file must be a .mp4 and store into 'SEQUENCES' folder
% Set the new files name as input and the number of frames expected per
% sequence
cd('SEQUENCES');

%%
% EXTRACT VIDEO

% Get video source file
videoName=char(strcat(sequenceName,'.mp4'));
vidSource = VideoReader(videoName); % Open row video file

% Get number of new files
nNewSequences = floor(vidSource.NumberOfFrames/frameLength);
nNewSequences = nNewSequences+1; % Last sequence containing remaining frames and data

% Store new sequences
for i=1:nNewSequences
    % Video file creation for the new sequence
    vidExtractName = strcat(sequenceName,'(',num2str(i),')');
    vidExtract = VideoWriter(vidExtractName,'MPEG-4'); % encode in MPEG-4
    vidExtract.FrameRate = vidSource.FrameRate; % keep video source frame rate
    open(vidExtract);
    
    % Write new sequence
    firstFrame = (i-1)*frameLength+1; % first frame of the i-th sequence
    lastFrame = i*frameLength; % last frame of the i-th sequence
    for j=firstFrame:lastFrame
        if j<=vidSource.NumberOfFrames % Check if the number of frames of the source video has not been reach
            img = read(vidSource,j); % read source frame
            writeVideo(vidExtract,img); % write new frame
            fprintf('writing frame %d / %d (sequence %d / %d) \r',j,vidSource.NumberOfFrames,i,nNewSequences);
        else
            break;
        end
    end
    fprintf('Video fully extracted (%d)\r',i);
    close(vidExtract);
end

%%
% EXTRACT DATA

% Get data source file
dataFileName=char(strcat(sequenceName,'.dat'));
dataFileSource = fopen(dataFileName,'r');

% Get configuration of the sensor
config=textscan(dataFileSource, '%s%d%d%d',1);
ref=char(config{1,1});
acc=int8(config{1,2}); % accelerometer sensibility 0=2G,1=4G,2=8G
gyr=int8(config{1,3}); % gyroscope sensibility  0=250°/s,1=500°/s,2=1000°/s
frq=int32(config{1,4}); % sampling rate in Hertz

% Get source data 
dataSource = textscan(dataFileSource, '%s%d%d%d%d%d%d%f', 'HeaderLines',1);
fclose(dataFileSource);

% Write new data files
for i=1:nNewSequences
    % Create data file
    dataExtractName = strcat(sequenceName,'(',num2str(i),')','.dat');
    dataFileExtract = fopen(dataExtractName,'w');
    
    % Write sensor configuration
    fprintf(dataFileExtract,sprintf('%s %d %d %d \n',ref,acc,gyr,frq));
    
    % Get source data limits for current sequence according to video extraction
    firstFrame = (i-1)*frameLength+1; % first frame of the i-th sequence
    lastFrame = i*frameLength; % last frame of the i-th sequence
    
    % Time value corresponding to first and last data
    dataTime_ = double(dataSource{8}); % get time reference of each source data
    t1=firstFrame/double(vidSource.FrameRate); % time corresponding to the first frame
    t2=lastFrame/double(vidSource.FrameRate); % time corresponding to the last frame
    firstRow = find(dataTime_-t1>=0 , 1);  % get data index corresponding to the time of the first frame
    if(t2<=max(dataTime_)) % check if the end of the data file has been reach
        lastRow = find(dataTime_-t2>=0 , 1); % get data index corresponding to the time of the last frame
    else
        % otherwhise take every remaining data in the data source file
        lastRow = size(dataSource{1,1},1);
        disp('data limit reached');
    end
    
    % Go over first and last row data to store them into the new data file
    for j=firstRow:lastRow
        ref = char(dataSource{1}(j,1));
        Ax = int32(dataSource{2}(j,1));
        Ay = int32(dataSource{3}(j,1));
        Az = int32(dataSource{4}(j,1));
        Gx = int32(dataSource{5}(j,1));
        Gy = int32(dataSource{6}(j,1));
        Gz = int32(dataSource{7}(j,1));
        if(i==1)
            timeData = double(dataSource{8}(j,1));
        else
            timeData = double(dataSource{8}(j,1)) - double(dataSource{8}(firstRow,1)); % be sure that each time data of every sequence start from 0
        end
        % Write row data into the file
        fprintf(dataFileExtract,sprintf('%s %d %d %d %d %d %d %f\n',ref,Ax,Ay,Az,Gx,Gy,Gz,timeData));
    end
    
    % Close new sequence data file
    fclose(dataFileExtract);
    fprintf('Data fully extracted (%d)\r',i);
end

end

