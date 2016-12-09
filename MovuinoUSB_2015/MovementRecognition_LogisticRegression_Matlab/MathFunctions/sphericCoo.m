function [ phi , theta ] = sphericCoo( X,Y,Z )
%Get spheric coordinates based on cartesian ones
%returns angles phi and theta

if(X.^2 + Y.^2 + Z.^2 ~= 0)
    phi = acos(Z ./ sqrt(X.^2 + Y.^2 + Z.^2));
else
    phi = 0;
end

if(X~=0)
    theta = atan(Y ./ X);
else
    theta = 0;
end

end

