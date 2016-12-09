function VisualizationVideoData
% Display video and data store into 'SEQUENCES' folder
% Sorry it's written in French

% Creation GUI
% Création de l'objet Figure
figure('units','pixels',...
    'position',[50 100 1175 500],...
    'color',[0.8 0.8 0.8],...
    'numbertitle','off',...
    'name','Frame visualization',...
    'menubar','none',...
    'KeyPressFcn',@keyPress,...
    'tag','interface');

% Recherche des séquences disponibles
cd('SEQUENCES') %change current directory
listVideo=dir('*.mp4*'); % returns the list of video file name in the Data directory
listSequence = cell(length(listVideo),1);
for k=1:length(listVideo)
    split = strsplit(listVideo(k).name,'.'); % split sur l'extension
    listSequence(k) = split(1);
end

% Popup Menu pour choisir la séquence
% SELECT SEQUENCE texte
uicontrol('style','text',...
    'units','pixels',...
    'position',[280 432 110 25],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'string','Select sequence:');
uicontrol('Style', 'popup',...
    'units','pixels',...
    'String', listSequence,...
    'Position', [400 410 300 50],...
    'tag','menu_SlctSeq',...
    'Callback', @loadSequence);
% Création de l'indication
% Use left and right arrows
uicontrol('style','text',...
    'units','pixels',...
    'BackgroundColor',[0 1 0],...
    'position',[5 415 220 30],...
    'string',sprintf('Use left and right arrows \n to navigate through the sequence'),...    
    'callback',@prevFrame,...
    'tag','btn_prevFrame');
% Zone d'affichage de la video
axes('units','pixels',...
    'Position',[5,25,500,350],...
    'tag','axeVideoFrame');
% axis off;
% Zone d'affichage des data
axes('units','pixels',...
    'Position',[600,50,550,300],...
    'tag','axeData');
axis on;

% Popup Menu pour choisir les data à afficher
uicontrol('Style', 'popup',...
    'units','pixels',...
    'String', {' Acceleration',' Gyroscope', ...
        ' Acc globale',' Gyr global',' Gyro filtered', ...
        'GyrYZGlobale','Vitesse linéaire','PositionXYZ'},...
    'Position', [815 330 120 50],...
    'tag','menu_selectdata',...
    'Callback', @selectNdisplayData);

lBut=110;
hBut=25;
% Création de l'objet Uicontrol UNZOOM DATA GRAPH
uicontrol('style','pushbutton',...
    'units','pixels',...
    'position',[1040 356 lBut hBut],...
    'string','Unzoom graphic',...    
    'callback',@unzoomDataGraph,...
    'tag','unzoom_data');

% Création de l'objet Uicontrol text CURRENT FRAME
% Current frame :
uicontrol('style','text',...
    'units','pixels',...
    'position',[3*lBut 0 lBut hBut*0.75],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'string','Current frame: ');
uicontrol('style','text',...
    'units','pixels',...
    'position',[4*lBut 0 lBut/2 hBut*0.75],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'string','',... % A modifier apres
    'tag','curFrmDspl');
%idem pour les valeurs des datas sous le graphique
uicontrol('style','text',...
    'units','pixels',...
    'position',[600 0 550 hBut*0.75],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'string','',...
    'tag','tx_dataVal');

% Création des contrôles pour l'extraction de séquences
% SAVE AS
uicontrol('style','text',...
    'units','pixels',...
    'position',[0 355+hBut lBut/2 hBut*0.75],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'string','Save as');
% SEQUENCE NAME edit
uicontrol('style','edit',...
    'units','pixels',...
    'position',[lBut/2 355+hBut 1.5*lBut hBut],...
    'BackgroundColor',[1 1 1],...
    'string','sequence_name',...
    'tag','edit_seqName');
% from frame
uicontrol('style','text',...
    'units','pixels',...
    'position',[2*lBut 355+hBut lBut/2 hBut*0.75],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'string','from frame');
% FIRST FRAME edit
uicontrol('style','edit',...
    'units','pixels',...
    'position',[5+2.5*lBut 355+hBut lBut/3 hBut],...
    'BackgroundColor',[1 1 1],...
    'string','1',...
    'tag','edit_fromFrm');
% to
uicontrol('style','text',...
    'units','pixels',...
    'position',[5+(2.5+1/3)*lBut 355+hBut lBut/5 hBut*0.75],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'string','to');
% TO FRAME edit
uicontrol('style','edit',...
    'units','pixels',...
    'position',[5+(2.7+1/3)*lBut 355+hBut lBut/3 hBut],...
    'BackgroundColor',[1 1 1],...
    'string','100',...
    'tag','edit_toFrm');
% EXTRACT button
uicontrol('style','pushbutton',...
    'units','pixels',...
    'position',[10+(2.7+2/3)*lBut 355+hBut 1.1*lBut hBut],...
    'string','Extract sequence',...  
    'callback',@extractSequence,...
    'tag','btn_extrSeq');

% Génération de la structure contenant les identifiants des objects graphiques dont la 
% propriété Tag a été utilisée.
dataHandle=guihandles(gcf);
disp(dataHandle)
% Enregistrement de data dans les données d'application de l'objet Figure
guidata(gcf,dataHandle);

%%

% Chargement de la video initiale (=premiere de la liste récupérée)
valSeq=get(findobj('tag','menu_SlctSeq'),'Value');
strSeq=get(findobj('tag','menu_SlctSeq'),'String');
loadVideoFile(strSeq(valSeq));
% Chargement des données corrspondantes
loadDataFile(strSeq(valSeq));

% Affichage de la premiere frame de la video initiale
displayCurrentFrame(1);

% Chargement et affichage des data "initiale" (normalement : Accelerometre)
selectNdisplayData(findobj('Style', 'popup',...
    'tag','menu_selectdata'),[],'menu_selectdata');

end

function loadVideoFile(fileName)
% Charge le fichier video contenu dans le dossier SEQUENCES
% dont le nom correspond à la valeur d'entrée 'fileName'(.mp4)

%Récupération du fichier vidéo
seqVideoName=char(strcat(fileName,'.mp4'));
disp(seqVideoName);
vid = VideoReader(seqVideoName);
frmrt = vid.FrameRate; %frame rate of video file
vidWidth = vid.Width;
vidHeight = vid.Height;

%Create a movie structure array
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),'colormap',[]);

%Lecture de la video et stockage dans mov
for i=1:vid.NumberOfFrames
% for i=1:20 % uncomment for debug
    mov(i).cdata = read(vid,i);
    fprintf('loading frame %d / %d \r',i,vid.NumberOfFrames)
end

% Initialisation de la variable représentant la valeur courante de l'index
% curFrame à 1
curFrame=1;

% Sauvegarde des données receuillies dans les data de l'application
setappdata(gcf,'current_frame',curFrame);
setappdata(gcf,'filevideo',vid);
setappdata(gcf,'movie',mov);
setappdata(gcf,'frame_rate_video',frmrt);
end

function loadDataFile(fileName)
% Charge le fichier data contenu dans le dossier SEQUENCES
% dont le nom correspond à la valeur d'entrée 'fileName'(.dat)
seqDataName=char(strcat(fileName,'.dat'));
fid = fopen(seqDataName,'r');

%Get configuration of the sensor
config=textscan(fid, '%*s%d%d%f',1);
disp(config)
acc=config{1,1}; %0=2G,1=4G,2=8G
gyr=config{1,2}; %0=250°/s,1=500°/s,2=1000°/s
frq=config{1,3}; %valeur en Hz

%Get Datas
rowData = textscan(fid, '%*s%d%d%d%d%d%d%f', 'HeaderLines',1); %skip the reference letter
fclose(fid);

% Sauvegarde des données receuillies dans les data de l'application
setappdata(gcf,'echantillonage',frq);
setappdata(gcf,'rowData',rowData);
end

function displayCurrentFrame(n)
% Affiche la frame en cours de la vidéo
% Recuperation de l'axe d'affichage des frames
%Recuperation des data nécessaires stockée dans l'objet Figure (gcf)
m_=getappdata(gcf,'movie');

% Selection de l'axe correspondant à la zone d'affichage de la video
dataHandle=guidata(gcf);
ax=dataHandle.axeVideoFrame;
axes(ax)

% Affichage de la frame
if n>0 && n<=length(m_)
    %Affichage de la frame
    image(m_(n).cdata)
    axis off
end

% Affichage de la frame en cours dans la zone de texte sous la video
set(dataHandle.curFrmDspl,'string',n);

% Enregistrement de la nouvelle valeur de la frame en cours dans les
% données d'application de l'objet Figure
setappdata(gcf,'current_frame',n);
end

function selectNdisplayData(obj,event,handles)
% Rempli le tableau des data à partir des data bruts (rowData)
% en fonction du menu popup de selection 'selectData'

% Chargement des data bruts
rowDat_=getappdata(gcf,'rowData');

val = get(obj,'Value');
val(1)
str = get(obj,'String');
disp(str{val}) % Control de la valeur recuperee dans la command window
switch val
    case 1 % Accelerometre
        data=[rowDat_{1},rowDat_{2},rowDat_{3}];
        nameData=cellstr(['Ax';'Ay';'Az']);
        unitData='g';
    case 2 % Gyrosocpe
        data=[rowDat_{4},rowDat_{5},rowDat_{6}];
        nameData=cellstr(['Gx';'Gy';'Gz']);
        unitData='°/s';
    case 3 % Acceleration globale
        data=[sqrt(double(rowDat_{1}.^2 + rowDat_{2}.^2 + rowDat_{3}.^2))];
        nameData=cellstr(['AccGlobale']);
        unitData='g';
    case 4 % Gyroscope globale
        data=[sqrt(double(rowDat_{4}.^2 + rowDat_{5}.^2 + rowDat_{6}.^2))];
        nameData=cellstr(['GyrGlobale']);
        unitData='°/s';
    case 5 % Gyro filtered
        % Compute accelerometer magnitude
        acc_mag = [sqrt(double(rowDat_{4}.^2 + rowDat_{5}.^2 + rowDat_{6}.^2))];
        
        samplePeriod = 1/60; % A CHANGER (Adrien)

        % HP filter accelerometer data
        filtCutOff = 0.001;
        [b, a] = butter(1, (2*filtCutOff)/(1/samplePeriod), 'high');
        acc_magFilt = filtfilt(b, a, acc_mag);

        % Compute absolute value
        acc_magFilt = abs(acc_magFilt);

        % LP filter accelerometer data
        filtCutOff = 5;
        [b, a] = butter(1, (2*filtCutOff)/(1/samplePeriod), 'low');
        acc_magFilt = filtfilt(b, a, acc_magFilt);
        data=acc_magFilt;

        % Threshold detection
%         data= acc_magFilt < 0.05;
        nameData=cellstr(['Stationary']);
        unitData='';
    case 6 % Gyroscope globale
        data=[sqrt(double(rowDat_{5}.^2 + rowDat_{6}.^2))];
        nameData=cellstr(['GyrYZGlobale']);
        unitData='°/s';
    case 7 % Integrale Acceleration
        data = NaN(length(rowDat_{1}),3);
        for k=1:length(rowDat_{1})
            data(k,:) = [sum(double(rowDat_{1}(1:k))) ...
                sum(double(rowDat_{2}(1:k))) ...
                sum(double(rowDat_{3}(1:k)))];
        end
        nameData=cellstr(['Vx';'Vy';'Vz']);
        unitData='';
    case 8 % Double Integrale Acceleration
        data0 = NaN(length(rowDat_{1}),3);
        data = NaN(length(rowDat_{1}),3);
        for k=1:length(rowDat_{1})
            data0(k,:) = [sum(double(rowDat_{1}(1:k))) ...
                sum(double(rowDat_{2}(1:k))) ...
                sum(double(rowDat_{3}(1:k)))];
            data(k,:) = [sum(double(data0(1:k,1))) ...
                sum(double(data0(1:k,2))) ...
                sum(double(data0(1:k,3)))];
        end
        nameData=cellstr(['X';'Y';'Z']);
        unitData='';
        
    otherwise
        warning('data not defined');
end

dataTime=[rowDat_{7}];

% Sauvegarde des données receuillies dans les data de l'application
setappdata(gcf,'data',data); % données qui vont etre affichees
setappdata(gcf,'dataTime',dataTime); % référence temps des datas
setappdata(gcf,'Name_Data',nameData); % nom des données qui vont etre affichees
setappdata(gcf,'Unit_Data',unitData); % unités des données qui vont etre affichees

displaySelectData;

end

function displaySelectData
dataHandle=guidata(gcf);
dat_=getappdata(gcf,'data');
datTime_=getappdata(gcf,'dataTime');
% frq_=getappdata(gcf,'echantillonage');

% Reset du graph des data
cla(dataHandle.axeData,'reset');

% Set current axe and resize to see entire data
axes(dataHandle.axeData);
set(dataHandle.axeData,'XLimMode','auto','YLimMode','auto');

if ~isempty(length(dat_))
    %Prepare plot
%     n=1:length(dat_);
    col=char('green','red','blue');
    %add title, label ...
    
    hold on
    for i=1:size(dat_,2)
%         plot(n/frq_,dat_(:,i),'color',col(i))
        plot(datTime_,dat_(:,i),'color',col(i))
    end
    hold off
else
    disp('No data')
end

% Affichage de la ligne repere de l'instant t sur le graph des data
frmrt_=getappdata(gcf,'frame_rate_video');
curFrame=getappdata(gcf,'current_frame');
t=curFrame/frmrt_;
rpr=line([t,t],get(dataHandle.axeData,'ylim'),'Color',[0 0 0]);
setappdata(gcf,'repere',rpr);

% Affichage des valeurs numériques des datas (sous le graph)
diplayCurrentNumericData

end

function keyPress(fig_obj,eventDat)
% disp(['You just pressed: ' eventDat.Key]);

% Chargement des données necessaires
curFrame=getappdata(gcf,'current_frame');
v_=getappdata(gcf,'filevideo');

switch eventDat.Key
    case 'rightarrow'
        if curFrame<=v_.NumberOfFrames
            curFrame=curFrame+1;
        else
            disp('max range video')
        end
    case 'leftarrow'
        if curFrame>1
            curFrame=curFrame-1;
        else
            disp('min range video')
        end
end

% Appel l'affichage de la nouvelle frame
displayCurrentFrame(curFrame);
% Zoom du graphique des datas sur la zone temporelle en cours
graphFollowData
% Appel de l'affichage numériques des datas correspondant à la frame en cours
diplayCurrentNumericData;
end

function diplayCurrentNumericData
curFrame=getappdata(gcf,'current_frame');
frmrt_=getappdata(gcf,'frame_rate_video');
% frq_=getappdata(gcf,'echantillonage');
dat_=getappdata(gcf,'data');
dataTime_=getappdata(gcf,'dataTime');
nameData_=getappdata(gcf,'Name_Data');
unitData_=getappdata(gcf,'Unit_Data');
dataHandle=guidata(gcf);

% Actualisation de l'affichage numérique des données sous le graph
t=curFrame/frmrt_;% temps en seconde correspondant à la frame en cours

if(t<=max(dataTime_))
    k = find(dataTime_-t>=0 , 1); % renvoie l'index des data correspondant au temps calculé depuis la frame de la vidéo
    tData = dataTime_(k);
    str = sprintf('index data = %d  ;  t = %6.2f s',k,tData);
    for i=1:size(dat_,2)
        str = strcat(str, sprintf('  ;  %s = %6.1f %s',nameData_{i},dat_(k,i),unitData_));
    end
    set(dataHandle.tx_dataVal,'string', str);
end
end

function graphFollowData
% Zoom du graphique des datas pour mieux suivre leur evolution
curFrame=getappdata(gcf,'current_frame');
frmrt_=getappdata(gcf,'frame_rate_video');
frq_=getappdata(gcf,'echantillonage');
dat_=getappdata(gcf,'data');
dataTime_=getappdata(gcf,'dataTime');
dataHandle=guidata(gcf);

d=1; % demi fourchette en secondes de l'affichage des données
t=curFrame/frmrt_;% temps en seconde correspondant à la frame en cours
if(t<=max(dataTime_))
    k = find(dataTime_-t>=0 , 1); % renvoie l'index des data correspondant au temps calculé depuis la frame de la vidéo
    tData = dataTime_(k);
else
    % s'il n'y a plus de data
    k=int32(t*frq_);% index de la table des datas correspondant à la frame en cours
    tData = t; % fake mais ça évite que ça plante
    disp('max range data');
end

if length(dat_)>2*d*frq_ % zoom uniquement si la longueur de la séquence est supérier à 2*d (2 secondes)
    if k>d*frq_ && k+d*frq_<length(dat_) % vers le milieu du graph
        D=zeros(2*d*frq_+1,size(dat_,2)); %vecteur recevant l'ensembles des datas de l'interval observé 
        for i=1:size(dat_,2)
            D(:,i)=dat_(k-d*frq_:k+d*frq_,i);
        end
    elseif k+d*frq_>=length(dat_) % quand on s'approche de la fin du graph
        D=zeros(length(dat_)-(k-d*frq_)+1,size(dat_,2)); %vecteur recevant l'ensembles des datas de l'interval observé 
        for i=1:size(dat_,2)
            D(:,i)=dat_(k-d*frq_:length(dat_),i);
        end
    else % quand on est au tout début du graph
        D=zeros((k+d*frq_-1)+1,size(dat_,2)); %vecteur recevant l'ensembles des datas de l'interval observé 
        for i=1:size(dat_,2)
            D(:,i)=dat_(1:k+d*frq_,i);
        end
    end
    set(dataHandle.axeData,'XLimMode','manual','YLimMode','manual');
    if ~isempty(D) % peut arriver si le décalage entre la fin de la vidéo et des données > 2*d
        minD=min(min(D));
        maxD=max(max(D));
        set(dataHandle.axeData,'XLim',[t-d t+d],'YLim',[-1.1*sign(minD)*minD 1.1*sign(maxD)*maxD]);
    end
end

% Actualisation de la position du repere sur le graphique des data
r_=getappdata(gcf,'repere');% pointeur des données
set(r_,'XData',[tData,tData],'YData',get(dataHandle.axeData,'ylim'));

end

function extractSequence(obj,event)
% Extrait une sequence de la video en cours et de ses datas
% indiquer un nom, exemple : "maingauche_directgauche_bon"
% indiquer la frame de la video correspondant au début de la sequence a extraire
% indiquer la frame de la video correspondant à la fin de la sequence a extraire
m_=getappdata(gcf,'movie');
dataTime_=getappdata(gcf,'dataTime');
frmrt_=getappdata(gcf,'frame_rate_video');
dataHandle=guidata(gcf);

% Récupere le texte inscrit par l'utilisateur pour le nom de la sequence
% Genere le nom des fichiers : NameSequence_FirstFrame_LastFrame
fileName=strcat(get(dataHandle.edit_seqName,'string'),...
    '_',...    
    get(dataHandle.edit_fromFrm,'string'),...
    '_',...
    get(dataHandle.edit_toFrm,'string'));

%%
% Extraction video

% Creation d'un fichier vidéo vide
vidExtract = VideoWriter(strcat(fileName,'.mp4'),'MPEG-4');
vidExtract.FrameRate = frmrt_;
open(vidExtract);

% Ecriture de la sequence extraite
fromFrame=str2num(get(dataHandle.edit_fromFrm,'string'));
toFrame=str2num(get(dataHandle.edit_toFrm,'string'));
for k = fromFrame:toFrame
   writeVideo(vidExtract,m_(k).cdata);
   fprintf('writing frame %d / %d \r',k-fromFrame,toFrame-fromFrame)
end

close(vidExtract);

%%
% Extraction data
% Recuperation de la sequence en cours du menu pop up SelectSequence
val = get(findobj('tag','menu_SlctSeq'),'Value');
oldListSequence = get(findobj('tag','menu_SlctSeq'),'String');

%Récupération des datas du fichiers .dat correspondant
seqDataName=char(strcat(oldListSequence(val),'.dat'));
fid = fopen(seqDataName,'r'); % ajouter un get current file name
fileID = fopen(strcat(char(fileName),'.dat'),'w'); %create file to store data (in case of crash)

%Get configuration of the sensor
config=textscan(fid, '%s%d%d%d',1);
% disp(config)
ref=char(config{1,1});
acc=int8(config{1,2}); %0=2G,1=4G,2=8G
gyr=int8(config{1,3}); %0=250°/s,1=500°/s,2=1000°/s
frq=int32(config{1,4}); %valeur en Hz

% Ecriture de la configuration du capteur
fprintf(fileID,sprintf('%s %d %d %d \n',ref,acc,gyr,frq));

% Recuperation des valeurs des datas correspondant aux frames definies
A = textscan(fid, '%s%d%d%d%d%d%d%f', 'HeaderLines',1);

t1=fromFrame/frmrt_; % temps en seconde correspondant à la première frame
t2=toFrame/frmrt_; % temps en seconde correspondant à la dernière frame
if(t1<=max(dataTime_) && t2<=max(dataTime_))
    fromIndex = find(dataTime_-t1>=0 , 1); % renvoie l'index des data correspondant au temps calculé depuis la frame de la vidéo
    toIndex = find(dataTime_-t2>=0 , 1); % renvoie l'index des data correspondant au temps calculé depuis la frame de la vidéo
else
    warning('! OUT OF DATA RANGE !');
end

for k=fromIndex:toIndex
    ref = char(A{1}(k,1));
    Ax = int32(A{2}(k,1));
    Ay = int32(A{3}(k,1));
    Az = int32(A{4}(k,1));
    Gx = int32(A{5}(k,1));
    Gy = int32(A{6}(k,1));
    Gz = int32(A{7}(k,1));
    timeData = double(A{8}(k,1)) - double(A{8}(fromIndex,1)); % on retranche le temps correspondant à la première mesure pour récupérer une origine temps = 0
    % Ecriture des data dans le fichier
    fprintf(fileID,sprintf('%s %d %d %d %d %d %d %f\n',ref,Ax,Ay,Az,Gx,Gy,Gz,timeData));
end

fclose(fileID);
fclose(fid);

%%
% Ajout de la nouvelle séquence dans la liste du menu pop up SELECT SEQUENCE

% Creation d'une nouvelle liste a afficher par le menu_SlctSeq en rajoutant
% une ligne a l'ancienne liste
newListSequence = cell(length(oldListSequence)+1,1);

% Re referencement des anciennes sequences disponibles (qui sont toujours là)
for k=1:length(newListSequence)-1
    newListSequence(k) = oldListSequence(k);
end
% Referencement de la nouvelle sequence
newListSequence(size(newListSequence,1)) = {fileName};

% Remplacement de la liste affichee par le menu menu_SlctSeq
set(dataHandle.menu_SlctSeq,'string',newListSequence);

end

function loadSequence(obj,event,handles)
% Charge la sequence selectionnee : Video + Data
% a partir du menu popup menu_SlctSeq

mov_=getappdata(gcf,'movie');
mov_=[];
setappdata(gcf,'movie',mov_);

% Recupere le nom de la sequence
valSeq=get(obj,'Value');
strSeq=get(obj,'String');
newSequence = strSeq(valSeq);

% Chargement de la video de la nouvelle sequence
loadVideoFile(newSequence);
% Chargement des data de la nouvelle sequence
loadDataFile(newSequence);

% Affichage de la premiere frame de la nouvelle sequence
displayCurrentFrame(1);

% Chargement et affichage des nouvelle data
selectNdisplayData(findobj('Style', 'popup',...
    'tag','menu_selectdata'),[],'menu_selectdata');

end

function unzoomDataGraph(obj,event)
% Affiche le graphique des data sur l'ensemble de la sequence
displaySelectData
end