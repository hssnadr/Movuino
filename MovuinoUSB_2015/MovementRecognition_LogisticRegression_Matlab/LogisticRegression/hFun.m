function [ output ] = hFun(X,theta)
% Evaluate estimated output value (h)
output = sigmoid(theta'*X);
end

function [Y] = sigmoid(X)
Y=1./(1+exp(-X));
end