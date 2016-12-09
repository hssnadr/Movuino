function [ Ureduce ] = PCA( datSetMatrix )
%Principal Component Analysis
%features association: project features on specific vectors to reduce their number
%PCA function compute Ureduce (used by LogisticRegression.m and PLAY.m)
%cf. Coursera - Week 13 - PCA Algorithm

m = size(datSetMatrix,1);% number of gesture examples
X_ = datSetMatrix;

%Compute eigen vectors and matrix
%formula p.28
Sigma = (1/m)*(X_'*X_);
[U,S,V] = svd(Sigma);

%Get main compenants
%formula p.29
k=1;
while(sum(diag(S(1:k,1:k)))/sum(diag(S)) <0.99) %precision up to 99%
    k=k+1;
end

%OUTPUT
Ureduce = U(:,1:k);%Reduction matrix

%%
%Plot weight graph (optional)
wMeanFeatures = mean(abs(Ureduce),2);
figure
bar(wMeanFeatures)

% Save figure
savefig('featuresRepartition_')
end

