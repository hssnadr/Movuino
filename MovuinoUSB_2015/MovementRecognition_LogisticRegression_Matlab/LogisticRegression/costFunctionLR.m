function [ jVal, gradient ] = costFunctionLR( theta )

load('LRvariables.mat'); % get Xtrain,Ytrain and lambda
n = size(Xtrain,2)-1; % number of features (without bias units)
m = length(Ytrain); % number of trainging examples
jVal_ = 0;
gradient_ = zeros(n+1,1);

for i=1:m
    X_ = Xtrain(i,:)';
    h_ = hFun(X_,theta);
    jVal_ = jVal_ + (1/m)*cost(h_,Ytrain(i));
    gradient_ = gradient_ + (1/m)*(h_-Ytrain(i))*X_; % formule p.9
end

jVal = jVal_ + (lambda/(2*m))*sum(theta(2:end)); % Regularistation de jVal
gradient = gradient_;

end

function [output] = cost(h,y)
output = -y.*log(h)-(1-y).*log(1-h); % formule p.9
end
