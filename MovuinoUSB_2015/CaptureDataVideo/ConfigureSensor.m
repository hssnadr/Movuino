function ConfigureSensor(acc,gyr,frq)
% Configure the sensor
% see the switch function below to see correspondance for acc (accelerometer) and gyr (gyroscope)
% Accelerometer correspondance : 0=2G,1=4G,2=8G
% Gyroscope correspondance : 0=250°/s,1=500°/s,2=1000°/s
% frq (= sampling frequence) can be enter with the expected value (ex: 60 for 60Hz)
fclose(instrfind); % avoid serial conflict

%%
% SENSOR INITIALIZATION

%User Defined Properties 
serialPort = 'COM5'; % define COM port %uncomment for Windows
% serialPort = '/dev/tty.usbmodem1411'; % uncomment for MAC
baudeRate = 38400; % serial bauderate

%Open Serial COM Port
s = serial(serialPort, 'BaudRate',baudeRate,'Terminator','LF');
fopen(s);

%%
% CONFIGURE SENSOR

disp('configuring sensor...');

%Send command to movuino
fprintf(s,'q'); % quite live mode if still running
pause(0.5);

% Set acceleration sensibility
fprintf(s,'1 %d',acc);
pause(0.1);
% Set gyroscope sensibility
fprintf(s,'2 %d',gyr);
pause(0.1);
% Set sampling rate
fprintf(s,'3 %d',frq);
pause(1);

%%
% Print new configuration with true values
trueVal = getTrueVal(acc,gyr);
fprintf('Sensor configuration : %s - %s - %dHz\n',char(trueVal(1)),char(trueVal(2)),frq);

% close serial
fclose(s);

end

function [configTrueVal] = getTrueVal(acc,gyr)
    configTrueVal = cellstr(char(zeros(2,1)));
    switch acc
        case 0
            configTrueVal{1}='2G';
        case 1
            configTrueVal{1}='4G';
        case 2
            configTrueVal{1}='8G';
        otherwise
            configTrueVal{1}='error acc';
    end
    switch gyr
        case 0
            configTrueVal{2}='250°/s';
        case 1
            configTrueVal{2}='500°/s';
        case 2
            configTrueVal{2}='1000°/s';
        otherwise
            configTrueVal{2}='error gyr';
    end
end

