# Capture data and video
Use those Matlab scripts to record, manipulate and visualize data stream from the Movuino simultaneously with video (from webcam)

#### Folder 'SEQUENCES'
Store data and video recording to be manipulate by the different scripts

#### ConfigureSensor.m (optional)
Permits to configure the sensibility of the accelerometer and the gyroscope of the Movuino. It also configures the sampling rate.

#### RecordData.m
Record data from Movuino in live mode into a single file (name with the input string)

#### RecordWebcamNData.m
Record data from Movuino in live mode and the webcam video stream in the same time. Store them into two files (name with the input string) :
- 1 video file (.mp4)
- 1 data file (.dat) 

#### RecordWebcamNData_Metronome.m
Record data from Movuino in live mode and the webcam video stream in the same time. Store them into several files based on a time window (cf : 'metronome' recording) :
- 1 video file (.mp4) per sequence
- 1 data file (.dat) per sequence 

#### splitSequence.m
Split long recording into several small ones (just enter the name of the new sequence files and the maximum number of video frames)

#### VisualizationVideoData.m
Permits to visualize data and video recorded streams when there's both a video and a data file (must have the same name).
- navigate through sequences with the top pop-up menu
- navigate through data with the pop-menu at the right (note that you can add as data type as you want by adding row and manipulating data in consequence -> see selectNdisplayData function and the ui control tag 'menu_selectdata' in the script)
- extract sequences by entering the first and the last frame of the desire sequence 


soon : VisualizationData.m
