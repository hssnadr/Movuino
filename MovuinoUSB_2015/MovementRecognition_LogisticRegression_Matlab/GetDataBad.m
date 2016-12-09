% Get datas of each movement stored in "DataCollection" defined as Bad
% generate cells containing all movements store individually
% each cell correspond to a precise row data :
% AccX / AccY / AccZ / GyrX / GyrY / GyrZ / Time

%%
% GET FILES
cd('DataCollection');
listDataFileBad= [dir('*letter*') ; dir('*NoM*')]; %get filenames corresponding to bad moves
dataSetLength=length(listDataFileBad);
%%
% CELLS GENERATION
% Go over files
for n=1:length(listDataFileBad)

    dataFileName=char(listDataFileBad(n).name);
    fid = fopen(dataFileName,'r'); % start read

    %Get configuration of the sensor
    config=textscan(fid, '%*s%d%d%f',1);
    acc=config{1,1}; %0=2G,1=4G,2=8G
    gyr=config{1,2}; %0=250°/s,1=500°/s,2=1000°/s
    frq=config{1,3}; %valeur en Hz

    %Get Datas
    rowData = textscan(fid, '%*s%d%d%d%d%d%d%f', 'HeaderLines',1); %skip the reference letter
    timeWindow = 0.5; % Time interval where we're looking for movement detection
    k = find(rowData{7} >= timeWindow , 1); % Corresponding index
    k = 3;
    
    if length(rowData{1})<=k
        k = length(rowData{1});
    end
    AccX = rowData{1}(1:k);
    AccY = rowData{2}(1:k);
    AccZ = rowData{3}(1:k);
    GyrX = rowData{4}(1:k);
    GyrY = rowData{5}(1:k);
    GyrZ = rowData{6}(1:k);
    timeDataBad = rowData{7}(1:k);
    fclose(fid);

    % Store data in cells
    cellAccXBad{n} = AccX;
    cellAccYBad{n} = AccY;
    cellAccZBad{n} = AccZ;
    cellGyrXBad{n} = GyrX;
    cellGyrYBad{n} = GyrY;
    cellGyrZBad{n} = GyrZ;
    cellTimeDataBad{n} = timeDataBad;

end

cd('../');