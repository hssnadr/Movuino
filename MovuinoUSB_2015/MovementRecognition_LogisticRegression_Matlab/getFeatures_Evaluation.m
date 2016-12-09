function [ Xoutput ] = getFeatures_Evaluation( rowData )
% Compute features of a data sequence corresponding to one move
% Compute derived data (derived curves) based on row data
% Slice each data curve to get series of point from each ones
% Return a row vector of all features
addpath('MathFunctions');

% Get datas
n = size(rowData,1);
accX = rowData(:,1);
accY = rowData(:,2);
accZ = rowData(:,3);
gyrX = rowData(:,4);
gyrY = rowData(:,5);
gyrZ = rowData(:,6);
time = rowData(:,7) - rowData(1,7); % Time origin (if it's not already the case)

%%
% COMPUTE DERIVED CURVES
% integral, double integral, derivative, double derivative

% Compute time ingral (only to get others integral)
integralData = NaN(n,6);
timeIntegral = time(1);
for k=2:n
    timeIntegral(k)=time(k)-time(k-1);
end

% Compute data integral (Speed X, Y,Z & Angle X,Y,Z)
for k=1:n
    integralData(k,:) = [sum(double(accX(1:k)).*timeIntegral(1:k)') ...
        sum(double(accY(1:k)).*timeIntegral(1:k)') ...
        sum(double(accZ(1:k)).*timeIntegral(1:k)') ...
        sum(double(gyrX(1:k)).*timeIntegral(1:k)') ...
        sum(double(gyrY(1:k)).*timeIntegral(1:k)') ...
        sum(double(gyrZ(1:k)).*timeIntegral(1:k)')];
end

% Compute data double integral (Position X,Y,Z)
doubleIntegralData = NaN(n,6);
for k=1:n
    doubleIntegralData(k,:) = [sum(integralData(1:k,1).*timeIntegral(1:k)') ...
        sum(integralData(1:k,2).*timeIntegral(1:k)') ...
        sum(integralData(1:k,3).*timeIntegral(1:k)') ...
        sum(integralData(1:k,4).*timeIntegral(1:k)') ...
        sum(integralData(1:k,5).*timeIntegral(1:k)') ...
        sum(integralData(1:k,6).*timeIntegral(1:k)')];
end

% Compute data derivate
derivData = NaN(n,6);
for k=1:n
    if k==1
        derivData(k,:) = [
            (double(accX(k+1))-double(accX(k)))/(double(time(k+1))-double(time(k))) ...
            (double(accY(k+1))-double(accY(k)))/(double(time(k+1))-double(time(k))) ...
            (double(accZ(k+1))-double(accZ(k)))/(double(time(k+1))-double(time(k))) ...
            (double(gyrX(k+1))-double(gyrX(k)))/(double(time(k+1))-double(time(k))) ...
            (double(gyrY(k+1))-double(gyrY(k)))/(double(time(k+1))-double(time(k))) ...
            (double(gyrZ(k+1))-double(gyrZ(k)))/(double(time(k+1))-double(time(k))) ...
            ];
    elseif k==n
        derivData(k,:) = [
            (double(accX(k))-double(accX(k-1)))/(double(time(k))-double(time(k-1))) ...
            (double(accY(k))-double(accY(k-1)))/(double(time(k))-double(time(k-1))) ...
            (double(accZ(k))-double(accZ(k-1)))/(double(time(k))-double(time(k-1))) ...
            (double(gyrX(k))-double(gyrX(k-1)))/(double(time(k))-double(time(k-1))) ...
            (double(gyrY(k))-double(gyrY(k-1)))/(double(time(k))-double(time(k-1))) ...
            (double(gyrZ(k))-double(gyrZ(k-1)))/(double(time(k))-double(time(k-1))) ...
            ];
    else
        derivData(k,:) = [
            (double(accX(k+1))-double(accX(k-1)))/(double(time(k+1))-double(time(k-1))) ...
            (double(accY(k+1))-double(accY(k-1)))/(double(time(k+1))-double(time(k-1))) ...
            (double(accZ(k+1))-double(accZ(k-1)))/(double(time(k+1))-double(time(k-1))) ...
            (double(gyrX(k+1))-double(gyrX(k-1)))/(double(time(k+1))-double(time(k-1))) ...
            (double(gyrY(k+1))-double(gyrY(k-1)))/(double(time(k+1))-double(time(k-1))) ...
            (double(gyrZ(k+1))-double(gyrZ(k-1)))/(double(time(k+1))-double(time(k-1))) ...
            ];
    end
end

% Compute double data derivate
doubleDerivData = NaN(n,6);
for k=1:n
    if k==1
        doubleDerivData(k,:) = [
            (double(derivData(k+1,1))-double(derivData(k,1)))/(double(time(k+1))-double(time(k))) ...
            (double(derivData(k+1,2))-double(derivData(k,2)))/(double(time(k+1))-double(time(k))) ...
            (double(derivData(k+1,3))-double(derivData(k,3)))/(double(time(k+1))-double(time(k))) ...
            (double(derivData(k+1,4))-double(derivData(k,4)))/(double(time(k+1))-double(time(k))) ...
            (double(derivData(k+1,5))-double(derivData(k,5)))/(double(time(k+1))-double(time(k))) ...
            (double(derivData(k+1,6))-double(derivData(k,6)))/(double(time(k+1))-double(time(k))) ...
            ];
    elseif k==n
        doubleDerivData(k,:) = [
            (double(derivData(k,1))-double(derivData(k-1,1)))/(double(time(k))-double(time(k-1))) ...
            (double(derivData(k,2))-double(derivData(k-1,2)))/(double(time(k))-double(time(k-1))) ...
            (double(derivData(k,3))-double(derivData(k-1,3)))/(double(time(k))-double(time(k-1))) ...
            (double(derivData(k,4))-double(derivData(k-1,4)))/(double(time(k))-double(time(k-1))) ...
            (double(derivData(k,5))-double(derivData(k-1,5)))/(double(time(k))-double(time(k-1))) ...
            (double(derivData(k,6))-double(derivData(k-1,6)))/(double(time(k))-double(time(k-1))) ...
            ];
    else
        doubleDerivData(k,:) = [
            (double(derivData(k+1,1))-double(derivData(k-1,1)))/(double(time(k+1))-double(time(k-1))) ...
            (double(derivData(k+1,2))-double(derivData(k-1,2)))/(double(time(k+1))-double(time(k-1))) ...
            (double(derivData(k+1,3))-double(derivData(k-1,3)))/(double(time(k+1))-double(time(k-1))) ...
            (double(derivData(k+1,4))-double(derivData(k-1,4)))/(double(time(k+1))-double(time(k-1))) ...
            (double(derivData(k+1,5))-double(derivData(k-1,5)))/(double(time(k+1))-double(time(k-1))) ...
            (double(derivData(k+1,6))-double(derivData(k-1,6)))/(double(time(k+1))-double(time(k-1))) ...
            ];
    end
end

%%
% GET FEATURES
% slice curves to get the same number of points on each curve

step = 3; %number of slice
ech = (n-1)/step; %sampling
x_=NaN; %features vector

% Mean data
x_ = [x_ ...
    mean(accX) mean(accY) mean(accZ) mean(gyrX) mean(gyrY) mean(gyrZ) ... 
    mean(integralData,1) mean(doubleIntegralData,1) mean(derivData,1) mean(doubleDerivData,1)];

%Cut each curves and add each point in the features vector
% ---ROW DATA (AccX, AccY,AccZ, GyrX, GyrY, GyrZ)
for i=1:ech:(n-ech)
    ind = floor(i);
    ind1 = floor(i+ech);
%     x_ = [x_ ...
%         double(accX(ind)) double(accY(ind)) double(accZ(ind)) ...
%         double(gyrX(ind)) double(gyrY(ind)) double(gyrZ(ind))];
    x_ = [x_ mean(double(gyrY(ind:ind1))) mean(double(gyrZ(ind:ind1)))];
end

% %---RAW DATA SPHERIC COO. (Acc & Gyr)
% for i=1:ech:n
%     ind = floor(i);
%     [phiAcc , thetaAcc] = sphericCoo(double(accX(ind)), double(accY(ind)), double(accZ(ind)));
%     [phiGyr , thetaGyr] = sphericCoo(double(gyrX(ind)), double(gyrY(ind)), double(gyrZ(ind)));
%     x_ = [x_, phiAcc, thetaAcc, phiGyr, thetaGyr];
% end

%---RAW DATA GLOBAL (AccGlobal GyrGlobal)
for i=1:ech:(n-ech) %SQRT(X²+Y²+Z²)
    ind = floor(i);
    ind1 = floor(i+ech);
    x_ = [x_ ...
        mean(sqrt(double(accX(ind:ind1)).^2 + double(accY(ind:ind1)).^2 + double(accZ(ind:ind1)).^2)) ...
        mean(sqrt(double(gyrX(ind:ind1)).^2 + double(gyrY(ind:ind1)).^2 + double(gyrZ(ind:ind1)).^2))];
end
% for i=1:ech:n %SQRT(X²+Y²)
%     ind = floor(i);
%     x_ = [x_ ...
%         sqrt(double(accX(ind)).^2 + double(accY(ind)).^2) ...
%         sqrt(double(gyrX(ind)).^2 + double(gyrY(ind)).^2)];
% end
% for i=1:ech:n %SQRT(X²+Z²)
%     ind = floor(i);
%     x_ = [x_ ...
%         sqrt(double(accX(ind)).^2 + double(accZ(ind)).^2) ...
%         sqrt(double(gyrX(ind)).^2 + double(gyrZ(ind)).^2)];
% end
% for i=1:ech:n %SQRT(Y²+Z²)
%     ind = floor(i);
%     x_ = [x_ ...
%         sqrt(double(accY(ind)).^2 + double(accZ(ind)).^2) ...
%         sqrt(double(gyrY(ind)).^2 + double(gyrZ(ind)).^2)];
% end

%---INTEGRAL (Speed X,Y,Z & Angle X,Y,Z)
for i=1:ech:(n-ech)
    ind = floor(i);
    ind1 = floor(i+ech);
%     x_ = [x_ ...
%         integralData(ind,1) integralData(ind,2) integralData(ind,3) ...
%         integralData(ind,4) integralData(ind,5) integralData(ind,6) ];
    x_ = [x_ mean(integralData(ind:ind1,5)) mean(integralData(ind:ind1,6))];
end

% %---INTEGRAL SPHERIC (Speed & Angle)
% for i=1:ech:n
%     ind = floor(i);
%     [phiVit , thetaVit] = sphericCoo(integralData(ind,1),integralData(ind,2),integralData(ind,3));
%     [phiAng , thetaAng] = sphericCoo(integralData(ind,4),integralData(ind,5),integralData(ind,6));
%     x_ = [x_, phiVit, thetaVit, phiAng, thetaAng];
% end

%---INTEGRAL GLOBAL (Global speed and angle)
for i=1:ech:(n-ech) %SQRT(X²+Y²+Z²)
    ind = floor(i);
    ind1 = floor(i+ech);
    x_ = [x_ ...
        mean(sqrt(integralData(ind:ind1,1).^2 + integralData(ind:ind1,2).^2 + integralData(ind:ind1,3).^2)) ...
        mean(sqrt(integralData(ind:ind1,4).^2 + integralData(ind:ind1,5).^2 + integralData(ind:ind1,6).^2))];
end
% for i=1:ech:n %SQRT(X²+Y²)
%     ind = floor(i);
%     x_ = [x_ ...
%         sqrt(integralData(ind,1).^2 + integralData(ind,2).^2) ...
%         sqrt(integralData(ind,4).^2 + integralData(ind,5).^2)];
% end
% for i=1:ech:n %SQRT(X²+Z²)
%     ind = floor(i);
%     x_ = [x_ ...
%         sqrt(integralData(ind,1).^2 + integralData(ind,3).^2) ...
%         sqrt(integralData(ind,4).^2 + integralData(ind,6).^2)];
% end
% for i=1:ech:n %SQRT(Y²+Z²)
%     ind = floor(i);
%     x_ = [x_ ...
%         sqrt(integralData(ind,2).^2 + integralData(ind,3).^2) ...
%         sqrt(integralData(ind,5).^2 + integralData(ind,6).^2)];
% end
% 
%---DOUBLE INTEGRAL (Postition X,Y,Z)
for i=1:ech:(n-ech)
    ind = floor(i);
    ind1 = floor(i+ech);
%     x_ = [x_ doubleIntegralData(ind,1) doubleIntegralData(ind,2) doubleIntegralData(ind,3)];
    x_ = [x_ mean(doubleIntegralData(ind:ind1,5)) mean(doubleIntegralData(ind:ind1,6))];
end

%---DOUBLE INTEGRALE GLOBAL (Position)
for i=1:ech:(n-ech) %SQRT(X²+Y²+Z²)
    ind = floor(i);
    ind1 = floor(i+ech);
    x_ = [x_ ...
        mean(sqrt(doubleIntegralData(ind:ind1,1).^2 + doubleIntegralData(ind:ind1,2).^2 + doubleIntegralData(ind:ind1,3).^2)) ...
        mean(sqrt(doubleIntegralData(ind:ind1,4).^2 + doubleIntegralData(ind:ind1,5).^2 + doubleIntegralData(ind:ind1,6).^2))];
end
% for i=1:ech:n %SQRT(X²+Y²)
%     ind = floor(i);
%     x_ = [x_ sqrt(doubleIntegralData(ind,1).^2 + doubleIntegralData(ind,2).^2)]; %SQRT(X²+Y²)
% end
% for i=1:ech:n %SQRT(X²+Z²)
%     ind = floor(i);
%     x_ = [x_ sqrt(doubleIntegralData(ind,1).^2 + doubleIntegralData(ind,3).^2)]; %SQRT(X²+Z²)
% end
% for i=1:ech:n %SQRT(Y²+Z²)
%     ind = floor(i);
%     x_ = [x_ sqrt(doubleIntegralData(ind,2).^2 + doubleIntegralData(ind,3).^2)]; %SQRT(Y²+Z²)
% end
% 
% %---DOUBLE INTEGRAL SPHERIC (Position)
% for i=1:ech:n
%     ind = floor(i);
%     [phiPos , thetaPos] = sphericCoo(doubleIntegralData(ind,1),doubleIntegralData(ind,2),doubleIntegralData(ind,3));
%     x_ = [x_, phiPos, thetaPos];
% end

%---DERIVATE
for i=1:ech:(n-ech)
    ind = floor(i);
    ind1 = floor(i+ech);
    x_ = [x_ mean(derivData(ind:ind1,5)) mean(derivData(ind:ind1,6))];
end

%---DERIVATE GLOBAL
for i=1:ech:(n-ech) %SQRT(X²+Y²+Z²)
    ind = floor(i);
    ind1 = floor(i+ech);
    x_ = [x_ ...
        mean(sqrt(derivData(ind:ind1,1).^2 + derivData(ind:ind1,2).^2 + derivData(ind:ind1,3).^2)) ...
        mean(sqrt(derivData(ind:ind1,4).^2 + derivData(ind:ind1,5).^2 + derivData(ind:ind1,6).^2))];
end

%---DOUBLE DERIVATE
for i=1:ech:(n-ech)
    ind = floor(i);
    ind1 = floor(i+ech);
    x_ = [x_ mean(doubleDerivData(ind:ind1,5)) mean(doubleDerivData(ind:ind1,6))];
end

%---DOUBLE DERIVATE GLOBAL
for i=1:ech:(n-ech) %SQRT(X²+Y²+Z²)
    ind = floor(i);
    ind1 = floor(i+ech);
    x_ = [x_ ...
        mean(sqrt(doubleDerivData(ind:ind1,1).^2 + doubleDerivData(ind:ind1,2).^2 + doubleDerivData(ind:ind1,3).^2)) ...
        mean(sqrt(doubleDerivData(ind:ind1,4).^2 + doubleDerivData(ind:ind1,5).^2 + doubleDerivData(ind:ind1,6).^2))];
end

%%
% MAKE FEATURES VECTOR

X = double(x_(2:end));
X = real(X); % sometimes it generates complex numbers even if it's just real numbers
Xoutput = [X sqrt(abs(X)) X.^2 X.^3 log(abs(X)+0.01)]; % Add features
end